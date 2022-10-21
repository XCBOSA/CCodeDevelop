//
//  FruitUIContainer.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/7.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import SwiftUI

extension TreeObject: Hashable {
    
    public static func == (lhs: TreeObject, rhs: TreeObject) -> Bool { lhs.id == rhs.id }
    public var hashValue: Int { Int(self.id) }
    public func hash(into hasher: inout Hasher) { hasher.combine(hashValue) }
    
    public var arrayObjects: [TreeObject] {
        guard let process = process else { return [] }
        return arrayValue?
            .map { process.getObject(withId: $0) ?? process.nullValueObject }
            .filter { $0.type != .null }
        ?? []
    }
    
    public func uiGetMember(_ named: String ...) -> TreeObject {
        guard let process = process else { return TreeObject(aNullValue: 0, ofProcess: nil) }
        for it in named {
            if hasMember(it) {
                return process.getObject(withId: kvGet(it)) ?? process.nullValueObject
            }
        }
        return process.nullValueObject
    }
    
    public func hasMember(_ named: String) -> Bool {
        switch self.type {
        case .kv:
            return kvValue?.contains(where: { $0.0 == named }) ?? false
        case .array:
            if let index = Int(named) {
                return index >= 0 && index < (arrayValue?.count ?? 0)
            }
            return false
        case .valueInt:
            return false
        case .valueString:
            return false
        case .null:
            return false
        case .valueDouble:
            return false
        }
    }
    
    public var uiType: String {
        uiGetMember("type").toString()
    }
    
    public var uiText: String {
        get {
            return uiGetMember("text").toString()
        }
        set {
            if uiGetMember("text").type != .null {
                uiGetMember("text").assign(toStringValue: newValue)
            }
        }
    }
    
    public var uiAction: Int {
        Int(uiGetMember("action").intValue ?? -1)
    }
    
    public var uiColor: Color? {
        let color = uiGetMember("color", "colorfg").toString()
        if let color = Color(hexOrName: color) {
            return color
        } else {
            return nil
        }
    }
    
    public var uiColorBg: Color? {
        let color = uiGetMember("colorbg").toString()
        if let color = Color(hexOrName: color) {
            return color
        } else {
            return nil
        }
    }
    
    public var uiAlignmentH: HorizontalAlignment {
        let color = uiGetMember("align", "alignment").toString()
        switch color {
        case "left": return .leading
        case "center": return .center
        case "right": return .trailing
        default: return .center
        }
    }
    
    public var uiAlignmentV: VerticalAlignment {
        let color = uiGetMember("align", "alignment").toString()
        switch color {
        case "top": return .top
        case "center": return .center
        case "bottom": return .bottom
        default: return .center
        }
    }
    
    public var uiSpacing: CGFloat? {
        if let double = uiGetMember("spacing", "space").toDouble() {
            return CGFloat(double)
        }
        return nil
    }
    
    public var uiCornerRadius: CGFloat {
        if let double = uiGetMember("radius", "cornerRadius").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiBorderColor: Color? {
        let color = uiGetMember("borderColor").toString()
        if let color = Color(hexOrName: color) {
            return color
        } else {
            return nil
        }
    }
    
    public var uiBorderWidth: CGFloat {
        if let double = uiGetMember("borderWidth").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiPaddingTop: CGFloat {
        if let double = uiGetMember("paddingTop").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiPaddingLeft: CGFloat {
        if let double = uiGetMember("paddingLeft").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiPaddingBottom: CGFloat {
        if let double = uiGetMember("paddingBottom").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiPaddingRight: CGFloat {
        if let double = uiGetMember("paddingRight").toDouble() {
            return CGFloat(double)
        }
        return 0
    }
    
    public var uiFontSize: CGFloat {
        if let double = uiGetMember("fontSize").toDouble() {
            return CGFloat(double)
        }
        return 16
    }
    
    public var uiFont: Font {
        return .system(size: uiFontSize)
    }
    
    public var uiWidth: CGFloat? {
        if let double = uiGetMember("width").toDouble() {
            return CGFloat(double)
        }
        return nil
    }
    
    public var uiHeight: CGFloat? {
        if let double = uiGetMember("height").toDouble() {
            return CGFloat(double)
        }
        return nil
    }
    
    public var uiPlaceholder: String {
        uiGetMember("placeholder").toString()
    }
    
    public var uiAlignment: Alignment {
        let color = uiGetMember("align", "alignment").toString()
        switch color {
        case "topLeft": return .topLeading
        case "top": return .top
        case "topRight": return .topTrailing
        case "left": return .leading
        case "center": return .center
        case "right": return .trailing
        case "bottomLeft": return .bottomLeading
        case "bottom": return .bottom
        case "bottomRight": return .bottomTrailing
        default: return .center
        }
    }
    
    public var imageFill: Bool {
        switch uiGetMember("imageScaleMode").toString() {
        case "fill": return true
        case "fit": return false
        default: return true
        }
    }
    
    public func uiImage(model: ForceUpdateViewModel) -> Image? {
        if self.type == .null { return nil }
        let imageValue = uiGetMember("image").toString()
        if imageValue.count == 0 { return nil }
        if imageValue.hasPrefix("http://") || imageValue.hasPrefix("https://"),
            let url = URL(string: imageValue) {
            var img: Image?
            let group = DispatchGroup()
            group.enter()
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data,
                   let uiImage = UIImage(data: data) {
                    img = Image(uiImage: uiImage)
                        .resizable()
                }
                group.leave()
            }
            return img
        }
        else {
            let objects = imageValue.split(separator: "/")
            if objects.count == 2,
               objects[0].hasSuffix(".images") {
                if let imageFile = model.projectPackage?.findCodeFile(fileName: String(objects[0])) {
                    let model = ImageSetModel(openByFile: imageFile)
                    if let imageModel = model.images.first(where: { $0.imageName == objects[1] }) {
                        return Image(uiImage: imageModel.image).resizable()
                    }
                }
            }
        }
        return nil
    }
    
}

public class ForceUpdateViewModel: ObservableObject {
    @Published var updatee: Bool = false
    @Published var viewData: TreeObject
    @Published var rootData: TreeObject
    @Published var windowId: CCDUIObjectHandle
    @Published var projectPackage: CCDProject?
    
    public func firstComponentObject(treeProcess: TreeObjectProcess) -> CCDUIObjectHandle? {
        return treeProcess.rootNode(fromRootNode: rootData.id, findingCurrentNode: viewData.id) {
            $0.type == .kv && $0.uiType == "component"
        }
    }
    
    public init(viewData: TreeObject, andRoot data: TreeObject, andWindowId: CCDUIObjectHandle, project: CCDProject?) {
        self.viewData = viewData
        self.updatee = false
        self.rootData = data
        self.windowId = andWindowId
        self.projectPackage = project
    }
}

public struct CCDUIComponentWrapperUI: View {
    @ObservedObject var updater: ForceUpdateViewModel
    
    private func callAction() {
#if MAINAPP_TARGET
                guard let treeProcess = updater.viewData.process else { return }
                if let process = CCDUIWrapper.process[treeProcess.Pid],
                   let parserState = process.parserState,
                   let callee = treeProcess.getCallee(updater.viewData.uiAction),
                   let rootNode = updater.firstComponentObject(treeProcess: treeProcess) {
                    process.dispatchAsync {
                        ExpressionParseCalleeAutoTree2(parserState, callee, rootNode, updater.viewData.id)
                        process.dispatchRedrawAsync(updater.windowId)
                    }
                }
#endif
    }
    
    public var body: some View {
        
        let dataBindingText = Binding(get: {
            return updater.viewData.uiText
        }, set: {
            updater.viewData.uiText = $0
        })
        
        if updater.viewData.uiType == "label" || updater.viewData.uiType == "text" {
            Text(updater.viewData.uiText)
                .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
                .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                    leading: updater.viewData.uiPaddingLeft,
                                    bottom: updater.viewData.uiPaddingBottom,
                                    trailing: updater.viewData.uiPaddingRight))
                .foregroundColor(updater.viewData.uiColor)
                .background(updater.viewData.uiColorBg)
                .background(updater.viewData.uiImage(model: updater).scaledToFill())
                .font(updater.viewData.uiFont)
                .cornerRadius(updater.viewData.uiCornerRadius)
                .overlay((
                    RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                        .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
                ))
        }
        else if updater.viewData.uiType == "input" {
            TextField(updater.viewData.uiPlaceholder, text: dataBindingText) {
                self.callAction()
            }
                .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
                .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                    leading: updater.viewData.uiPaddingLeft,
                                    bottom: updater.viewData.uiPaddingBottom,
                                    trailing: updater.viewData.uiPaddingRight))
                .foregroundColor(updater.viewData.uiColor)
                .background(updater.viewData.uiColorBg)
                .background(updater.viewData.uiImage(model: updater).scaledToFill())
                .font(updater.viewData.uiFont)
                .cornerRadius(updater.viewData.uiCornerRadius)
                .overlay((
                    RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                        .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
                ))
        }
        else if updater.viewData.uiType == "spacer" {
            Spacer(minLength: updater.viewData.uiSpacing)
                .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
                .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                    leading: updater.viewData.uiPaddingLeft,
                                    bottom: updater.viewData.uiPaddingBottom,
                                    trailing: updater.viewData.uiPaddingRight))
        }
        else if updater.viewData.uiType == "component" {
            ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                subview in
                CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview, andRoot: updater.rootData, andWindowId: updater.windowId, project: updater.projectPackage))
            }
                .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
                .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
        }
        else if updater.viewData.uiType == "view" {
            ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                subview in
                CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                      andRoot: updater.rootData,
                                                                      andWindowId: updater.windowId,
                                                                      project: updater.projectPackage))
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "vstack" {
            VStack(alignment: updater.viewData.uiAlignmentH, spacing: updater.viewData.uiSpacing) {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "hstack" {
            HStack(alignment: updater.viewData.uiAlignmentV, spacing: updater.viewData.uiSpacing) {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "zstack" {
            ZStack(alignment: updater.viewData.uiAlignment) {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "list" {
            List {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
        }
        else if updater.viewData.uiType == "button" {
            Button(updater.viewData.uiText) {
                self.callAction()
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .font(updater.viewData.uiFont)
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "buttonArea" {
            Button(action: {
                self.callAction()
            }, label: {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            })
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "vscroll" {
            ScrollView(.vertical, showsIndicators: true) {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
        else if updater.viewData.uiType == "hscroll" {
            ScrollView(.horizontal, showsIndicators: true) {
                ForEach(updater.viewData.uiGetMember("sub").arrayObjects, id: \TreeObject.id) {
                    subview in
                    CCDUIComponentWrapperUI(updater: ForceUpdateViewModel(viewData: subview,
                                                                          andRoot: updater.rootData,
                                                                          andWindowId: updater.windowId,
                                                                          project: updater.projectPackage))
                }
            }
            .frame(width: updater.viewData.uiWidth, height: updater.viewData.uiHeight, alignment: updater.viewData.uiAlignment)
            .padding(EdgeInsets(top: updater.viewData.uiPaddingTop,
                                leading: updater.viewData.uiPaddingLeft,
                                bottom: updater.viewData.uiPaddingBottom,
                                trailing: updater.viewData.uiPaddingRight))
            .foregroundColor(updater.viewData.uiColor)
            .background(updater.viewData.uiColorBg)
            .background(updater.viewData.uiImage(model: updater).scaledToFill())
            .cornerRadius(updater.viewData.uiCornerRadius)
            .overlay((
                RoundedRectangle(cornerRadius: updater.viewData.uiCornerRadius)
                    .stroke(updater.viewData.uiBorderColor ?? Color(hexOrName: "systemFill")!, lineWidth: updater.viewData.uiBorderWidth)
            ))
        }
    }
}

