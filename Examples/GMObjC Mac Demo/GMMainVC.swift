//
//  ViewController.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/22.
//

import Cocoa

class GMMainVC: NSViewController {
    
    private let kGMTestColumnID = NSUserInterfaceItemIdentifier("kGMTestColumnID")
    private let kGMTestCellID = NSUserInterfaceItemIdentifier("kGMTestCellID")
    private var itemModelList: [GMTestItemModel] = []
    
    override func loadView() {
        let winSize = NSScreen.main?.frame.size ?? NSSize(width: 800.0, height: 600.0)
        let winRect = NSRect(x: 0, y: 0, width: winSize.width * 0.5, height: winSize.height * 0.5)
        self.view = NSView(frame: winRect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 运行示例
        var modelList: [GMTestModel] = []
        modelList.append(GMTestUtil.testSm2EnDe())
        modelList.append(GMTestUtil.testSm2Sign())
        modelList.append(GMTestUtil.testSm3())
        modelList.append(GMTestUtil.testSm4())
        modelList.append(GMTestUtil.testECDH())
        modelList.append(GMTestUtil.testReadPemDerFiles())
        modelList.append(GMTestUtil.testSaveToPemDerFiles())
        modelList.append(GMTestUtil.testCreateKeyPairFiles())
        modelList.append(GMTestUtil.testCompressPublicKey())
        modelList.append(GMTestUtil.testConvertPemAndDer())
        modelList.append(GMTestUtil.testReadX509FileInfo())
        // 转换类型
        self.itemModelList = modelList.flatMap({ $0.itemList as? [GMTestItemModel] ?? [] })
        // 创建视图
        self.tableView.addTableColumn(self.tableColumn)
        self.scrollView.documentView = self.tableView
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        self.tableColumn.width = self.view.bounds.width - 20
        self.tableView.reloadData()
    }
    
    // MARK: - Lazy Load
    lazy var scrollView: NSScrollView = {
        let tmpView = NSScrollView(frame: NSRect.zero)
        tmpView.translatesAutoresizingMaskIntoConstraints = false
        return tmpView
    }()
    
    lazy var tableView: NSTableView = {
        let tmpView = NSTableView(frame: NSRect.zero)
        if #available(macOS 11.0, *) {
            tmpView.style = NSTableView.Style.fullWidth
        }
        tmpView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tmpView.translatesAutoresizingMaskIntoConstraints = false
        // 父视图的尺寸更改时的自动调整
        tmpView.autoresizingMask = [.width, .height]
        tmpView.rowHeight = 44
        tmpView.selectionHighlightStyle = .none
        tmpView.allowsColumnResizing = true
        tmpView.allowsColumnSelection = false
        tmpView.allowsColumnReordering = false
        tmpView.headerView = nil
        tmpView.dataSource = self
        tmpView.delegate = self
        return tmpView
    }()
    
    lazy var tableColumn: NSTableColumn = {
        let tmpColumn = NSTableColumn(identifier: self.kGMTestColumnID)
        tmpColumn.resizingMask = NSTableColumn.ResizingOptions.userResizingMask
        return tmpColumn
    }()
    
    lazy var colorList: [NSColor] = {
        let color0 = NSColor.white
        let color1 = NSColor(red: 250.0/255.0, green: 249.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        let color2 = NSColor(red: 255.0/255.0, green: 242.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        let color3 = NSColor(red: 253.0/255.0, green: 230.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        let color4 = NSColor(red: 227.0/255.0, green: 237.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        let color5 = NSColor(red: 220.0/255.0, green: 226.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        let color6 = NSColor(red: 233.0/255.0, green: 235.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        let color7 = NSColor(red: 234.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        let colors = [color0, color1, color2, color3, color4, color5, color6, color7]
        return colors
    }()
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource
extension GMMainVC: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.itemModelList.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let model = self.itemModelList[row]
        let textWidth = tableView.bounds.size.width - 12 - 20
        let detailHeight = self.textHeight(text: model.detail, fontSize: 14, width: textWidth)
        let cellHeight = detailHeight + 40.0 + 6
        return cellHeight
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell = tableView.makeView(withIdentifier: self.kGMTestCellID, owner: self) as? GMTestCell
        if (cell == nil) {
            cell = GMTestCell(frame: NSRect.zero)
        }
        guard let cell = cell else { return cell }
        // 背景色
        let colorIndex: Int = (row%8) < self.colorList.count ? (row%8) : 0
        cell.updateBgColor(titleBg: self.colorList[colorIndex], contentBg: self.colorList[colorIndex])
        // 更新文本
        let model = self.itemModelList[row]
        cell.updateTxt(title: model.title, content: model.detail)
        return cell
    }
}

// MARK: - 工具类
extension GMMainVC {
    // 计算文本的高度
    private func textHeight(text: String?, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let textSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude);
        let textDict = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: fontSize)]
        guard let text = text, text.isEmpty == false else { return 0 }
        let height = text.boundingRect(with: textSize,
                                       options: .usesLineFragmentOrigin,
                                       attributes: textDict,
                                       context: nil).size.height
        return height
    }
}
