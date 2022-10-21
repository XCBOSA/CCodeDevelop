//
//  CCDUIWrapper.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/8.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation
import UIKit
import XCNotificationCenter

public class CCDUIWrapper: FrontendLifeCycle {
    
    public private(set) static var process = [Int32 : CCDUIProcess]()
    
    public static func initWrapper() {
        #if MAINAPP_TARGET
        print("MAINAPP_TARGET")
        sf_ui_start = {
            Pid, ParserState in
            guard let process = process[Pid] else { return -1 }
            return process.joinMessageLoop(ParserState)
        }
        sf_ui_create = {
            Pid in
            guard let process = process[Pid] else { return -1 }
            return process.allocateObject()
        }
        sf_ui_attach = {
            Pid, WindowHandle, TreeHandle in
            guard let process = process[Pid] else { return }
            guard let treeProcess = TreeObjectWrapper.process[Pid] else { return }
            if let treeObject = treeProcess.getObject(withId: TreeHandle),
               let window = process.getObject(withId: WindowHandle) {
                //treeProcess.make(current: TreeHandle, linkWithParent: TreeHandle)
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    window.swiftUIView.updater.rootData = treeObject
                    window.swiftUIView.updater.viewData = treeObject
                    window.swiftUIView.updater.updatee.toggle()
                    group.leave()
                }
                group.wait()
            }
        }
        sf_ui_show = {
            Pid, WindowHandle, OpenMethod in
            guard let process = process[Pid] else { return }
            guard let window = process.getObject(withId: WindowHandle) else { return }
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                if !window.isPresenting {
                    if OpenMethod == 0 {
                        window.isPresenting = true
                        window.checkDisappear = true
                        if splitViewControllerIsIpadMode() {
                            UIApplication.shared.requestSceneSessionActivation(nil,
                                                                               userActivity: SceneDelegate.activity {
                                window
                            }, options: .none)
                            window.dismissBlock = {
                                if let sceneSession = UIApplication.shared.sceneSession(forRootViewController: window) {
                                    UIApplication.shared.requestSceneSessionDestruction(sceneSession, options: nil)
                                }
                            }
                            XCNotificationCenter.shared.addObserver(window, forName: "didDiscardSceneSessions") {
                                data in
                                guard let data = data as? Set<UISceneSession> else { return }
                                for it in data {
                                    if let windowScene = it.scene as? UIWindowScene {
                                        for windowC in windowScene.windows {
                                            if windowC.rootViewController == window {
                                                window.dismiss(animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if let parentVc = window.presentOnViewController {
                                parentVc.present(window, animated: true)
                            }
                        }
                    }
                    else if (OpenMethod == 1) {
                        window.isPresenting = true
                        window.checkDisappear = false
                        window.dismissBlock = {
                            window.windowManager?.forceCloseWindow(window)
                        }
                        window.presentOnViewController?.ide?.windowManager.openWindow(useWindowInstance: window, switchTo: true)
                    }
                }
                group.leave()
            }
            group.wait()
        }
        sf_ui_close = {
            Pid, WindowHandle in
            guard let process = process[Pid] else { return }
            guard let window = process.getObject(withId: WindowHandle) else { return }
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                window.dismiss(animated: true)
                group.leave()
            }
            group.wait()
        }
        sf_ui_destroy = {
            Pid, WindowHandle in
            guard let process = process[Pid] else { return }
            process.freeObject(withId: WindowHandle)
        }
        sf_ui_id = {
            Pid, TreeHandle, Id in
            guard let process = process[Pid] else { return 0 }
            guard let treeProcess = TreeObjectWrapper.process[Pid] else { return 0 }
            guard let Id = NSString(cString: Id, encoding: String.Encoding.utf8.rawValue) as? String else { return treeProcess.nullValue }
            return treeProcess.firstNode(fromRootNode: TreeHandle, by: { $0.uiGetMember("id").type == .valueString && $0.uiGetMember("id").stringValue == Id }) ?? treeProcess.nullValue
        }
        #else
        sf_ui_start = {
            Pid, ParserState in
            guard let process = process[Pid] else { return -1 }
            return 0
        }
        sf_ui_create = {
            Pid in
            guard let process = process[Pid] else { return -1 }
            return 0
        }
        sf_ui_attach = {
            Pid, WindowHandle, TreeHandle in
            guard let process = process[Pid] else { return }
            guard let treeProcess = TreeObjectWrapper.process[Pid] else { return }
            return
        }
        sf_ui_show = {
            Pid, WindowHandle, OpenMethod in
            guard let process = process[Pid] else { return }
            return
        }
        sf_ui_close = {
            Pid, WindowHandle in
            guard let process = process[Pid] else { return }
            return
        }
        sf_ui_destroy = {
            Pid, WindowHandle in
            return
        }
        sf_ui_id = {
            Pid, TreeHandle, Id in
            return 0
        }
        #endif
    }
    
    public static func setup(forPid pid: Int32) {
        #if MAINAPP_TARGET
        if process[pid] != nil {
            return
        }
        process[pid] = CCDUIProcess(withPid: pid)
        #endif
    }
    
    public static func cleanUp(forPid pid: Int32) {
        #if MAINAPP_TARGET
        process[pid]?.cleanUp()
        process.removeValue(forKey: pid)
        #endif
    }
    
}

extension UIApplication {
    func window(forRootViewController rootVc: UIViewController) -> UIWindow? {
        if let windowScene = connectedScenes
            .map( {$0 as? UIWindowScene})
            .compactMap( {$0})
            .first(where: { $0.windows.contains(where: { $0.rootViewController == rootVc }) }),
           let window = windowScene.windows.first(where: { $0 == rootVc }) {
            return window
        }
        return nil
    }
    
    func sceneSession(forRootViewController rootVc: UIViewController) -> UISceneSession? {
        if let windowScene = connectedScenes
            .map( {$0 as? UIWindowScene})
            .compactMap( {$0})
            .first(where: { $0.windows.contains(where: { $0.rootViewController == rootVc }) }) {
            return windowScene.session
        }
        return nil
    }
    
    func sceneSession(where predicate: (UIViewController?) -> Bool) -> UISceneSession? {
        if let windowScene = connectedScenes
            .map( {$0 as? UIWindowScene})
            .compactMap( {$0})
            .first(where: { $0.windows.contains(where: { predicate($0.rootViewController) }) }) {
            return windowScene.session
        }
        return nil
    }
    
    func sceneSessionForAllRootViewControllers() -> [UIViewController] {
        var vcs = [UIViewController]()
        for it in connectedScenes.map( {$0 as? UIWindowScene})
            .compactMap( {$0} ) {
            for wnd in it.windows {
                if let w = wnd.rootViewController {
                    vcs.append(w)
                }
            }
        }
        return vcs
    }
}
