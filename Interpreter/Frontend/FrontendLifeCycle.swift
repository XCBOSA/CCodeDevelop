//
//  FrontendLifeCycle.swift
//  CDEnvCInterp
//
//  Created by xcbosa on 2022/6/13.
//

import Foundation

public protocol FrontendLifeCycle {
    
    static func initWrapper()
    static func setup(forPid pid: Int32)
    static func cleanUp(forPid pid: Int32)
    
}

public protocol FrontendLifeCycleEx {
    
    static func initWrapper()
    static func setup(forInstance instance: CDEnvCPointer)
    static func cleanUp(forPid pid: Int32)
    
}
