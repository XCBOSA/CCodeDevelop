//
//  TreeObjectWrapper.swift
//  CDEnvCInterp
//
//  Created by xcbosa on 2022/6/13.
//

import Foundation

public class TreeObjectWrapper: FrontendLifeCycle {
    
    public static var process = [Int32 : TreeObjectProcess]()
    
    public static func initWrapper() {
        sf_tree_json2tree = {
            pid, val in
            guard let process = self.process[pid] else { return -1 }
            if let str = NSString(cString: val, encoding: String.Encoding.utf8.rawValue) as? String {
                return process.allocateObject(fromString: str)
            }
            return process.nullValue
        }
        sf_tree_tree2json = {
            pid, handle in
            guard let process = self.process[pid] else { return nil }
            if let str = process.getObject(withId: handle)?.toString() {
                return NSString(string: str).cString(using: String.Encoding.utf8.rawValue)
            }
            return NSString().cString(using: String.Encoding.utf8.rawValue)
        }
        sf_tree_release = {
            pid, handle in
            guard let process = self.process[pid] else { return }
            process.getObject(withId: handle)?.reduceReference()
        }
        sf_tree_retain = {
            pid, handle in
            guard let process = self.process[pid] else { return }
            process.getObject(withId: handle)?.addReference()
        }
        sf_tree_referenceCount = {
            pid, handle in
            guard let process = self.process[pid] else { return -1 }
            let val = process.getObject(withId: handle)?.referenceCount ?? -1
            return Int32(val)
        }
        sf_tree_null = {
            pid in
            guard let process = self.process[pid] else { return -1 }
            return process.nullValue
        }
        sf_tree_path = {
            pid, handle, path in
            guard let process = self.process[pid] else { return -1 }
            if let node = process.getObject(withId: handle) {
                if let path = path, let path = NSString(cString: path, encoding: String.Encoding.utf8.rawValue) as? String {
                    return node.path(at: path)
                }
            }
            return process.nullValue
        }
        sf_tree_copy_value = {
            pid, left, right in
            guard let process = self.process[pid] else { return }
            if let left = process.getObject(withId: left) {
                left.assign(valueFromOther: right)
            }
        }
        sf_tree_copy_reference = {
            pid, leftParent, leftMember, right in
            guard let process = self.process[pid] else { return }
            guard let leftMemberName = NSString(cString: leftMember, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            if let leftParentObject = process.getObject(withId: leftParent) {
                leftParentObject.kvSet(right, forKey: leftMemberName)
            }
        }
        sf_tree_set_int64 = {
            pid, left, right in
            guard let process = self.process[pid] else { return }
            if let left = process.getObject(withId: left) {
                left.assign(toIntValue: Int64(right))
            }
        }
        sf_tree_set_string = {
            pid, left, right in
            guard let process = self.process[pid] else { return }
            guard let right = NSString(cString: right, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            if let left = process.getObject(withId: left) {
                left.assign(toStringValue: right)
            }
        }
        sf_tree_get_type = {
            pid, handle in
            guard let process = self.process[pid] else { return -1 }
            return Int32(process.getObject(withId: handle)?.type.rawValue ?? -1)
        }
        sf_tree_get_int64 = {
            pid, handle in
            guard let process = self.process[pid] else { return -1 }
            return Int(process.getObject(withId: handle)?.intValue ?? 0)
        }
        sf_tree_get_string = {
            pid, handle in
            guard let process = self.process[pid] else { return nil }
            var str = ""
            if let object = process.getObject(withId: handle) {
                if object.type == .valueString {
                    if let o = object.stringValue {
                        str = o
                    } else {
                        str = ""
                    }
                } else {
                    str = object.toString()
                }
            }
            return (str as NSString).cString(using: String.Encoding.utf8.rawValue)
        }
        sf_tree_set_reference_int64 = {
            pid, leftParent, leftMember, right in
            guard let process = self.process[pid] else { return }
            guard let leftMemberName = NSString(cString: leftMember, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            let newNode = process.allocateObject(Int64(right))
            process.getObject(withId: leftParent)?.kvSet(newNode, forKey: leftMemberName, addReferenceCountForGivenValue: false)
        }
        sf_tree_set_reference_string = {
            pid, leftParent, leftMember, right in
            guard let process = self.process[pid] else { return }
            guard let leftMemberName = NSString(cString: leftMember, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            guard let rightValue = NSString(cString: right, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            let newNode = process.allocateObject(rightValue)
            process.getObject(withId: leftParent)?.kvSet(newNode, forKey: leftMemberName, addReferenceCountForGivenValue: false)
        }
        sf_tree_enumerator = {
            pid, handle in
            guard let process = self.process[pid] else { return nil }
            if let obj = process.getObject(withId: handle) {
                switch obj.type {
                case .kv:
                    guard let kvValue = obj.kvValue else { return nil }
                    var strbuf = ""
                    for it in kvValue {
                        strbuf.append(it.0)
                        strbuf.append(";")
                    }
                    if (strbuf.last == ";") {
                        strbuf.removeLast()
                    }
                    return (strbuf as NSString).cString(using: String.Encoding.utf8.rawValue)
                case .array:
                    guard let arrayValue = obj.arrayValue else { return nil }
                    var strbuf = ""
                    for id in 0..<arrayValue.count {
                        strbuf.append("\(id)")
                        strbuf.append(";")
                    }
                    if (strbuf.last == ";") {
                        strbuf.removeLast()
                    }
                    return (strbuf as NSString).cString(using: String.Encoding.utf8.rawValue)
                default: return nil
                }
            }
            return nil
        }
        sf_tree_typeof = {
            pid, handle in
            guard let process = self.process[pid] else { return Int32(TreeObjectType.null.rawValue) }
            if let obj = process.getObject(withId: handle) {
                return Int32(obj.type.rawValue)
            }
            return Int32(TreeObjectType.null.rawValue)
        }
        sf_tree_arrayLen = {
            pid, handle in
            guard let process = self.process[pid] else { return -1 }
            if let obj = process.getObject(withId: handle) {
                return Int32(obj.arrayValue?.count ?? 0)
            }
            return 0
        }
        sf_tree_get_double = {
            pid, handle in
            guard let process = self.process[pid] else { return -1 }
            if let object = process.getObject(withId: handle) {
                if object.type == .valueDouble {
                    return object.doubleValue ?? 0
                }
            }
            return 0
        }
        sf_tree_set_double = {
            pid, handle, value in
            guard let process = self.process[pid] else { return }
            if let object = process.getObject(withId: handle) {
                if object.type == .valueDouble {
                    object.doubleValue = value
                }
            }
        }
        sf_tree_set_reference_double = {
            pid, handle, member, value in
            guard let process = self.process[pid] else { return }
            guard let leftMemberName = NSString(cString: member, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            let newNode = process.allocateObject(value)
            process.getObject(withId: handle)?.kvSet(newNode, forKey: leftMemberName, addReferenceCountForGivenValue: false)
        }
        sf_tree_array_append = {
            pid, Handle, ToAddHandle in
            guard let process = self.process[pid] else { return }
            process.getObject(withId: Handle)?.arrayAppend(ToAddHandle)
        }
        sf_tree_array_remove = {
            pid, Handle, Index in
            guard let process = self.process[pid] else { return }
            process.getObject(withId: Handle)?.arrayRemove(at: Int(Index))
        }
        sf_http_send = {
            pid, url, method, paramHandle, headerHandle in
#if MAINAPP_TARGET
            guard let pmprocess = PMWrapper.process[pid] else { return -1 }
#endif
            guard let process = self.process[pid] else { return -1 }
            guard let url = NSString(cString: url, encoding: String.Encoding.utf8.rawValue) as? String, let url = URL(string: url) else { return -1 }
            let param = process.getObject(withId: paramHandle) ?? process.getObject(withId: process.nullValue)!
            let header = process.getObject(withId: headerHandle) ?? process.getObject(withId: process.nullValue)!
            var urlReq = URLRequest(url: url)
            urlReq.httpBody = param.toData()
            urlReq.httpMethod = method == 0 ? "post" : "get"
            for it in header.kvValue ?? [] {
                let value = process.getObject(withId: it.1) ?? process.getObject(withId: process.nullValue)!
                var str = ""
                if value.type == .valueString {
                    if let o = value.stringValue {
                        str = o
                    } else {
                        str = ""
                    }
                } else {
                    str = value.toString()
                }
                urlReq.addValue(str, forHTTPHeaderField: it.0)
            }
            var isFinish = false
            var resultTree: TreeObjectHandle?
            URLSession.shared.dataTask(with: urlReq) {
                data, resp, err in
                if isFinish { return }
                resultTree = process.allocateObject([(String, TreeObjectHandle)]())
                process.getObject(withId: resultTree!)?.kvSet(process.allocateObject(Int64(err == nil ? 1 : 0)), forKey: "isSuccess", addReferenceCountForGivenValue: false)
                if let err = err {
                    process.getObject(withId: resultTree!)?.kvSet(process.allocateObject(err.localizedDescription), forKey: "error", addReferenceCountForGivenValue: false)
                    isFinish = true
                    return
                }
                if let resp = resp as? HTTPURLResponse {
                    if let header = process.allocateObject(fromNativeObject: resp.allHeaderFields) {
                        process.getObject(withId: resultTree!)?.kvSet(header, forKey: "header", addReferenceCountForGivenValue: false)
                    }
                }
                if let data = data {
                    let obj = process.allocateObject(fromString: String(data: data, encoding: .utf8) ?? "")
                    process.getObject(withId: resultTree!)?.kvSet(obj, forKey: "data")
                }
                isFinish = true
            }.resume()
            while !isFinish {
#if MAINAPP_TARGET
                if pmprocess.cdenvcInstance.pointee.pthread_cancel_p == 1 {
                    isFinish = true
                    break
                }
#endif
                usleep(1000)
            }
            return resultTree ?? process.nullValue
        }
        sf_tree_register_callee = {
            Pid, Callee in
            guard let process = self.process[Pid] else { return -1 }
            return Int32(process.registerCallee(Callee))
        }
        sf_tree_add_json = {
            Pid, OperateHandle, ToAddJson in
            guard let process = self.process[Pid] else { return }
            guard let ToAddJson = NSString(cString: ToAddJson, encoding: String.Encoding.utf8.rawValue) as? String else { return }
            guard let OperateTree = process.getObject(withId: OperateHandle) else { return }
            let partTree = process.allocateObject(fromString: ToAddJson)
            if let partTree = process.getObject(withId: partTree) {
                if partTree.type != .kv {
                    return
                }
                for sub in (partTree.kvValue ?? []) {
                    OperateTree.kvSet(sub.1, forKey: sub.0)
                }
                partTree.reduceReference()
            }
        }
    }
    
    public class func setup(forPid pid: Int32) {
        if process[pid] != nil {
            return
        }
        process[pid] = TreeObjectProcess(pid)
    }
    
    public class func cleanUp(forPid pid: Int32) {
        process.removeValue(forKey: pid)?.deallocateProcess()
    }
    
}
