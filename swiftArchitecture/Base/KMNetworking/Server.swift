//
//  Server.swift
//  swiftArchitecture
//
//  Created by Klein Mioke on 15/12/7.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import Foundation

class Server: NSObject {
    
    static var online: Bool = true

    fileprivate var onlineURL: String
    fileprivate var offlineURL: String
    
    var url: String {
        get {
            if Server.online {
                return self.onlineURL
            } else {
                return self.offlineURL
            }
        }
    }
    /**
     Initailize a server with online url and offline/test url
     
     - parameter online:  The URL that online server's site
     - parameter offline: The URL that offline or test server's site
     # Format is like _https://10.24.0.3:8001_ or something, don't end with '/' (I think this is big enough to warn you)
     */
    init(online: String, offline: String) {
        self.onlineURL = online
        self.offlineURL = offline
        super.init()
    }
}

let kServer = Server(online: "https://www.baidu.com", offline: "https://www.baidu.com")

protocol ServerDataProcessProtocol {
    func handle(data: Any, shouldRetry: inout Bool) throws -> Void
}
