//
//  APIFetcher.swift
//  C Code Develop
//
//  Created by xcbosa on 2022/6/20.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import Foundation

public typealias ProvideRootMarkdownBlock = () -> [APIDocFileCollectionModel]

public protocol APIDocMarkdownGenerable: AnyObject {
    func generateMarkdown() -> String
    var navigationItemTitle: String { get }
    var shareURL: URL? { get }
    var collectionPath: String { get }
    var linkPathPrefix: String { get set }
    var language: ElementDefs.SupportedLanguage { get set }
    var provideRootMarkdownBlock: ProvideRootMarkdownBlock? { get set }
}

extension APIDocMarkdownGenerable {
    
    public func getCollectionName() -> String {
        switch collectionPath {
        case "stdc": return "APIDoc.StandardCHeaderName".apiDocLocalized(language)
        case "cdenvc": return "APIDoc.ExtendedCHeaderName".apiDocLocalized(language)
        default: return collectionPath
        }
    }
    
}

public struct FunctionParamDef {
    public var name: String
    public var type: String
    public var description: String
}

public extension APIDocMarkdownGenerable {
    
    var cKeyWordsExtended: [String] {
        [
            "break", "case", "char", "continue", "default", "do", "double", "else", "extern", "false", "FALSE", "float", "for", "goto", "if", "int", "long", "register", "const", "return", "short", "signed", "sizeof", "struct", "null", "static", "switch", "true", "TRUE", "typedef", "unsigned", "void", "while", "include", "define", "builtin", "unsigned int", "unsigned long", "long long", "unsigned char", "unsigned short", "__Macro", "const int", "const long", "const float", "const double", "Never", "const void", "const char", "const short", "const unsigned char", "const unsigned short", "const unsigned int", "const unsigned long", "union"
        ]
    }
    
    func buildLinkPath(withMemberName name: String?, inFile file: String, inCollection collection: String) -> String {
        if let name = name {
            return "\(linkPathPrefix)/\(collection)/\(file)/\(name)"
        } else {
            return "\(linkPathPrefix)/\(collection)/\(file)"
        }
    }
    
    func color(token str: String, drawFunctionName: Bool, drawTypeName: Bool, drawStructName: Bool, drawVariableName: Bool) -> String {
        var pstr = str
        while pstr.first == "*" { pstr.removeFirst() }
        while pstr.last == "*" { pstr.removeLast() }
        let colorTable = CLangColorTable.getColorTable()
        if cKeyWordsExtended.contains(pstr) {
            return "<font color=\"\(colorTable.getKeywordColor().hexString)\">\(str)</font>"
        }
        var files = [APIDocFileCollectionModel]()
        if let rootArray = provideRootMarkdownBlock?() {
            files = rootArray
        } else {
            print("[APIDoc] provideRootMarkdownBlock = nil, Using \"Current\"")
            if let self = self as? APIDocFileModel {
                files.append(APIDocFileCollectionModel([self], withCollectionTitle: "Current", andCollectionStoragePath: "Current"))
            }
        }
        
        for it in files {
            for doc in it.files {
                if doc.fileName.hasSuffix(".h") {
                    let items = doc.items
                    if drawFunctionName,
                       items.filter({ $0.type == .functionDefintion }).contains(where: { $0.name == pstr }) {
                        return "<font color=\"\(colorTable.getMethodContentColor().hexString)\"><a href='\(buildLinkPath(withMemberName: pstr, inFile: doc.fileName, inCollection: it.collectionStoragePath))' style='color:\(colorTable.getMethodContentColor().hexString)'>\(str)</a></font>"
                    }
                    if drawTypeName {
                        if pstr.hasPrefix("struct ") {
                            if items.filter({ $0.type == .structDefinition }).contains(where: { $0.name == pstr.split(separator: " ").last?.description ?? "" }) {
                                return "<font color=\"\(colorTable.getStructContentColor().hexString)\"><a href='\(buildLinkPath(withMemberName: pstr.split(separator: " ").last?.description ?? "", inFile: doc.fileName, inCollection: it.collectionStoragePath))' style='color:\(colorTable.getStructContentColor().hexString)'>\(str)</a></font>"
                            }
                        }
                        if items.filter({ $0.type == .typeDefinition }).contains(where: { $0.name == pstr }) {
                            return "<font color=\"\(colorTable.getTypeContentColor().hexString)\"><a href='\(buildLinkPath(withMemberName: pstr, inFile: doc.fileName, inCollection: it.collectionStoragePath))' style='color:\(colorTable.getTypeContentColor().hexString)'>\(str)</a></font>"
                        }
                    }
                    if drawStructName,
                       items.filter({ $0.type == .structDefinition }).contains(where: { $0.name == pstr }) {
                        return "<font color=\"\(colorTable.getStructContentColor().hexString)\"><a href='\(buildLinkPath(withMemberName: pstr, inFile: doc.fileName, inCollection: it.collectionStoragePath))' style='color:\(colorTable.getStructContentColor().hexString)'>\(str)</a></font>"
                    }
                    if drawVariableName,
                       items.filter({ $0.type == .variableDefinition }).contains(where: { $0.name == pstr }) {
                        return "<font color=\"\(colorTable.getUserDefinedContentColor().hexString)\"><a href='\(buildLinkPath(withMemberName: pstr, inFile: doc.fileName, inCollection: it.collectionStoragePath))' style='color:\(colorTable.getUserDefinedContentColor().hexString)'>\(str)</a></font>"
                    }
                }
            }
        }
        
        return str
    }
    
    func drawFunc(_ token: String) -> String { color(token: token, drawFunctionName: true, drawTypeName: false, drawStructName: false, drawVariableName: false) }
    func drawType(_ token: String) -> String { color(token: token, drawFunctionName: false, drawTypeName: true, drawStructName: false, drawVariableName: false) }
    func drawStruct(_ token: String) -> String { color(token: token, drawFunctionName: false, drawTypeName: false, drawStructName: true, drawVariableName: false) }
    func drawVariable(_ token: String) -> String { color(token: token, drawFunctionName: false, drawTypeName: false, drawStructName: false, drawVariableName: true) }
    
    func getFuncParamDef(_ def: ElementDefs) -> [FunctionParamDef] {
        let paramArray = def.functionArgs.split(separator: ",").filter({ !$0.isEmpty })
        var defs = [FunctionParamDef]()
        var unnameValIndex = 0
        let peekUnnameIndex = { () -> String in
            unnameValIndex += 1
            return "arg\(unnameValIndex)"
        }
        for it in paramArray {
            let paramDef = it.trimmingCharacters(in: .whitespacesAndNewlines)
            let paramDefArray = paramDef.split(separator: " ").filter({ !$0.isEmpty })
            var paramType = ""
            var paramName = ""
            for id in 0..<paramDefArray.count {
                let it = paramDefArray[id]
                if id != paramDefArray.count - 1 {
                    paramType.append(it + " ")
                } else {
                    paramName = it.description
                }
            }
            paramType = paramType.trimmingCharacters(in: .whitespacesAndNewlines)
            paramName = paramName.trimmingCharacters(in: .whitespacesAndNewlines)
            if paramType.isEmpty {
                paramType = paramName
                paramName = peekUnnameIndex()
            }
            while paramType.last == "*" {
                paramType.removeLast()
                paramName = "*" + paramName
            }
            var realParamName = paramName
            while realParamName.first == "*" { realParamName.removeFirst() }
            let comment = def.getLocalizedComment(withKey: realParamName, language: language)
            defs.append(FunctionParamDef(name: paramName, type: paramType, description: comment))
        }
        return defs
    }
    
    func drawParamTable(_ str: String) -> String {
        let paramArray = str.split(separator: ",").filter({ !$0.isEmpty })
        var strbuf = ""
        var unnameValIndex = 0
        let peekUnnameIndex = { () -> String in
            unnameValIndex += 1
            return "arg\(unnameValIndex)"
        }
        for it in paramArray {
            let paramDef = it.trimmingCharacters(in: .whitespacesAndNewlines)
            let paramDefArray = paramDef.split(separator: " ").filter({ !$0.isEmpty })
            var paramType = ""
            var paramName = ""
            for id in 0..<paramDefArray.count {
                let it = paramDefArray[id]
                if id != paramDefArray.count - 1 {
                    paramType.append(it + " ")
                } else {
                    paramName = it.description
                }
            }
            paramType = paramType.trimmingCharacters(in: .whitespacesAndNewlines)
            paramName = paramName.trimmingCharacters(in: .whitespacesAndNewlines)
            if paramType.isEmpty {
                paramType = paramName
                paramName = peekUnnameIndex()
            }
            while paramType.last == "*" {
                paramType.removeLast()
                paramName = "*" + paramName
            }
            var realParamName = paramName
            var starStr = ""
            while realParamName.first == "*" { starStr.append(realParamName.removeFirst()) }
            if realParamName.isEmpty {
                paramName = starStr + peekUnnameIndex()
            }
            strbuf.append(drawType(paramType))
            strbuf.append(" \(paramName), ")
        }
        strbuf = strbuf.trimmingCharacters(in: .whitespacesAndNewlines)
        if strbuf.last == "," { strbuf.removeLast() }
        return strbuf
    }
    
    func drawDefinition(forElement element: ElementDefs) -> String {
        let colorTable = CLangColorTable.getColorTable()
        switch element.type {
        case .functionDefintion:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\">\(drawType(element.functionReturn)) \(drawFunc(element.name))(\(drawParamTable(element.functionArgs)));</font>".replacingOccurrences(of: "*", with: "\\*")
        case .structDefinition:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\"><font color=\"\(colorTable.getStructContentColor().hexString)\">struct</font> { ... } \(drawStruct(element.name));</font>".replacingOccurrences(of: "*", with: "\\*")
        case .typeDefinition:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\">\(color(token: "typedef", drawFunctionName: false, drawTypeName: false, drawStructName: false, drawVariableName: false)) \(drawType(element.typeImplementation)) \(drawType(element.name));</font>".replacingOccurrences(of: "*", with: "\\*")
        case .variableDefinition:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\">\(drawType(element.variableType)) \(drawVariable(element.name));</font>".replacingOccurrences(of: "*", with: "\\*")
        case .anyToken:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\">\(element.name)</font>".replacingOccurrences(of: "*", with: "\\*")
        case .functionPointer:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\">\(drawType(element.functionReturn)) (\(element.functionPointerFlag) \(drawType(element.name)))(\(drawParamTable(element.functionArgs)));</font>"
        case .specialReserved:
            return "<font face=\"menlo\" color=\"\(colorTable.getKeywordColor().hexString)\">\(element.name)</font>".replacingOccurrences(of: "*", with: "\\*")
        case .unionDefinition:
            return "<font face=\"menlo\" color=\"\(colorTable.getDocDefaultColor().hexString)\"><font color=\"\(colorTable.getStructContentColor().hexString)\">union</font> { ... } \(drawStruct(element.name));</font>".replacingOccurrences(of: "*", with: "\\*")
        }
    }
    
}

public class APIDocMemberModel: APIDocMarkdownGenerable {
    
    public var language: ElementDefs.SupportedLanguage = .unspecified
    public var provideRootMarkdownBlock: ProvideRootMarkdownBlock?
    public var member: ElementDefs
    public var collectionPath: String
    public var fileName: String
    public var linkPathPrefix: String = "https://docs.forgetive.org"
    
    public var shareURL: URL? {
        URL(string: "\(linkPathPrefix)/\(collectionPath)/\(fileName)/\(member.name)")
    }
    
    public var navigationItemTitle: String { member.name }
    
    public init(_ item: ElementDefs, inFile file: String, inCollection collection: String) {
        member = item
        fileName = file
        collectionPath = collection
    }
    
    public func generateMarkdown() -> String {
        let colorTable = CLangColorTable.getColorTable()
        
        let headerColorHex = colorTable.getTypeContentColor().hexString
        
        var markdown = ""
        markdown.append("#### \("APIDoc.\(member.type.rawValue)".apiDocLocalized(language)) (\("APIDoc.BelongsTo".apiDocLocalized(language)) \(getCollectionName()) / <font color=\"\(headerColorHex)\"><a href=\"\(buildLinkPath(withMemberName: nil, inFile: fileName, inCollection: collectionPath))\" style=\"color: \(headerColorHex)\">\(fileName)</a></font>)  \n")
        markdown.append("# \(member.name)  \n")
        markdown.append("\(drawDefinition(forElement: member))  \n")
        markdown.append("### \(member.getLocalizedComment(withKey: nil, language: language))  \n")
        
        let filePath = Bundle.main.resourcePath! + "/CodeAnalyserFile/article/\(fileName).md"
        if ["cdenvc", "stdc"].contains(collectionPath), FileManager.default.fileExists(atPath: filePath) {
            markdown.append("### <font color=\"\(CLangColorTable.getColorTable().getTypeContentColor().hexString)\"><a href=\"\(buildLinkPath(withMemberName: "__article__", inFile: fileName, inCollection: collectionPath))\" style=\"color: \(CLangColorTable.getColorTable().getTypeContentColor().hexString)\">\("APIDoc.Article".apiDocLocalized(language))</a></font>  \n")
        }
        
        var wantDrawBottomLine = true
        
        if member.type == .functionDefintion || member.type == .functionPointer {
            let paramDef = getFuncParamDef(member)
            if !paramDef.isEmpty {
                if wantDrawBottomLine {
                    markdown.append("  \n--------  \n")
                    wantDrawBottomLine = false
                }
                markdown.append("### \("APIDoc.ParamTable".apiDocLocalized(language))  \n")
                for it in paramDef {
                    markdown.append("&nbsp;&nbsp;\(drawType(it.type)) <font color=\"\(colorTable.getUserDefinedContentColor().hexString)\">\(it.name)</font>  \n")
                    if !it.description.isEmpty {
                        markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(it.description)  \n  \n")
                    }
                }
                wantDrawBottomLine = true
            }
        }
        
        if member.type == .typeDefinition || member.type == .structDefinition {
            let currentObjectName = member.type == .typeDefinition ? member.name : "struct \(member.name)"
            let collections = provideRootMarkdownBlock?() ?? []
            var relatedTypes = [ElementDefs]()
            var relatedFunctions = [ElementDefs]()
            var relatedVariables = [ElementDefs]()
            for collection in collections {
                for file in collection.files {
                    if file.fileName.hasSuffix(".h") {
                        for member in file.items {
                            switch member.type {
                            case .typeDefinition:
                                if member.typeImplementation == currentObjectName {
                                    relatedTypes.append(member)
                                }
                                break
                            case .functionDefintion:
                                if member.functionReturn == currentObjectName {
                                    relatedFunctions.append(member)
                                    break
                                }
                                let paramDefs = getFuncParamDef(member)
                                if paramDefs.contains(where: { $0.type == currentObjectName }) {
                                    relatedFunctions.append(member)
                                }
                                break
                            case .variableDefinition:
                                if member.variableType == currentObjectName {
                                    relatedVariables.append(member)
                                }
                                break
                            default:
                                break
                            }
                        }
                    }
                }
            }
            if relatedTypes.count + relatedVariables.count + relatedFunctions.count > 0 {
                if wantDrawBottomLine {
                    markdown.append("  \n--------  \n")
                    wantDrawBottomLine = false
                }
                markdown.append("### \("APIDoc.Related".apiDocLocalized(language))  \n")
                for it in relatedTypes {
                    markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                    let comment = it.getLocalizedComment(withKey: nil, language: language)
                    if !comment.isEmpty {
                        markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                    } else {
                        markdown.append("\n")
                    }
                }
                for it in relatedFunctions {
                    markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                    let comment = it.getLocalizedComment(withKey: nil, language: language)
                    if !comment.isEmpty {
                        markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                    } else {
                        markdown.append("\n")
                    }
                }
                for it in relatedVariables {
                    markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                    let comment = it.getLocalizedComment(withKey: nil, language: language)
                    if !comment.isEmpty {
                        markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                    } else {
                        markdown.append("\n")
                    }
                }
                wantDrawBottomLine = true
            }
        }
        
        return markdown
    }
    
}

public class ArticleDocModel: APIDocMarkdownGenerable {
    
    public var navigationItemTitle: String { "" }
    public var shareURL: URL? { URL(string: "\(linkPathPrefix)/\(collectionPath)/\(filePath)/__article__") }
    public var collectionPath: String
    public var linkPathPrefix: String = "https://docs.forgetive.org"
    public var language: ElementDefs.SupportedLanguage = .unspecified
    public var provideRootMarkdownBlock: ProvideRootMarkdownBlock?
    public var filePath: String
    
    public init(collectionPath: String, filePath: String) {
        self.filePath = filePath
        self.collectionPath = collectionPath
    }
    
    public func generateMarkdown() -> String {
        var markdown = ""
        markdown.append("#### \("APIDoc.Article.Title".apiDocLocalized(language)) (\("APIDoc.BelongsTo".apiDocLocalized(language)) \(getCollectionName()) / <font color=\"\(CLangColorTable.getColorTable().getTypeContentColor().hexString)\"><a href=\"\(buildLinkPath(withMemberName: nil, inFile: filePath, inCollection: collectionPath))\" style=\"color: \(CLangColorTable.getColorTable().getTypeContentColor().hexString)\">\(filePath)</a></font>)  \n")
        let pathToFile = Bundle.main.resourcePath! + "/CodeAnalyserFile/article/\(filePath).md"
        markdown.append((try? String(contentsOfFile: pathToFile)) ?? "")
        return markdown
    }
    
}

public class APIDocFileModel: APIDocMarkdownGenerable {
    
    public var language: ElementDefs.SupportedLanguage = .unspecified
    public var fileName: String
    public var collectionPath: String
    public var firstComment: ElementDefs
    public var items: [ElementDefs]
    public var provideRootMarkdownBlock: ProvideRootMarkdownBlock?
    public var linkPathPrefix: String = "https://docs.forgetive.org"
    
    public var shareURL: URL? {
        URL(string: "\(linkPathPrefix)/\(collectionPath)/\(fileName)")
    }
    
    public var navigationItemTitle: String { fileName }
    
    public convenience init() {
        self.init([], firstComment: ElementDefs(withAnyToken: "", comment: ""), withFileName: "", inCollection: "")
    }
    
    public init(_ items: [ElementDefs], firstComment: ElementDefs, withFileName file: String, inCollection collectionPath: String) {
        self.items = items
        self.fileName = file
        self.firstComment = firstComment
        self.collectionPath = collectionPath
    }
    
    public func generateMarkdown() -> String {
        var markdown = ""
        
        if fileName.hasSuffix(".h") {
            markdown.append("#### \("APIDoc.Header".apiDocLocalized(language))  \n")
        }
        if fileName.hasSuffix(".c") {
            markdown.append("#### \("APIDoc.Source".apiDocLocalized(language))  \n")
        }
        
        markdown.append("# \(fileName)  \n")
        
        if fileName.hasSuffix(".c") {
            markdown.append("<font color='#777777'>\("APIDoc.Source.Warn".apiDocLocalized(language))</font>  \n")
        }
        
        markdown.append("### \(firstComment.getLocalizedComment(withKey: "filesummary", language: language))  \n")
        let fileDescription = firstComment.getLocalizedComment(withKey: "filedescription", language: language)
        if !fileDescription.isEmpty {
            markdown.append("\(fileDescription)  \n")
        }
        let filePath = Bundle.main.resourcePath! + "/CodeAnalyserFile/article/\(fileName).md"
        if ["cdenvc", "stdc"].contains(collectionPath), FileManager.default.fileExists(atPath: filePath) {
            markdown.append("### <font color=\"\(CLangColorTable.getColorTable().getTypeContentColor().hexString)\"><a href=\"\(buildLinkPath(withMemberName: "__article__", inFile: fileName, inCollection: collectionPath))\" style=\"color: \(CLangColorTable.getColorTable().getTypeContentColor().hexString)\">\("APIDoc.Article".apiDocLocalized(language))</a></font>  \n")
        }
        markdown.append("--------  \n")
        
        let typeItems = items.filter { $0.type == .typeDefinition }
        let funcPtrItems = items.filter { $0.type == .functionPointer }
        let structItems = items.filter { $0.type == .structDefinition }
        let functionItems = items.filter { $0.type == .functionDefintion }
        let variableItems = items.filter { $0.type == .variableDefinition }
        
        var wantDrawBottomLine = false
        
        if !typeItems.isEmpty {
            markdown.append("### \("APIDoc.Type".apiDocLocalized(language))  \n")
            for it in typeItems {
                markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                let comment = it.getLocalizedComment(withKey: nil, language: language)
                if !comment.isEmpty {
                    markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                } else {
                    markdown.append("\n")
                }
            }
            wantDrawBottomLine = true
        }
        
        if !funcPtrItems.isEmpty {
            markdown.append("### \("APIDoc.FunctionPointer".apiDocLocalized(language))  \n")
            for it in funcPtrItems {
                markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                let comment = it.getLocalizedComment(withKey: nil, language: language)
                if !comment.isEmpty {
                    markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                } else {
                    markdown.append("\n")
                }
            }
            wantDrawBottomLine = true
        }
        
        if !structItems.isEmpty {
            if wantDrawBottomLine {
                markdown.append("  \n--------  \n")
                wantDrawBottomLine = false
            }
            markdown.append("### \("APIDoc.Struct".apiDocLocalized(language))  \n")
            for it in structItems {
                markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                let comment = it.getLocalizedComment(withKey: nil, language: language)
                if !comment.isEmpty {
                    markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                } else {
                    markdown.append("\n")
                }
            }
            wantDrawBottomLine = true
        }
        
        if !functionItems.isEmpty {
            if wantDrawBottomLine {
                markdown.append("  \n--------  \n")
                wantDrawBottomLine = false
            }
            markdown.append("### \("APIDoc.Function".apiDocLocalized(language))  \n")
            for it in functionItems {
                markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                let comment = it.getLocalizedComment(withKey: nil, language: language)
                if !comment.isEmpty {
                    markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                } else {
                    markdown.append("\n")
                }
            }
            wantDrawBottomLine = true
        }
        
        if !variableItems.isEmpty {
            if wantDrawBottomLine {
                markdown.append("  \n--------  \n")
                wantDrawBottomLine = false
            }
            markdown.append("### \("APIDoc.Variable".apiDocLocalized(language))  \n")
            for it in variableItems {
                markdown.append("&nbsp;&nbsp;\(drawDefinition(forElement: it))  \n")
                let comment = it.getLocalizedComment(withKey: nil, language: language)
                if !comment.isEmpty {
                    markdown.append("&nbsp;&nbsp;&nbsp;&nbsp;\(comment)  \n\n")
                } else {
                    markdown.append("\n")
                }
            }
            wantDrawBottomLine = true
        }
        
        return markdown
    }
    
}

public class APIDocFileCollectionModel {
    
    public var collectionTitle: String
    public var collectionStoragePath: String
    public var files: [APIDocFileModel]
    
    public convenience init() {
        self.init([], withCollectionTitle: "", andCollectionStoragePath: "")
    }
    
    public init(_ files: [APIDocFileModel], withCollectionTitle name: String, andCollectionStoragePath path: String) {
        self.collectionStoragePath = path
        self.files = files
        self.collectionTitle = name
    }
    
}

public class APIDocFetcher {
    
    public static let cdEnvCHeaders = ["autotree.h", "ccd.h", "debug.h", "http.h", "ccdui.h", "ccduicomp.h"]
    
    public class func fetch(_ code: String, _ name: String, inCollection collectionPath: String) -> APIDocFileModel {
        let doc = APIDocFileModel()
        doc.fileName = name
        doc.collectionPath = collectionPath
        let engine = CodeAnalysisEngine()
        var includeSet = [String]()
        engine.writeElementList = true
        engine.analysis(code, name, nil, &includeSet, false)
        doc.items = engine.elementList
        doc.firstComment = engine.getFirstComment(code)
        return doc
    }
    
    public class func fetchAll(withGivenProjectContext project: CCDProject?) -> [APIDocFileCollectionModel] {
        let standardCollection = APIDocFileCollectionModel([], withCollectionTitle: "APIDoc.StandardCHeaderName".apiDocLocalized(), andCollectionStoragePath: "stdc")
        let cdenvcCollection = APIDocFileCollectionModel([], withCollectionTitle: "APIDoc.ExtendedCHeaderName".apiDocLocalized(), andCollectionStoragePath: "cdenvc")
        var collections = [standardCollection, cdenvcCollection]
        for it in (try? FileManager.default.contentsOfDirectory(atPath: (Bundle.main.resourcePath ?? "") + "/CodeAnalyserFile"))?.filter({ !$0.hasSuffix("_intrinsic.h") }) ?? [] {
            let isFolder = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
            FileManager.default.fileExists(atPath: (Bundle.main.resourcePath ?? "") + "/CodeAnalyserFile/" + it, isDirectory: isFolder)
            if !isFolder.pointee.boolValue {
                let fileName = it
                let fileCode = (try? String(contentsOfFile: (Bundle.main.resourcePath ?? "") + "/CodeAnalyserFile/" + it)) ?? ""
                let apiDoc = fetch(fileCode, fileName, inCollection: cdEnvCHeaders.contains(fileName) ? "cdenvc" : "stdc")
                if cdEnvCHeaders.contains(fileName) {
                    cdenvcCollection.files.append(apiDoc)
                } else {
                    standardCollection.files.append(apiDoc)
                }
            }
        }
        
        if let project = project {
            let currentProjectCollection = APIDocFileCollectionModel([], withCollectionTitle: "\(project.projectName ) \("APIDoc.Current".apiDocLocalized())", andCollectionStoragePath: project.projectName )
            for it in project.files.files {
                let ifn = it.fileName ?? ""
                let ifv = it.fileCode ?? ""
                if ifn.hasSuffix(".h") || ifn.hasSuffix(".c") {
                    currentProjectCollection.files.append(fetch(ifv, ifn, inCollection: project.projectName ))
                }
            }
            collections.append(currentProjectCollection)
        }
        
        for it in (try? FileManager.default.contentsOfDirectory(atPath: AppDelegate.documentsDirectory())) ?? [] {
            if it == (project?.projectName ?? "") { continue }
            let project = CCDProject(openWithName: it)
            let currentProjectCollection = APIDocFileCollectionModel([], withCollectionTitle: it, andCollectionStoragePath: it)
            let collectionPath = it
            if let project = project {
                for it in project.files.files {
                    let ifn = it.fileName ?? ""
                    let ifv = it.fileCode ?? ""
                    if ifn.hasSuffix(".h") || ifn.hasSuffix(".c") {
                        currentProjectCollection.files.append(fetch(ifv, ifn, inCollection: collectionPath))
                    }
                }
            }
            collections.append(currentProjectCollection)
        }
        
        return collections
    }
    
}
