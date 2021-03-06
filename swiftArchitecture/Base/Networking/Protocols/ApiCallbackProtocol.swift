//
//  ApiCallbackProtocol.swift
//  swiftArchitecture
//
//  Created by Klein Mioke on 15/12/7.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import Foundation

/// Describe callback of an api.
internal protocol ApiCallbackProtocol: NSObjectProtocol {

    /// Success callback
    ///
    /// - Parameters:
    ///   - apiManager: api manager which finished
    ///   - data: Origin data of response
    func API(_ api: API, finishedWithOriginData data: [String : Any]) -> Void
    
    /**
     If API returns error or undefined exception, will call this method in delegate. 
     
     - ATTENTION: **DON'T** try to solve problems here, only do the reflection after error occured
     
     - parameter apimanager:      API manager
     - parameter failedWithError: The error occured
     */
    func API(_ api: API, failedWithError error: NSError) -> Void
}
