//
//  BaseApiManager.swift
//  swiftArchitecture
//
//  Created by Klein Mioke on 15/12/7.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import Foundation
import Alamofire

class BaseApiManager: NSObject {
    
    // MARK: Statics
    /// For produce the unique key of caches
    fileprivate static var keyNum: Int = 0
    
    // MARK: Privates
    fileprivate weak var child: ApiInfoProtocol?
    fileprivate var request: DataRequest?
    
    fileprivate var retryTimes: Int = 0
    
    fileprivate var data: [String: Any]?
    fileprivate var urlString: String?
    fileprivate var cacheKey: String?
    
    // MARK: Publics
    var isLoading = false
    var timeoutInterval: TimeInterval = 20
    var autoProcessServerData: Bool = true
    
    /// if this property is true, it will auto retry when all situations are eligible
    var shouldAutoRetry: Bool = true
    var shouldAutoCacheResultWhenSucceed: Bool = false
    
    // MARK: Initialization
    override init() {
        super.init()
        if self is ApiInfoProtocol {
            self.child = (self as! ApiInfoProtocol)
        } else {
            assert(false, "ApiManager's subclass must conform the ApiInfoProtocol")
        }
    }
    
    // MARK: - Actions
    weak var delegate: ApiCallbackProtocol?
    
    public func loadData(with params: [String: Any]?) -> Void {
        
        if self.isLoading {
            debugPrint("API manager current is requesting, if you want to reload, call cancel() and retry")
            return
        }
        // If there is cached result then return it.
        
        if let key = self.cacheKey,
            let value = NetworkCache.memoryCache.object(forKey: key) as? [String: Any], self.shouldAutoCacheResultWhenSucceed {
            
            self.data = value
            self.loadingComplete()
            self.delegate?.ApiManager(self, finishWithOriginData: value)
            return
        }
        
        self.isLoading = true
        self.cancel()
        
        self.request = KMRequestGenerator.generateRequest(withApi: self, method: self.child!.httpMethod, params: params)
        self.request?.session.configuration.timeoutIntervalForRequest = self.timeoutInterval
        
        self.request?.responseJSON(completionHandler: { (resp: DataResponse<Any>) in
            
            self.isLoading = false
            var err: NSError?
            
            // HTTP request success
            if let value = resp.result.value as? [String: Any] {
                self.data = value
                SystemLog.write("HTTP response:\n\tRESP:\(resp.response!)\n\tVALUE:\(value)")
                
                // If the server has retry mechanism
                if let server = self.child!.server as? ServerDataProcessProtocol,
                    self.autoProcessServerData {
                    
                    var shouldRetry = false
                    do {
                        try server.handle(data: value, shouldRetry: &shouldRetry)
                        self.loadingComplete()
                        self.successRoute()
                    } catch {
                        err = error as NSError
                    }
                } else {
                    self.loadingComplete()
                    self.successRoute()
                }
            }
            // HTTP request error
            else if let error = resp.result.error {
                self.loadingFailed(with: error as NSError)
                self.failureRoute(with: error as NSError)
                err = error as NSError?
            }
            // Value is not a Dictionary
            else {
                let error = NSError(domain: "Unknown domain", code: 1001, userInfo: nil)
                self.loadingFailed(with: error)
                self.failureRoute(with: error)
                err = error
            }
            
            if let err = err {
                // Retry operations
                if let maxCount = self.child!.autoRetryMaxCount(withErrorCode: err.code),
                    let interval = self.child!.retryTimeInterval(withErrorCode: err.code) {
                    
                    if self.shouldAutoRetry && self.retryTimes < maxCount {
                        
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: interval), execute: {
                            self.loadData(with: params)
                        })
                        self.retryTimes += 1
                        return
                    }
                }
                // reset the retry count
                self.retryTimes = 0
                
                self.loadingFailed(with: err)
                self.failureRoute(with: err)
                
                SystemLog.write("HTTP response:\n\tRESP:\(resp.response!)\n\tVALUE:\(err)")
            }
        })
    }
    
    open func cancel() -> Void {
        self.request?.cancel()
    }
    
    private func successRoute() -> Void {
        self.doOnMainQueue({
            self.delegate?.ApiManager(self, finishWithOriginData: self.data!)
        })
        self.retryTimes = 0
        if self.shouldAutoCacheResultWhenSucceed {
            if self.cacheKey == nil {
                self.cacheKey = "\(self.child!.apiName)_\(BaseApiManager.keyNum)"
                BaseApiManager.keyNum += 1
            }
            NetworkCache.memoryCache.set(object: self.data!, forKey: self.child!.apiName)
        }
    }
    
    private func failureRoute(with error: NSError) -> Void {
        self.doOnMainQueue({
            self.delegate?.ApiManager(self, failedWithError: error)
        })
    }
    
    // MARK: - Callbacks
    public func loadingComplete() -> Void {
        // hook
    }
    
    public func loadingFailed(with error: NSError) -> Void {
        // hook
    }
    
    // MARK: - Others
    
    /// HTTP request is succeed or not
    open func isSuccess() -> Bool {
        return self.data != nil && !self.isLoading
    }
    
    /// Data which received from server and transformed to JSON
    ///
    /// - Returns: origin data
    open func originData() -> [String: Any]? {
        return self.data
    }
    
    /// Get url string including server url, API version and API name
    ///
    /// - Returns: URL string of request, doesn't include query parameters.
    open func apiURLString() -> String {
        
        if self.urlString == nil {
            if self.child!.apiVersion.isEmpty {
                self.urlString = self.child!.server.url + "/" + self.child!.apiName
            } else {
                self.urlString = self.child!.server.url + "/" + self.child!.apiVersion + "/" + self.child!.apiName
            }
        }
        return self.urlString!
    }
    
    private func doOnMainQueue(_ block: @escaping () -> ()) -> Void {
        DispatchQueue.main.async(execute: block)
    }
}
