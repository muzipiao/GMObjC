//
//  ViewController.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/22.
//

import Cocoa

class GMMainVC: NSViewController {
    
    private let kGMTestCellID = NSUserInterfaceItemIdentifier("kGMTestCellID")
    
    override func loadView() {
        super.loadView()
        guard let winSize = NSScreen.main?.frame.size else { return }
        let winWidth = winSize.width * 0.5
        let winHeight = winSize.height * 0.5
        self.view.frame = CGRect(x: 0, y: 0, width: winWidth, height: winHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.tableView)
        print(self.scrollView)
        print(self.view)
        self.view.window?.delegate = self
        self.view.layer?.backgroundColor = NSColor.green.cgColor
        self.view.addSubview(self.scrollView)
        self.tableView.reloadData()
    }
    
    // MARK: - Lazy Load
    lazy var scrollView: NSScrollView = {
        let tmpView = NSScrollView(frame: self.view.bounds)
        tmpView.documentView = self.tableView
        return tmpView
    }()
    
    lazy var tableView: NSTableView = {
        let tmpView = NSTableView(frame: self.view.bounds)
        if #available(macOS 11.0, *) {
            tmpView.style = .fullWidth
        }
        tmpView.dataSource = self
        tmpView.delegate = self
//        let cellNibName = NSNib.Name(reflecting: GMTestCell.self)
//        tmpView.register(NSNib(nibNamed: cellNibName, bundle: nil), forIdentifier: kGMTestCellID)
//        tableView.register(GMTestCell.self, forIdentifier: NSUserInterfaceItemIdentifier("CustomCellIdentifier"))
        return tmpView
    }()

}

extension GMMainVC: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        print("windowDidResize===\(notification)")
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        print("windowDidEndLiveResize===\(notification)")
    }
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource
extension GMMainVC: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: kGMTestCellID, owner: self)
        cell?.layer?.backgroundColor = NSColor.orange.cgColor
        return cell
    }
}

