//
//  GMTestCell.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/25.
//

import Cocoa

class GMTestCell: NSTableCellView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.layer?.backgroundColor = NSColor.red.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
