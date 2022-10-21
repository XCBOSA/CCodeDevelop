//
//  PMWrapper.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/10.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation

public class PMWrapper: FrontendLifeCycleEx {
    
    public private(set) static var process = [Int32 : PMProcess]()
    
    public static func initWrapper() {
        
    }
    
    public static func setup(forInstance instance: CDEnvCPointer) {
        process[instance.pointee.Pid] = PMProcess(instance)
    }
    
    public static func cleanUp(forPid pid: Int32) {
        process[pid] = nil
    }
    
}
