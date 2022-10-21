//
//  CCDUIObject.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/8.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public typealias CCDUIObjectHandle = Int32

#if MAINAPP_TARGET

public class CCDUIObject: UIHostingController<CCDUIComponentWrapperUI>, AbstractWindow {
    
    public var filePath: String = "CCDUI Window"
    public var type: AbstractWindowType = .draggableTools
    
    public var swiftUIView: CCDUIComponentWrapperUI
    
    public var needRedraw = false
    public var isPresenting = false
    public var checkDisappear = true
    public weak var presentOnViewController: UIViewController?
    public weak var windowManager: WindowManager?
    
    public init(viewData: TreeObject, id: CCDUIObjectHandle, presentOnViewController vc: UIViewController?) {
        self.presentOnViewController = vc
        self.windowManager = vc?.ide?.windowManager
        self.swiftUIView = CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: viewData, andRoot: viewData, andWindowId: id, project: vc?.project))
        super.init(rootView: swiftUIView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var dismissBlock: (() -> Void)?
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if isPresenting {
            isPresenting = false
            if let dismissBlock = dismissBlock {
                dismissBlock()
            } else {
                super.dismiss(animated: flag, completion: completion)
            }
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        if checkDisappear {
            isPresenting = false
        }
    }
    
}

#endif
