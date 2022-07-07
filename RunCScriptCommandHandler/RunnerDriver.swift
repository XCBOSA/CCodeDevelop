//
//  RunnerDriver.swift
//  RunCScriptCommandHandler
//
//  Created by 邢铖 on 2022/7/7.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation

public struct CodeFile {
    public var fileName, content: String
}

public struct CodeEnvironment {
    public var files: [CodeFile]
    public var startIndex: Int
}

public class RunnerDriver {
    
    var processThread: Thread?
    
    public func runCodeAsync(inEnvironment env: CodeEnvironment) {
        sf_receiver_putchar = bridgePutchar(_:)
        sf_ccd_io_fopen = bridgeFopen(_:_:)
        sf_ccd_io_fclose = bridgeFclose(_:)
        sf_ccd_io_fflush = bridgeFflush(_:)
        sf_ccd_io_fputc = bridgeFputc(_:_:)
        sf_ccd_io_fgetc = bridgeFgetc(_:)
        sf_ccd_io_fsetpos = bridgeFsetpos(_:_:)
        sf_ccd_io_fgetpos = bridgeFgetpos(_:)
        sf_ccd_io_fungetc = bridgeFungetc(_:_:)
        sf_ccd_system_clear = bridgeClear
        sf_setup_pid = Self.setup(forPid:)
        sf_cleanup_pid = Self.cleanUp(forPid:)
        TreeObjectWrapper.initWrapper()
        
        pthread_cancel_p = 0
        
        processThread = Thread {
            print("Process started.")
            CCDPrepareCompile()
            for it in env.files.filter({ $0.fileName != env.files[env.startIndex].fileName }) {
                let unsafeFileName = UnsafeMutablePointer<Int8>(mutating: (it.fileName as NSString).utf8String)
                let unsafeCode = UnsafeMutablePointer<Int8>(mutating: (it.content as NSString).utf8String)
                CCDAddFile(unsafeFileName, unsafeCode)
            }
            let unsafe_predefinedStdin = UnsafeMutablePointer<Int8>(mutating: ("" as NSString).utf8String)
            setPredefinedStdin(unsafe_predefinedStdin!)
            let unsafeArgs = UnsafeMutablePointer<Int8>(mutating: ("notebook" as NSString).utf8String)
            mainInvokerSetArgs(unsafeArgs!)
            let entryFile = UnsafeMutablePointer<Int8>(mutating: (env.files[env.startIndex].content as NSString).utf8String)!
            CCDInterpretInline(entryFile)
        }
        
        Thread {
            [weak self] in
            while (true) {
                guard let self = self, let processThread = self.processThread else {
                    return
                }

                if (ccd_state == 1) {
                    ccd_state = 10
                }

                if (ui_stdin_needed == 1) {
                    let ch = fgetc(stdin)
                    stdin_putch_u(UInt8(ch))
                } else if (ui_stdin_needed == 0) {

                }

                if processThread.isExecuting {

                } else {
                    print("\nProcess terminated.")
                    self.processThread = nil
                    return
                }
                usleep(1000)
            }
        }.start()
        
        processThread?.start()
    }
    
    public func waitForEnd() {
        while self.processThread != nil {
            usleep(20000)
        }
    }
    
    public func runCode(inEnvironment env: CodeEnvironment, notify: (() -> Void)? = nil) {
        runCodeAsync(inEnvironment: env)
        if let notify = notify {
            DispatchQueue.global(qos: .utility).async {
                self.waitForEnd()
                notify()
            }
        } else {
            waitForEnd()
        }
    }
    
    public private(set) var stdout: String = ""
    
    private func bridgePutchar(_ ch: UnsafeMutablePointer<Int8>?) {
        guard let ch = ch else {
            return
        }
        
        if let scalar = Unicode.Scalar(UInt32(ch.pointee)) {
            stdout.append(Character(scalar))
        }
    }
    
    private func bridgeClear() {
        print("## Clear Screen")
    }
    
    public func stopCode() {
        pthread_cancel_p = 1
    }
    
}

extension RunnerDriver {
    
    private class func setup(forPid pid: Int32) {
        TreeObjectWrapper.setup(forPid: pid)
    }
    
    private class func cleanUp(forPid pid: Int32) {
        TreeObjectWrapper.cleanUp(forPid: pid)
    }
    
    private func bridgeFopen(_ file: UnsafeMutablePointer<CChar>, _ openMode: UnsafeMutablePointer<CChar>) -> Int32 {
        
        return 0
    }
    
    private func bridgeFclose(_ fd: Int32) {
        
    }
    
    private func bridgeFflush(_ fd: Int32) {
        
    }
    
    private func bridgeFputc(_ fd: Int32, _ ch: CChar) {
        
    }
    
    private func bridgeFgetc(_ fd: Int32) -> Int8 {
        
        return 0
    }
    
    private func bridgeFsetpos(_ fd: Int32, _ pos: Int32) {
        
    }
    
    private func bridgeFgetpos(_ fd: Int32) -> Int32 {
        
        return 0
    }
    
    private func bridgeFungetc(_ fd: Int32, _ c: UInt8) {
        
    }
    
}

