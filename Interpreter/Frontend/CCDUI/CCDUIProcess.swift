//
//  CCDUIProcess.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/8.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation

public class CCDUIProcess {
    
#if MAINAPP_TARGET
    
    private var objects = [CCDUIObjectHandle : CCDUIObject]()
    private var freeList = [CCDUIObjectHandle]()
    private var maker: CCDUIObjectHandle = 0
    
    public private(set) var pid: Int32
    public private(set) var userThreadJoined: Bool = false
    public private(set) var parserState: UnsafeMutablePointer<ParseState>?
    public private(set) var actions = [() -> Void]()
    
    public var treeProcess: TreeObjectProcess! {
        TreeObjectWrapper.process[pid]
    }
    
    public init(withPid pid: Int32) {
        self.pid = pid
    }
    
    private func allocateId() -> CCDUIObjectHandle {
        if !freeList.isEmpty {
            return freeList.removeLast()
        }
        let newId = maker
        maker += 1
        return newId
    }
    
    private func freeId(_ id: CCDUIObjectHandle) {
        freeList.append(id)
    }
    
    public func allocateObject() -> CCDUIObjectHandle {
        let id = allocateId()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            let object = CCDUIObject(viewData: self.treeProcess.nullValueObject, id: id, presentOnViewController: PMWrapper.process[self.pid]?.terminalViewController)
            self.objects[id] = object
            group.leave()
        }
        group.wait()
        return id
    }
    
    public func freeObject(withId: CCDUIObjectHandle) {
        if let removedVc = objects.removeValue(forKey: withId) {
            DispatchQueue.main.async {
                if removedVc.isBeingPresented {
                    removedVc.dismiss(animated: false)
                }
            }
        }
        freeId(withId)
    }
    
    public func getObject(withId: CCDUIObjectHandle) -> CCDUIObject? {
        return objects[withId]
    }
    
    public func dispatchAsync(_ closure: @escaping () -> Void) {
        actions.append(closure)
    }
    
    public func dispatchSync(_ closure: @escaping () -> Void) {
        let group = DispatchGroup()
        group.enter()
        dispatchAsync {
            closure()
            group.leave()
        }
        group.wait()
    }
    
    public func dispatchRedrawAsync(_ windowHandle: CCDUIObjectHandle) {
        self.objects[windowHandle]?.needRedraw = true;
    }
    
    public func joinMessageLoop(_ parserState: UnsafeMutablePointer<ParseState>) -> Int32 {
        guard let pc = PMWrapper.process[pid]?.cdenvcInstance else { return -1 }
        self.parserState = parserState
        if userThreadJoined { return -1 }
        userThreadJoined = true
        defer {
            userThreadJoined = false
        }
        while pc.pointee.pthread_cancel_p == 0 {
            if !updateView() {
                return 0
            }
        }
        return 0
    }
    
    private func updateView() -> Bool {
        while !actions.isEmpty {
            actions.removeLast()()
        }
        var fin = false
        var activeCount = 0
        DispatchQueue.main.async {
            for it in self.objects.values {
                if it.isPresenting {
                    activeCount += 1
                    if it.needRedraw {
                        it.needRedraw = false
                        it.swiftUIView.updater.updatee.toggle()
                    }
                }
            }
            fin = true
        }
        while !fin { usleep(1000) }
        return activeCount != 0
    }
    
    public func cleanUp() {
        DispatchQueue.main.sync {
            for it in self.objects.values {
                if it.isPresenting {
                    it.dismiss(animated: false)
                }
            }
        }
    }
    
#endif
    
}
