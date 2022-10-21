//
//  PMProcess.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/10.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation
import XCNotificationCenter

public enum PMStatus: String {
    case running = "running"
    case waitingInput = "waitingInput"
    case waitingForStop = "waitingForStop"
}

public class PMProcess {
    
    public var cdenvcInstance: CDEnvCPointer
    weak var terminalViewController: TerminalViewController?
    public var pid: Int32
    
    public var projectName: String {
        terminalViewController?.runningProjectName ?? ""
    }
    
    public var fileName: String? {
        let str = terminalViewController?.runningFileName ?? ""
        if str.count == 0 { return nil }
        return str
    }
    
    public var status: PMStatus {
        if cdenvcInstance.pointee.pthread_cancel_p > 0 {
            return .waitingForStop
        }
        if cdenvcInstance.pointee.ui_stdin_needed != 0 {
            return .waitingInput
        }
        return .running
    }
    
    public init(_ cdenvcInstance: CDEnvCPointer) {
        self.cdenvcInstance = cdenvcInstance
        self.pid = cdenvcInstance.pointee.Pid
        let group = DispatchGroup()
        group.enter()
        let closureSetTerminalVc: (TerminalViewController) -> Void = {
            if self.terminalViewController != nil { return }
            self.terminalViewController = $0
            group.leave()
        }
        XCNotificationCenter.shared.post(notificationNamed: .pmRequireTerminalViewController, attachedObject: PmRequireTerminalViewControllerInfo(pid: self.pid, provideVcIfIsPid: closureSetTerminalVc))
        group.wait()
    }
    
    public func shutdown() {
        cdenvcInstance.pointee.pthread_cancel_p = 1
    }
    
}
