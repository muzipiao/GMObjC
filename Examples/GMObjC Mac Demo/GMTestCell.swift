//
//  GMTestCell.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/25.
//

import Cocoa
import SnapKit

//NSTableCellView
class GMTestCell: NSTableRowView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel)
        self.addSubview(self.contentLabel)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateBgColor(titleBg: NSColor, contentBg: NSColor) {
        self.titleLabel.backgroundColor = titleBg
        self.contentLabel.backgroundColor = contentBg
    }
    
    func updateTxt(title: String?, content: String?) {
        self.titleLabel.string = title ?? ""
        self.contentLabel.string = content ?? ""
        self.titleLabel.sizeToFit()
        self.contentLabel.sizeToFit()
        self.needsUpdateConstraints = true
        self.layoutSubtreeIfNeeded()
    }
    
    private func setupConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Lazy Load
    lazy var titleLabel: NSTextView = {
        let textView = NSTextView(frame: NSRect.zero)
        textView.font = NSFont.systemFont(ofSize: 16)
        textView.textColor = NSColor(red: 47.0/255.0, green: 56.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        textView.textContainer?.lineFragmentPadding = 0 // 一行的首尾默认会再加5的边距
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.textContainer?.lineBreakMode = .byWordWrapping
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = true
        textView.isEditable = false
        return textView
    }()
    
    lazy var contentLabel: NSTextView = {
        let textView = NSTextView(frame: NSRect.zero)
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.textColor = NSColor(red: 94.0/255.0, green: 99.0/255.0, blue: 123.0/255.0, alpha: 1.0)
        textView.textContainer?.lineFragmentPadding = 0 // 一行的首尾默认会再加5的边距
        textView.textContainerInset = NSSize(width: 10, height: 0)
        textView.textContainer?.lineBreakMode = .byWordWrapping
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = true
        textView.isEditable = false
        return textView
    }()
}
