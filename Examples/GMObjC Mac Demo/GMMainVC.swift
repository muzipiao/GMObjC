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
    private var modelList: [GMTestModel] = []
    
    override func loadView() {
        super.loadView()
        guard let winSize = NSScreen.main?.frame.size else { return }
        let winWidth = winSize.width * 0.5
        let winHeight = winSize.height * 0.5
        self.view.frame = CGRect(x: 0, y: 0, width: winWidth, height: winHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer?.backgroundColor = NSColor.green.cgColor
        // 运行示例
        self.modelList.append(GMTestUtil.testSm2EnDe())
        self.modelList.append(GMTestUtil.testSm2Sign())
        self.modelList.append(GMTestUtil.testSm3())
        self.modelList.append(GMTestUtil.testSm4())
        self.modelList.append(GMTestUtil.testECDH())
        self.modelList.append(GMTestUtil.testReadPemDerFiles())
        self.modelList.append(GMTestUtil.testSaveToPemDerFiles())
        self.modelList.append(GMTestUtil.testCreateKeyPairFiles())
        self.modelList.append(GMTestUtil.testCompressPublicKey())
        self.modelList.append(GMTestUtil.testConvertPemAndDer())
        self.modelList.append(GMTestUtil.testReadX509FileInfo())
        // 创建视图
        self.tableView.addTableColumn(self.tableColumn)
        self.scrollView.documentView = self.tableView
        self.view.addSubview(self.scrollView)
        self.scrollView.frame = self.view.bounds
        self.tableView.frame = self.view.bounds
        self.tableColumn.width = self.view.bounds.size.width
        self.tableView.reloadData()
    }
    
    // MARK: - Lazy Load
    lazy var scrollView: NSScrollView = {
        let tmpView = NSScrollView(frame: self.view.bounds)
        return tmpView
    }()
    
    lazy var tableView: NSTableView = {
        let tmpView = NSTableView(frame: self.view.bounds)
        if #available(macOS 11.0, *) {
            tmpView.style = NSTableView.Style.automatic
        }
        tmpView.autoresizingMask = NSView.AutoresizingMask.width
        tmpView.rowSizeStyle = NSTableView.RowSizeStyle.custom
        tmpView.usesAutomaticRowHeights = true
        tmpView.rowHeight = 44
        tmpView.selectionHighlightStyle = .regular
        tmpView.allowsColumnResizing = false
        tmpView.allowsColumnSelection = false
        tmpView.allowsColumnReordering = false
        tmpView.headerView = nil
        tmpView.dataSource = self
        tmpView.delegate = self
        return tmpView
    }()
    
    lazy var tableColumn: NSTableColumn = {
        let tmpView = NSTableColumn(identifier: self.kGMTestColumnID)
        tmpView.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        return tmpView
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
        return self.modelList[0].itemList.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        NSTableCellView
        return 88
    }
    
    //Recalculate when the screen moves
//    func tableViewColumnDidResize(_ notification: Notification) {
//      let allIndex = IndexSet(integersIn:0..<self.YOURTABLE.numberOfRows)
//     YOURTABLE.noteHeightOfRows(withIndexesChanged: allIndex)
// }
    
//    func tableViewColumnDidResize(_ notification: Notification) {
//        let allIndex = IndexSet(integersIn: 0..<self.modelList[0].itemList.count)
//        self.tableView.noteHeightOfRows(withIndexesChanged: allIndex)
//    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell = tableView.makeView(withIdentifier: self.kGMTestCellID, owner: self) as? GMTestCell
        if (cell == nil) {
            cell = GMTestCell(frame: NSRect.zero)
        }
        guard let model = self.modelList[0].itemList[row] as? GMTestItemModel else { return cell }
        cell?.titleLabel.string = model.detail
        return cell
    }
}

