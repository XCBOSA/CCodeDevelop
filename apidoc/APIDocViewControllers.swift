//
//  APIDocRootViewController.swift
//  C Code Develop
//
//  Created by xcbosa on 2022/6/20.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import UIKit
import FastLayout
import WebKit

public extension String {
    func apiDocLocalized(_ language: ElementDefs.SupportedLanguage = .unspecified) -> String {
        switch language {
        case .unspecified:
            return NSLocalizedString(self, tableName: "APIDocLocalizable", bundle: .main, value: "", comment: "")
        case .english:
            return Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "")?.localizedString(forKey: self, value: "", table: "APIDocLocalizable") ?? ""
        case .chinese:
            return Bundle(path: Bundle.main.path(forResource: "zh-Hans", ofType: "lproj") ?? "")?.localizedString(forKey: self, value: "", table: "APIDocLocalizable") ?? ""
        }
        
    }
}

public extension Array where Element == String {
    func localized(_ language: ElementDefs.SupportedLanguage) -> String {
        var index = 0
        switch (language) {
        case .unspecified:
            if NSLocalizedString("UpdateAssets", comment: "en.rtf") == "zh.rtf" {
                index = 1
            } else {
                index = 0
            }
            break
        case .chinese:
            index = 1
            break
        case .english:
            index = 0
            break
        }
        return self[index]
    }
}

public class APIDocRootViewController: UISplitViewController {
    
    public var collectionModel: [APIDocFileCollectionModel] = []
    public var collectionModelChangeBlock: (() -> Void)?
    public private(set) var hasXmarkButton: Bool = false
    public private(set) var useNewSplitViewController: Bool
    public var legacyNavigationViewController: UINavigationController?
    
    public private(set) var didAPIDocLoaded = false
    private var executeWhenLoadedQueue = [() -> Void]()
    
    public func executeWhenLoaded(_ block: @escaping () -> Void) {
        if didAPIDocLoaded {
            block()
        } else {
            executeWhenLoadedQueue.append(block)
        }
    }
    
    public func provideRootCollectionModel() -> [APIDocFileCollectionModel] { collectionModel }
    
    public init(hasXmarkButton: Bool) {
//        if #available(iOS 14.0, *) {
//            self.useNewSplitViewController = true
//            super.init(style: .doubleColumn)
//            super.preferredSplitBehavior = .tile
//        } else {
            self.useNewSplitViewController = false
            super.init(nibName: nil, bundle: nil)
//        }
        super.preferredDisplayMode = .oneBesideSecondary
        super.primaryBackgroundStyle = .sidebar
        super.viewControllers = [ADLeftNavigationController(parent: self)]
        self.hasXmarkButton = hasXmarkButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func doFetching() {
        let fetchingAlert = UIAlertController(title: "APIDoc.FetchingAlert.Title".apiDocLocalized(),
                                              message: "APIDoc.FetchingAlert.Text".apiDocLocalized(),
                                              preferredStyle: .alert)
        fetchingAlert.regThemeManagerResponser()
        self.present(fetchingAlert, animated: true) {
            DispatchQueue.global(qos: .utility).async {
                self.collectionModel = APIDocFetcher.fetchAll(withGivenProjectContext: self.project)
                DispatchQueue.main.async {
                    self.didAPIDocLoaded = true
                    self.executeWhenLoadedQueue.forEach({ $0() })
                    fetchingAlert.dismiss(animated: true) {
                        self.collectionModelChangeBlock?()
                    }
                }
            }
        }
    }
    
    public override func viewDidLoad() {
        self.regThemeManagerResponser()
        
        DispatchQueue.main.async {
            self.doFetching()
        }
    }
    
    public func openSecondary(viewController vc: UIViewController, replaceCurrentRightStack replace: Bool) {
        if useNewSplitViewController {
            if #available(iOS 14.0, *) {
                self.setViewController(vc, for: .secondary)
                self.show(.secondary)
            }
        } else {
            if replace {
                self.legacyNavigationViewController = nil
            }
            if let navVc = self.legacyNavigationViewController {
                self.legacyNavigationViewController?.pushViewController(vc, animated: true)
                ocIgnoreException {
                    self.showDetailViewController(navVc, sender: nil)
                }
            } else {
                let navVc = UINavigationController(rootViewController: vc)
                self.legacyNavigationViewController = navVc
                self.showDetailViewController(navVc, sender: nil)
            }
        }
    }
    
}

extension APIDocRootViewController: AbstractWindow {
    
    public var filePath: String { "APIDoc.Title".apiDocLocalized() }
    public var type: AbstractWindowType { .draggableTools }
    
}

public class ADLeftNavigationController: UINavigationController {
    
    public var parentController: APIDocRootViewController
    
    public init(parent: APIDocRootViewController) {
        self.parentController = parent
        super.init(nibName: nil, bundle: nil)
        self.pushViewController(ADListViewController(parent: self), animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        self.regThemeManagerResponser()
        self.navigationBar.prefersLargeTitles = true
    }
    
}

public class ADListViewController: UITableViewController {
    
    public var parentController: ADLeftNavigationController
    private lazy var resultViewController = ADSearchController(listViewController: self)
    
    public var collectionModel: [APIDocFileCollectionModel] {
        get { self.parentController.parentController.collectionModel }
        set { self.parentController.parentController.collectionModel = newValue }
    }
    
    public init(parent: ADLeftNavigationController) {
        self.parentController = parent
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var btnExpandOrCollapse: UIBarButtonItem?
    
    public override func viewDidLoad() {
        self.regThemeManagerResponser()
        self.navigationItem.title = "APIDoc.Title".apiDocLocalized()
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = UISearchController(searchResultsController: resultViewController)
        self.navigationItem.searchController?.searchResultsUpdater = resultViewController
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.navigationItem.leftBarButtonItems = []
        
        if parentController.parentController.hasXmarkButton {
            let btnXmark = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(btnXmarkTouched(_:)))
            btnXmark.tintColor = .systemRed
            self.navigationItem.leftBarButtonItems?.append(btnXmark)
        }
        
        if !parentController.parentController.useNewSplitViewController && splitViewControllerIsIpadMode() {
            let btnExpandOrCollapse = UIBarButtonItem(image: UIImage(systemName: "sidebar.left"), style: .plain, target: self, action: #selector(btnSidebar(_:)))
            self.navigationItem.leftBarButtonItems?.append(btnExpandOrCollapse)
            self.btnExpandOrCollapse = btnExpandOrCollapse
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(btnRefresh(_:)))
        ]
        self.tableView.register(ADFileCell.self, forCellReuseIdentifier: "ADFileCell")
        self.parentController.parentController.collectionModelChangeBlock = {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func btnSidebar(_ any: Any) {
        let splitVc = self.parentController.parentController
        splitVc.preferredDisplayMode = splitVc.preferredDisplayMode == .oneBesideSecondary ? .oneOverSecondary : .oneBesideSecondary
        if splitVc.preferredDisplayMode == .oneBesideSecondary {
            self.btnExpandOrCollapse?.image = UIImage(systemName: "sidebar.left")
        } else {
            self.btnExpandOrCollapse?.image = UIImage(systemName: "rectangle")
        }
    }
    
    @objc private func btnXmarkTouched(_ any: Any) {
        self.parentController.parentController.dismiss(animated: true)
    }
    
    @objc private func btnRefresh(_ any: Any) {
        self.parentController.parentController.doFetching()
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.collectionModel[section].collectionTitle
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return self.collectionModel.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collectionModel[section].files.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let view = tableView.dequeueReusableCell(withIdentifier: "ADFileCell", for: indexPath) as? ADFileCell {
            view.fill(data: self.collectionModel[indexPath.section].files[indexPath.row])
            return view
        }
        return UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 0 && indexPath.section < self.collectionModel.count {
            if indexPath.row >= 0 && indexPath.row < self.collectionModel[indexPath.section].files.count {
                let obj = self.collectionModel[indexPath.section].files[indexPath.row]
                openAPIDocObject(obj, replaceCurrentRightStack: true)
            }
        }
    }
    
    public func openAPIDocObject(_ apiDoc: APIDocMarkdownGenerable, replaceCurrentRightStack: Bool) {
        var data = apiDoc
        data.provideRootMarkdownBlock = {
            [weak self] in self?.collectionModel ?? []
        }
        let subVc = APIDocExplorerViewController(withAPIDocFile: data)
        self.parentController.parentController.openSecondary(viewController: subVc, replaceCurrentRightStack: replaceCurrentRightStack)
    }
    
}
            
public class ADSearchController: UITableViewController, UISearchResultsUpdating {
    
    public class SearchModel {
        public private(set) var fileModel: APIDocFileModel?
        public private(set) var elementModel: APIDocMemberModel?
        
        public init(withFile file: APIDocFileModel) {
            self.fileModel = file
        }
        
        public init(withElement element: APIDocMemberModel) {
            self.elementModel = element
        }
        
        public var title: String {
            if let fileModel = fileModel {
                return fileModel.fileName
            } else {
                return elementModel?.member.name ?? ""
            }
        }
        
        public var description: String {
            if let fileModel = fileModel {
                return fileModel.firstComment.getLocalizedComment(withKey: "filesummary")
            } else {
                return elementModel?.member.definition ?? ""
            }
        }
        
        public var renderCode: Bool {
            return elementModel != nil
        }
    }
    
    let sectionList = [
        "Header",
        ElementDefs.ElementType.typeDefinition.rawValue,
        ElementDefs.ElementType.structDefinition.rawValue,
        ElementDefs.ElementType.functionDefintion.rawValue,
        ElementDefs.ElementType.variableDefinition.rawValue,
        ElementDefs.ElementType.functionPointer.rawValue
    ]
    
    var model = [[SearchModel](),
                 [SearchModel](),
                 [SearchModel](),
                 [SearchModel](),
                 [SearchModel](),
                 [SearchModel]()]
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let listViewController = self.listViewController else { return }
        self.listViewController?.tableView.isHidden = !(searchController.searchBar.text ?? "").isEmpty
        if let text = searchController.searchBar.text {
            let lowerText = text.lowercased()
            for id in 0..<model.count {
                model[id].removeAll()
            }
            for collection in listViewController.collectionModel {
                for file in collection.files {
                    if file.fileName.lowercased().contains(lowerText) ||
                        file.firstComment.getLocalizedComment(withKey: "filesummary").lowercased().contains(lowerText) {
                        model[0].append(SearchModel(withFile: file))
                    }
                    for element in file.items {
                        if element.name.lowercased().contains(lowerText) ||
                            element.getLocalizedComment(withKey: nil).lowercased().contains(lowerText) {
                            let elementModel = APIDocMemberModel(element, inFile: file.fileName, inCollection: collection.collectionStoragePath)
                            let searchModel = SearchModel(withElement: elementModel)
                            switch element.type {
                            case .functionDefintion:
                                model[3].append(searchModel)
                                break
                            case .structDefinition:
                                model[2].append(searchModel)
                                break
                            case .typeDefinition:
                                model[1].append(searchModel)
                                break
                            case .variableDefinition:
                                model[4].append(searchModel)
                                break
                            case .anyToken:
                                break
                            case .functionPointer:
                                model[5].append(searchModel)
                            case .specialReserved:
                                break
                            default: break // TODO: union
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    public weak var listViewController: ADListViewController?
    
    public init(listViewController: ADListViewController?) {
        self.listViewController = listViewController
        super.init(style: .insetGrouped)
        self.tableView.register(ADFileCell.self, forCellReuseIdentifier: "ADFileCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        self.regThemeManagerResponser()
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "APIDoc.\(sectionList[section])".apiDocLocalized()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        model.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ADFileCell", for: indexPath) as? ADFileCell {
            cell.fill(data: model[indexPath.section][indexPath.row])
            return cell
        }
        return ADFileCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.model[indexPath.section][indexPath.row]
        if let fileModel = data.fileModel {
            listViewController?.openAPIDocObject(fileModel, replaceCurrentRightStack: true)
        }
        if let elementModel = data.elementModel {
            listViewController?.openAPIDocObject(elementModel, replaceCurrentRightStack: false)
        }
    }
    
}

public class ADFileCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func fill(data: APIDocFileModel) {
        self.textLabel?.text = data.fileName
        self.textLabel?.font = .systemFont(ofSize: 18)
        self.detailTextLabel?.text = data.firstComment.getLocalizedComment(withKey: "filesummary")
        self.detailTextLabel?.numberOfLines = 3
        self.detailTextLabel?.font = .systemFont(ofSize: 12)
    }
    
    public func fill(data: ADSearchController.SearchModel) {
        self.textLabel?.text = data.title
        self.textLabel?.font = .systemFont(ofSize: 18)
        self.detailTextLabel?.text = "\(data.description)"
        self.detailTextLabel?.numberOfLines = 3
        self.detailTextLabel?.font = .systemFont(ofSize: 12)
        if data.renderCode {
            self.detailTextLabel?.text = " \(data.description)"
            let draw = CodeEditorDelegate(" \(data.description)", "snapshot.c", withProject: self.firstViewController()?.project)
            draw.updateHighlight_C_H(textView: self.detailTextLabel!)
            draw.deinitTimer()
            self.detailTextLabel?.attributedText = self.detailTextLabel?.attributedText?.attributedSubstring(from: NSRange(location: 1, length: data.description.count - 1))
            self.detailTextLabel?.font = UIFont(name: "Menlo", size: 12)
        }
    }
    
}

public class APIDocExplorerViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    public private(set) var apiDoc: APIDocMarkdownGenerable
    private var isPreviewLoaded: Bool = false
    public var openSecondaryBlock: ((APIDocExplorerViewController) -> Void)?
    var previewNotLoadedStoragedRequest: String? = nil
    
    public var inlineConstraints = [NSLayoutConstraint]()
    
    public init(withAPIDocFile file: APIDocMarkdownGenerable) {
        self.apiDoc = file
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var webView: WKWebView = {
        let view = WKWebView()
        view.loadFileURL(URL(fileURLWithPath: Bundle.main.resourcePath! + "/MarkdownView/index.html"), allowingReadAccessTo: URL(fileURLWithPath: Bundle.main.resourcePath! + "/MarkdownView"))
        view.uiDelegate = self
        view.navigationDelegate = self
        view.scrollView.delegate = self
        return view
    }()
    
    private lazy var webViewMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    public override func viewDidLoad() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(webView)
        webView.left == self.view.leftAnchor
        webView.top == self.view.topAnchor
        webView.right == self.view.rightAnchor
        webView.bottom == self.view.bottomAnchor
        
        self.view.addSubview(webViewMaskView)
        webViewMaskView.left == self.view.leftAnchor
        webViewMaskView.right == self.view.rightAnchor
        webViewMaskView.top == self.view.topAnchor
        webViewMaskView.bottom == self.view.bottomAnchor
        
        self.displayMarkdown(newCode: apiDoc.generateMarkdown())
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportButtonClicked(_:)))
    }
    
    @objc private func exportButtonClicked(_ sourceItem: UIBarButtonItem) {
        let exportHtmlBlock = {
            let alert = UIAlertController(title: "APIDoc.ExportAlert.Title".apiDocLocalized(), message: "APIDoc.ExportAlert.Text".apiDocLocalized(), preferredStyle: .actionSheet)
            alert.popoverPresentationController?.barButtonItem = sourceItem
            
            alert.addAction(UIAlertAction(title: self.apiDoc.navigationItemTitle, style: .default, handler: {
                _ in
                self.submitWebView {
                    APIDocGenerator(webView: self.webView).generateAsync(self.apiDoc, rootBlock: self.apiDoc.provideRootMarkdownBlock) {
                        html in
                        do {
                            if !FileManager.default.fileExists(atPath: AppDelegate.documentsDirectory() + "/ExportTemp") {
                                try FileManager.default.createDirectory(at: URL(fileURLWithPath: AppDelegate.documentsDirectory() + "/ExportTemp"), withIntermediateDirectories: true)
                            }
                            let exportTempFileURL = AppDelegate.documentsDirectory() + "/ExportTemp/" + self.apiDoc.navigationItemTitle + ".html"
                            if FileManager.default.fileExists(atPath: exportTempFileURL) {
                                try FileManager.default.removeItem(atPath: exportTempFileURL)
                            }
                            try html.write(toFile: exportTempFileURL, atomically: true, encoding: .utf8)
                            self.presentSavePanel(url: URL(fileURLWithPath: exportTempFileURL), from: sourceItem) {
                                try? FileManager.default.removeItem(at: $0)
                            }
                        }
                        catch {
                            let alert = UIAlertController(title: "APIDoc.Export.Error".apiDocLocalized(), message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "APIDoc.Export.OK".apiDocLocalized(), style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }))
            
            for it in self.apiDoc.provideRootMarkdownBlock?().filter({ !$0.files.isEmpty }) ?? [] {
                #if !DEBUG
                if ["stdc", "cdenvc"].contains(it.collectionStoragePath) { continue }
                #endif
                alert.addAction(UIAlertAction(title: it.collectionTitle, style: .default, handler: {
                    alert in
                    self.submitWebView {
                        var exportRoot = AppDelegate.documentsDirectory() + "/ExportTemp"
                        do {
                            let generator = APIDocGenerator(webView: self.webView)
                            let group = DispatchGroup()
                            if !FileManager.default.fileExists(atPath: exportRoot) {
                                try FileManager.default.createDirectory(at: URL(fileURLWithPath: exportRoot), withIntermediateDirectories: true)
                            }
                            exportRoot += "/\(UUID())"
                            try FileManager.default.createDirectory(at: URL(fileURLWithPath: exportRoot), withIntermediateDirectories: true)
                            for file in it.files {
                                group.enter()
                                generator.generateAsync(file, rootBlock: self.apiDoc.provideRootMarkdownBlock, completion: {
                                    html in
                                    try? html.write(toFile: exportRoot + "/\(file.fileName).html", atomically: true, encoding: .utf8)
                                    group.leave()
                                })
                                for member in file.items {
                                    let member = APIDocMemberModel(member, inFile: file.fileName, inCollection: file.collectionPath)
                                    group.enter()
                                    generator.generateAsync(member, rootBlock: self.apiDoc.provideRootMarkdownBlock, completion: {
                                        html in
                                        if !FileManager.default.fileExists(atPath: exportRoot + "/\(file.fileName)") {
                                            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: exportRoot + "/\(file.fileName)"), withIntermediateDirectories: true)
                                        }
                                        try? html.write(toFile: exportRoot + "/\(file.fileName)/\(member.member.name).html", atomically: true, encoding: .utf8)
                                        group.leave()
                                    })
                                }
                            }
                            group.notify(queue: .main) {
                                if SSZipArchive.createZipFile(atPath: exportRoot + "/\(it.collectionStoragePath).zip", withContentsOfDirectory: exportRoot) {
                                    self.presentSavePanel(url: URL(fileURLWithPath: exportRoot + "/\(it.collectionStoragePath).zip"), from: sourceItem) {
                                        url in
                                        try? FileManager.default.removeItem(atPath: exportRoot)
                                    }
                                } else {
                                    try? FileManager.default.removeItem(atPath: exportRoot)
                                    let alert = UIAlertController(title: "APIDoc.Export.Error".apiDocLocalized(), message: "APIDoc.Export.ZipFail".apiDocLocalized(), preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "APIDoc.Export.OK".apiDocLocalized(), style: .default))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                        catch {
                            try? FileManager.default.removeItem(atPath: exportRoot)
                            let alert = UIAlertController(title: "APIDoc.Export.Error".apiDocLocalized(), message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "APIDoc.Export.OK".apiDocLocalized(), style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }))
            }
            
            alert.addAction(UIAlertAction(title: "APIDoc.ExportAlert.Cancel".apiDocLocalized(), style: .cancel))
            self.present(alert, animated: true)
            
            
        }
        let exportShare = {
            if let url = self.apiDoc.shareURL {
                self.presentSharePanel(url: url, from: sourceItem)
            }
        }
        if ["cdenvc", "stdc"].contains(self.apiDoc.collectionPath) {
            exportShare()
        } else {
            exportHtmlBlock()
        }
    }
    
    var beforeLoadingQueue = [(() -> Void)?]()
    private func submitWebView(action: @escaping () -> Void) {
        if isPreviewLoaded {
            action()
        } else {
            beforeLoadingQueue.append(action)
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let theme = self.traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        submitWebView {
            self.webView.evaluateJavaScript("document.getElementById('x').style.backgroundColor = '\(self.view.backgroundColor?.resolvedColor(with: self.traitCollection).hexString ?? "#555555")'", completionHandler: nil)
            self.webView.evaluateJavaScript("setTheme(\"\(theme)\")", completionHandler: nil)
            self.displayMarkdown(newCode: self.apiDoc.generateMarkdown())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.webViewMaskView.isHidden = true
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.isPreviewLoaded = true
        let theme = self.traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        self.webView.evaluateJavaScript("setTheme(\"\(theme)\")", completionHandler: nil)
        if let storaged = self.previewNotLoadedStoragedRequest {
            self.previewNotLoadedStoragedRequest = nil
            self.displayMarkdown(newCode: storaged)
        }
        _ = beforeLoadingQueue.map({ $0?() })
        self.traitCollectionDidChange(self.traitCollection)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !isPreviewLoaded {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        if let path = navigationAction.request.url?.path {
            let pathComponents = path.split(separator: "/")
            if pathComponents.count == 3 {
                let collectionId = pathComponents[0]
                let fileName = pathComponents[1]
                let memberName = pathComponents[2]
                if ["cdenvc", "stdc"].contains(collectionId), memberName == "__article__" {
                    let articleModel = ArticleDocModel(collectionPath: String(collectionId), filePath: String(fileName))
                    articleModel.provideRootMarkdownBlock = apiDoc.provideRootMarkdownBlock
                    let explorerVc = APIDocExplorerViewController(withAPIDocFile: articleModel)
                    if let openSecondaryBlock = openSecondaryBlock {
                        openSecondaryBlock(explorerVc)
                    } else {
                        (self.splitViewController as? APIDocRootViewController)?.openSecondary(viewController: explorerVc, replaceCurrentRightStack: false)
                    }
                }
                else if let rootModel = apiDoc.provideRootMarkdownBlock?(),
                   let collectionModel = rootModel.first(where: { $0.collectionStoragePath == collectionId }),
                   let fileModel = collectionModel.files.first(where: { $0.fileName == fileName }),
                   let defs = fileModel.items.first(where: { $0.name == memberName }) {
                    let memberModel = APIDocMemberModel(defs, inFile: fileName.description, inCollection: collectionId.description)
                    memberModel.provideRootMarkdownBlock = apiDoc.provideRootMarkdownBlock
                    let explorerVc = APIDocExplorerViewController(withAPIDocFile: memberModel)
                    if let openSecondaryBlock = openSecondaryBlock {
                        openSecondaryBlock(explorerVc)
                    } else {
                        (self.splitViewController as? APIDocRootViewController)?.openSecondary(viewController: explorerVc, replaceCurrentRightStack: false)
                    }
                }
            }
            if pathComponents.count == 2 {
                let collectionId = pathComponents[0]
                let fileName = pathComponents[1]
                if let rootModel = apiDoc.provideRootMarkdownBlock?(),
                   let collectionModel = rootModel.first(where: { $0.collectionStoragePath == collectionId }),
                   let fileModel = collectionModel.files.first(where: { $0.fileName == fileName }) {
                    fileModel.provideRootMarkdownBlock = apiDoc.provideRootMarkdownBlock
                    let explorerVc = APIDocExplorerViewController(withAPIDocFile: fileModel)
                    if let openSecondaryBlock = openSecondaryBlock {
                        openSecondaryBlock(explorerVc)
                    } else {
                        (self.splitViewController as? APIDocRootViewController)?.openSecondary(viewController: explorerVc, replaceCurrentRightStack: false)
                    }
                }
            }
        }
    }
    
    func displayMarkdown(newCode: String) {
        if !isPreviewLoaded {
            self.previewNotLoadedStoragedRequest = newCode
            return
        }
        if Thread.isMainThread {
            self.webView.evaluateJavaScript("displayMarkdown(\(codeToJsStr(content: newCode)))", completionHandler: nil)
        } else {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("displayMarkdown(\(codeToJsStr(content: newCode)))", completionHandler: nil)
            }
        }
        self.navigationItem.title = apiDoc.navigationItemTitle
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
    
}
