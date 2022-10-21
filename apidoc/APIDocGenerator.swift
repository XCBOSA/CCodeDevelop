//
//  APIDocGenerator.swift
//  C Code Develop
//
//  Created by 邢铖 on 2022/7/4.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import WebKit

public class APIDocGenerator: NSObject, WKNavigationDelegate {
    
    static let templateHtml = (try? String(contentsOf: URL(fileURLWithPath: (Bundle.main.resourcePath ?? "") + "/MarkdownView/template.html"))) ?? ""
    
    private var webView: WKWebView
    
    public init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    public func generateAsync(_ markdown: APIDocMarkdownGenerable, linkPrefix: String = "https://docs.forgetive.org", rootBlock: ProvideRootMarkdownBlock?, completion: @escaping (String) -> Void) {
        let prefixBackup = markdown.linkPathPrefix
        let languageBackup = markdown.language
        let rootBlockBkup = markdown.provideRootMarkdownBlock
        defer {
            markdown.linkPathPrefix = prefixBackup
            markdown.language = languageBackup
            markdown.provideRootMarkdownBlock = rootBlockBkup
        }
        markdown.linkPathPrefix = linkPrefix
        let languages = [ElementDefs.SupportedLanguage.english, .chinese]
        var fileCode = Self.templateHtml
        let group = DispatchGroup()
        fileCode = fileCode
            .replacingOccurrences(of: "{{PARSED_TITLE}}", with: markdown.navigationItemTitle)
            .replacingOccurrences(of: "{{PARSED_BACKGROUND}}", with: UIColor.systemBackground.resolvedColor(with: webView.traitCollection).hexString)
            .replacingOccurrences(of: "{{PARSED_FOREGROUND}}", with: UIColor.label.resolvedColor(with: webView.traitCollection).hexString)
        for language in languages {
            let language = language
            markdown.language = language
            markdown.provideRootMarkdownBlock = rootBlock
            let markdownText = markdown.generateMarkdown()
            group.enter()
            webView.evaluateJavaScript("parseMarkdown(\(codeToJsStr(content: markdownText)))") {
                result, error in
                if error == nil, let result = result as? String {
                    fileCode = fileCode.replacingOccurrences(of: "{{PARSED_HTML_\(language)}}", with: result)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(fileCode)
        }
    }
    
}
