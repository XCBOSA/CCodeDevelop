//
//  TreeObjectProcess.swift
//  CDEnvCInterp
//
//  Created by xcbosa on 2022/6/13.
//

import Foundation

public class TreeObjectProcess {
    
    private var objects = [TreeObjectHandle : TreeObject]()
    private var callees = [FuncDef]()
    private var freeList = [TreeObjectHandle]()
    private var maker: TreeObjectHandle = 0
    
    public private(set) var Pid: Int32 = 0
    
    public init(_ pid: Int32) {
        self.Pid = pid
    }
    
    public lazy var nullValue: TreeObjectHandle = {
        let handle = allocateId()
        let nullValue = TreeObject(aNullValue: handle, ofProcess: self)
        objects[handle] = nullValue
        return handle
    }()
    
    public lazy var nullValueObject: TreeObject = {
        getObject(withId: nullValue)!
    }()
    
    public func registerCallee(_ funcDef: FuncDef) -> Int {
        callees.append(funcDef)
        return callees.count - 1
    }
    
    public func getCallee(_ index: Int) -> FuncDef? {
        if index >= 0 && index < callees.count {
            return callees[index]
        }
        return nil
    }
    
    private func allocateId() -> TreeObjectHandle {
        if !freeList.isEmpty {
            return freeList.removeLast()
        }
        let newId = maker
        maker += 1
        return newId
    }
    
    private func freeId(_ id: TreeObjectHandle) {
        freeList.append(id)
    }
    
    public func getObject(withId id: TreeObjectHandle) -> TreeObject? {
        return objects[id]
    }
    
    public func allocateObject(_ value: [(String, TreeObjectHandle)]) -> TreeObjectHandle {
        let handle = allocateId()
        let object = TreeObject(value, aKvNodeValue: handle, ofProcess: self)
        objects[handle] = object
        return handle
    }
    
    public func allocateObject(_ value: [TreeObjectHandle]) -> TreeObjectHandle {
        let handle = allocateId()
        let object = TreeObject(value, anArrayValue: handle, ofProcess: self)
        objects[handle] = object
        return handle
    }
    
    public func allocateObject(_ value: Int64) -> TreeObjectHandle {
        let handle = allocateId()
        let object = TreeObject(value, anIntValue: handle, ofProcess: self)
        objects[handle] = object
        return handle
    }
    
    public func allocateObject(_ value: String) -> TreeObjectHandle {
        let handle = allocateId()
        let object = TreeObject(value, aStringValue: handle, ofProcess: self)
        objects[handle] = object
        return handle
    }
    
    public func allocateObject(_ value: Double) -> TreeObjectHandle {
        let handle = allocateId()
        let object = TreeObject(value, aDoubleValue: handle, ofProcess: self)
        objects[handle] = object
        return handle
    }
    
    private func kvValuePut(_ value: TreeObjectHandle, key: String, kvValue: inout [(String, TreeObjectHandle)]) {
        if let pairId = kvValue.firstIndex(where: { $0.0 == key }) {
            kvValue[pairId] = (key, value)
        } else {
            kvValue.append((key, value))
        }
    }
    
    private func kvValueGet(key: String, kvValue: inout [(String, TreeObjectHandle)]) -> TreeObjectHandle? {
        kvValue.first { $0.0 == key }?.1
    }
    
    private func allocateObject(fromNativeObject nativeObject: Any, fallIdRecorder recorder: inout [TreeObjectHandle]) throws -> TreeObjectHandle {
        let handle = allocateId()
        recorder.append(handle)
        if let dictionary = nativeObject as? [String : Any?] {
            var treeDictionary = [(String, TreeObjectHandle)]()
            for key in dictionary.keys {
                if let oriValue = dictionary[key], let v = oriValue {
                    kvValuePut(try allocateObject(fromNativeObject: v, fallIdRecorder: &recorder), key: key, kvValue: &treeDictionary)
                } else {
                    kvValuePut(nullValue, key: key, kvValue: &treeDictionary)
                }
            }
            let tree = TreeObject(treeDictionary, aKvNodeValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let array = nativeObject as? [Any?] {
            var treeArray = [TreeObjectHandle]()
            for it in array {
                if let it = it {
                    try treeArray.append(allocateObject(fromNativeObject: it, fallIdRecorder: &recorder))
                } else {
                    treeArray.append(nullValue)
                }
            }
            let tree = TreeObject(treeArray, anArrayValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let int = nativeObject as? Int {
            let tree = TreeObject(Int64(int), anIntValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let int = nativeObject as? Int32 {
            let tree = TreeObject(Int64(int), anIntValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let int = nativeObject as? Int64 {
            let tree = TreeObject(int, anIntValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let string = nativeObject as? String {
            let magic = ":::::tree_handle_reference:::::"
            if string.hasPrefix(magic) {
                let referenceId = string.substring(from: string.index(string.startIndex, offsetBy: magic.count))
                if let handle = Int32(referenceId) {
                    return handle
                }
            }
            let tree = TreeObject(string, aStringValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        if let double = nativeObject as? Double {
            let tree = TreeObject(double, aDoubleValue: handle, ofProcess: self)
            objects[handle] = tree
            return handle
        }
        throw NSError()
    }
    
    public func allocateObject(fromNativeObject nativeObject: Any) -> TreeObjectHandle? {
        var recorder = [TreeObjectHandle]()
        do {
            return try allocateObject(fromNativeObject: nativeObject, fallIdRecorder: &recorder)
        } catch {
            for it in recorder {
                freeId(it)
                objects.removeValue(forKey: it)
            }
            return nil
        }
    }
    
    public func allocateObject(fromString string: String) -> TreeObjectHandle {
        if let jsonObject = try? JSONSerialization.jsonObject(with: string.replacingOccurrences(of: "'", with: "\"").data(using: .utf8) ?? Data(count: 0)) {
            return allocateObject(fromNativeObject: jsonObject) ?? allocateObject(string)
        }
        let lmagic = "\":::::tree_handle_reference:::::"
        if string.hasPrefix(lmagic) {
            var cs = string.substring(from: string.index(string.startIndex, offsetBy: lmagic.count)).description
            if cs.hasSuffix("\"") {
                cs.removeLast()
            }
            if let int32 = Int32(cs) {
                return int32
            }
        }
        return allocateObject(string)
    }
    
    internal func markChanges() {
        
    }
    
    func deallocateProcess() {
        objects.removeAll()
        callees.removeAll()
        freeList.removeAll()
    }
    
    public func make(current: TreeObjectHandle, linkWithParent parent: TreeObjectHandle) {
        guard let object = getObject(withId: current) else { return }
        switch object.type {
        case .null:
            return
        case .array:
            for it in object.arrayValue ?? [] {
                make(current: it, linkWithParent: current)
            }
            break
        case .kv:
            for it in object.kvValue ?? .init() {
                make(current: it.1, linkWithParent: current)
            }
            break
        case .valueInt:
            break
        case .valueString:
            break
        case .valueDouble:
            break
        }
        object.parentHandle = parent
    }
    
    public func rootNode(fromRootNode rootNode: TreeObjectHandle,
                         findingCurrentNode currentNode: TreeObjectHandle,
                         by predicate: ((TreeObject) -> Bool)) -> TreeObjectHandle? {
        guard let currentObject = getObject(withId: currentNode) else { return nil }
        if predicate(currentObject) { return currentNode }
        make(current: rootNode, linkWithParent: -1)
        var object = currentObject
        while let parent = object.parentHandle {
            if let parentObject = getObject(withId: parent) {
                if parentObject.type == .null { return nil }
                if predicate(parentObject) {
                    return parentObject.id
                }
                object = parentObject
            } else {
                return nil
            }
        }
        return nil
    }
    
    public func firstNode(fromRootNode rootNode: TreeObjectHandle,
                          by predicate: ((TreeObject) -> Bool)) -> TreeObjectHandle? {
        guard let currentObject = getObject(withId: rootNode) else { return nil }
        if predicate(currentObject) { return rootNode }
        switch currentObject.type {
        case .kv:
            for it in currentObject.kvValue ?? [] {
                if let node = firstNode(fromRootNode: it.1, by: predicate) {
                    return node
                }
            }
        case .array:
            for it in currentObject.arrayValue ?? [] {
                if let node = firstNode(fromRootNode: it, by: predicate) {
                    return node
                }
            }
        case .valueInt:
            break
        case .valueString:
            break
        case .null:
            break
        case .valueDouble:
            break
        }
        return nil
    }
    
    /// 直接删除对象，不考虑子对象
    /// - Parameter handle: 对象Handle
    func deleteObjectDirectly(_ handle: TreeObjectHandle) {
        objects.removeValue(forKey: handle)
        freeId(handle)
    }
    
}

