//
//  FrontendWrapper.swift
//  CDEnvCInterp
//
//  Created by xcbosa on 2022/6/13.
//

import Foundation

public typealias CDEnvCPointer = UnsafeMutablePointer<CDEnvCInstance>

public class FrontendWrapper {
    
    private static var inited: Bool = false
    
    public class func initWrapper() {
        if Self.inited {
            return
        }
        Self.inited = true
        
        sf_setup_pid = setup(forInstance:)
        sf_cleanup_pid = cleanUp(forPid:)
        
        some_other_works_to_initialize();

        // Todo: Add Wrapper initialization
        TreeObjectWrapper.initWrapper()
        CCDUIWrapper.initWrapper()
#if MAINAPP_TARGET
        PMWrapper.initWrapper()
#endif
    }
    
    public class func setup(forInstance cdenvcInstance: CDEnvCPointer) {
#if MAINAPP_TARGET
        PMWrapper.setup(forInstance: cdenvcInstance)
#endif
        TreeObjectWrapper.setup(forPid: cdenvcInstance.pointee.Pid)
        CCDUIWrapper.setup(forPid: cdenvcInstance.pointee.Pid)
    }
    
    public class func cleanUp(forPid pid: Int32) {
#if MAINAPP_TARGET
        PMWrapper.cleanUp(forPid: pid)
        TreeObjectWrapper.cleanUp(forPid: pid)
        CCDUIWrapper.cleanUp(forPid: pid)
#endif
    }
    
}
