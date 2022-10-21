//
//  TreeObject.swift
//  CDEnvCInterp
//
//  Created by xcbosa on 2022/6/13.
//

import Foundation

public typealias TreeObjectHandle = Int32

/// 表示树节点对象的类型
public enum TreeObjectType: Int {
    case kv = 3
    case array = 4
    case valueInt = 0
    case valueString = 1
    case null = 2
    case valueDouble = 5
}

/// 树的一个节点对象，可以是KV对，可以是数组，可以是树叶（Int、字符串）
public class TreeObject {
    
    public private(set) weak var process: TreeObjectProcess?
    public private(set) var id: TreeObjectHandle
    public private(set) var type: TreeObjectType
    
    public var intValue: Int64?
    public var stringValue: String?
    public var kvValue: [(String, TreeObjectHandle)]?
    public var arrayValue: [TreeObjectHandle]?
    public var doubleValue: Double?
    public private(set) var referenceCount: Int
    
    public var parentHandle: TreeObjectHandle?
    
    private func kvValuePut(_ value: TreeObjectHandle, to key: String) {
        if let pairId = kvValue?.firstIndex(where: { $0.0 == key }) {
            kvValue![pairId] = (key, value)
        } else {
            kvValue?.append((key, value))
        }
    }
    
    private func kvValueGet(key: String) -> TreeObjectHandle? {
        kvValue?.first { $0.0 == key }?.1
    }
    
    public init(_ value: [(String, TreeObjectHandle)],
                aKvNodeValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess) {
        self.id = id
        self.type = .kv
        self.process = process
        self.intValue = nil
        self.stringValue = nil
        self.doubleValue = nil
        self.kvValue = value
        self.arrayValue = nil
        self.referenceCount = 1
    }
    
    public init(_ value: [TreeObjectHandle],
                anArrayValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess) {
        self.id = id
        self.type = .array
        self.process = process
        self.intValue = nil
        self.stringValue = nil
        self.doubleValue = nil
        self.kvValue = nil
        self.arrayValue = value
        self.referenceCount = 1
    }
    
    public init(_ value: Int64,
                anIntValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess) {
        self.id = id
        self.type = .valueInt
        self.process = process
        self.intValue = value
        self.stringValue = nil
        self.doubleValue = nil
        self.kvValue = nil
        self.arrayValue = nil
        self.referenceCount = 1
    }
    
    public init(_ value: String,
                aStringValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess) {
        self.id = id
        self.type = .valueString
        self.process = process
        self.intValue = nil
        self.stringValue = value
        self.doubleValue = nil
        self.kvValue = nil
        self.arrayValue = nil
        self.referenceCount = 1
    }
    
    public init(_ value: Double,
                aDoubleValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess) {
        self.id = id
        self.type = .valueDouble
        self.process = process
        self.intValue = nil
        self.stringValue = nil
        self.doubleValue = value
        self.kvValue = nil
        self.arrayValue = nil
        self.referenceCount = 1
    }
    
    public init(aNullValue id: TreeObjectHandle,
                ofProcess process: TreeObjectProcess?) {
        self.id = id
        self.type = .null
        self.process = process
        self.intValue = nil
        self.stringValue = nil
        self.doubleValue = nil
        self.kvValue = nil
        self.arrayValue = nil
        self.referenceCount = Int.max
    }
    
    public func getSubObjects() -> [TreeObjectHandle] {
        if self.type == .array {
            return self.arrayValue ?? []
        }
        if self.type == .kv {
            return self.kvValue?.map({ t in t.1 }) ?? []
        }
        return []
    }
    
    public func addReference() {
        if (self.referenceCount == Int.max) {
            return
        }
        self.referenceCount += 1
    }
    
    public func reduceReference() {
        if (self.referenceCount == Int.max) {
            return
        }
        self.referenceCount -= 1
        if self.referenceCount <= 0 {
            process?.deleteObjectDirectly(self.id)
            let subObjects = getSubObjects()
            for it in subObjects {
                process?.getObject(withId: it)?.reduceReference()
            }
        }
    }
    
    public func kvGet(_ key: String) -> TreeObjectHandle {
        guard let process = process else { return -1 }
        if let val = kvValueGet(key: key) {
            return val
        }
        if let arrayValue = arrayValue, let intKey = Int(key) {
            if intKey >= 0 && intKey < arrayValue.count {
                return arrayValue[intKey]
            }
        }
        return process.nullValue
    }
    
    public func kvSet(_ value: TreeObjectHandle, forKey key: String, addReferenceCountForGivenValue addRef: Bool = true) {
        guard let process = process else { return }
        if kvValue != nil {
            let originalValue = kvValueGet(key: key)
            kvValuePut(value, to: key)
            if addRef {
                process.getObject(withId: value)?.addReference()
            }
            if let originalValue = originalValue {
                process.getObject(withId: originalValue)?.reduceReference()
            }
            return
        }
        if arrayValue != nil, let intKey = Int(key) {
            if intKey >= 0 && intKey < arrayValue!.count {
                let originalValue = arrayValue![intKey]
                arrayValue![intKey] = value
                if addRef {
                    process.getObject(withId: value)?.addReference()
                }
                process.getObject(withId: originalValue)?.reduceReference()
                return
            }
        }
    }
    
    public func arrayGet(_ index: Int) -> TreeObjectHandle {
        guard let process = process else { return -1 }
        if let arrayValue = arrayValue {
            if index >= 0 && index < arrayValue.count {
                return arrayValue[index]
            }
        }
        return process.nullValue
    }
    
    public func arraySet(_ value: TreeObjectHandle, forIndex index: Int) {
        guard let process = process else { return }
        if arrayValue != nil {
            if index >= 0 && index < arrayValue!.count {
                let originalValue = arrayValue![index]
                arrayValue![index] = value
                process.getObject(withId: value)?.addReference()
                process.getObject(withId: originalValue)?.reduceReference()
            } else if index == arrayValue!.count {
                arrayValue!.append(value)
                process.getObject(withId: value)?.addReference()
            }
        }
    }
    
    public func arrayAppend(_ value: TreeObjectHandle) {
        guard let process = process else { return }
        if arrayValue != nil {
            arrayValue!.append(value)
            process.getObject(withId: value)?.addReference()
        }
    }
    
    public func arrayRemove(at index: Int) {
        guard let process = process else { return }
        if arrayValue != nil {
            if index >= 0 && index < arrayValue!.count {
                process.getObject(withId: arrayValue!.remove(at: index))?.reduceReference()
            }
        }
    }
    
    public func toNativeType() -> Any? {
        guard let process = process else { return nil }
        switch self.type {
        case .kv:
            guard let kvValue = kvValue else {
                return nil
            }
            var kvPair = [String : Any?]()
            for pair in kvValue {
                if let object = process.getObject(withId: pair.1) {
                    kvPair[pair.0] = object.toNativeType()
                }
            }
            return kvPair
        case .array:
            guard let arrayValue = arrayValue else {
                return nil
            }
            var array = [Any?]()
            for it in arrayValue {
                if let object = process.getObject(withId: it) {
                    array.append(object.toNativeType())
                }
            }
            return array
        case .valueInt:
            return self.intValue
        case .valueString:
            return self.stringValue
        case .null:
            return nil
        case .valueDouble:
            return self.doubleValue
        }
    }
    
    public func toData() -> Data {
        guard let val = toNativeType() else {
            return Data(count: 0)
        }
        if let val = val as? [String : Any?] {
            return (try? JSONSerialization.data(withJSONObject: val, options: .prettyPrinted)) ?? Data(count: 0)
        }
        if let val = val as? [Any?] {
            return (try? JSONSerialization.data(withJSONObject: val, options: .prettyPrinted)) ?? Data(count: 0)
        }
        if let val = val as? String {
            return val.data(using: .utf8) ?? Data(count: 0)
        }
        if let val = val as? Int {
            return val.description.data(using: .utf8) ?? Data(count: 0)
        }
        if let val = val as? Int32 {
            return val.description.data(using: .utf8) ?? Data(count: 0)
        }
        if let val = val as? Int64 {
            return val.description.data(using: .utf8) ?? Data(count: 0)
        }
        if let val = val as? Double {
            return val.description.data(using: .utf8) ?? Data(count: 0)
        }
        return Data(count: 0)
    }
    
    public func toString() -> String {
        return String(data: toData(), encoding: .utf8) ?? ""
    }
    
    public func toDouble() -> Double? {
        switch type {
        case .kv:
            return nil
        case .array:
            return nil
        case .valueInt:
            return Double(intValue ?? 0)
        case .valueString:
            if let double = Double(stringValue ?? "") {
                return double
            }
            return nil
        case .null:
            return nil
        case .valueDouble:
            return doubleValue ?? 0
        }
    }
    
    public func path(at string: String) -> TreeObjectHandle {
        guard let process = process else { return -1 }
        var left = "", right = "", isLeft = true
        for it in string {
            if it == "." {
                if isLeft {
                    isLeft = false
                } else {
                    right.append(it)
                }
            } else if it == "[" {
                isLeft = false
                right.append(it)
            } else {
                if isLeft {
                    left.append(it)
                } else {
                    right.append(it)
                }
            }
        }
        if isLeft {
            // 叶子
            return kvGet(left)
        }
        if left.count == 0 {
            // 数组
            var step = 0
            var index = ""
            var then = ""
            for it in right {
                if step == 0 {
                    if it == "[" {
                        step = 1
                    }
                }
                else if step == 1 {
                    if it == "]" {
                        step = 2
                    } else {
                        index.append(it)
                    }
                }
                else if step == 2 {
                    if it == "." {
                        step = 3
                    }
                }
                else if step == 3 {
                    then.append(it)
                }
            }
            if ![2, 3].contains(step) {
                return process.nullValue
            }
            if let intIndex = Int(index) {
                let queryValue = self.arrayGet(intIndex)
                if then.isEmpty {
                    return queryValue
                }
                if let obj = process.getObject(withId: queryValue) {
                    return obj.path(at: then)
                }
            }
        }
        if left.count > 0 {
            let handle = self.kvGet(left)
            if let obj = process.getObject(withId: handle) {
                return obj.path(at: right)
            }
        }
        return process.nullValue
    }
    
    public func assign(toIntValue value: Int64) {
        guard let process = process else { return }
        let subObjects = self.getSubObjects().map { process.getObject(withId: $0) }
        self.type = .valueInt
        self.intValue = value
        self.stringValue = nil
        self.kvValue = nil
        self.arrayValue = nil
        subObjects.forEach { $0?.reduceReference() }
    }
    
    public func assign(toStringValue value: String) {
        guard let process = process else { return }
        let subObjects = self.getSubObjects().map { process.getObject(withId: $0) }
        self.type = .valueString
        self.intValue = nil
        self.stringValue = value
        self.kvValue = nil
        self.arrayValue = nil
        subObjects.forEach { $0?.reduceReference() }
    }
    
    public func assign(valueFromOther handle: TreeObjectHandle) {
        guard let process = process else { return }
        guard let object = process.getObject(withId: handle) else {
            return assign(valueFromOther: process.nullValue)
        }
        let subObjects = self.getSubObjects().map { process.getObject(withId: $0) }
        
        self.type = object.type
        self.intValue = nil
        self.stringValue = nil
        self.kvValue = nil
        self.arrayValue = nil
        
        switch object.type {
        case .valueInt:
            self.intValue = object.intValue ?? 0
            break
        case .valueString:
            self.stringValue = object.stringValue ?? ""
            break
        case .kv:
            self.kvValue = [(String, TreeObjectHandle)]()
            object.kvValue?.forEach {
                kvValuePut($0.1, to: $0.0)
                process.getObject(withId: $0.1)?.addReference()
            }
            break
        case .array:
            self.arrayValue = [TreeObjectHandle]()
            object.arrayValue?.forEach {
                self.arrayValue?.append($0)
                process.getObject(withId: $0)?.addReference()
            }
            break
        case .null: break
        case .valueDouble:
            self.doubleValue = object.doubleValue ?? 0
            break
        }
        
        subObjects.forEach { $0?.reduceReference() }
    }
    
}
