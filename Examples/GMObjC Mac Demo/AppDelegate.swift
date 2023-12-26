//
//  AppDelegate.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/22.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    public var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 窗口尺寸
        let screenSize = NSScreen.main?.frame.size
        let winWidth = (screenSize?.width ?? 1920) * 0.5
        let winHeight = (screenSize?.height ?? 1080) * 0.5
        let winRect = CGRect(x: winWidth * 0.5, y: winHeight * 0.5, width: winWidth, height: winHeight)
        // 创建 window
        let styleMask: NSWindow.StyleMask = [.titled, .resizable, .miniaturizable, .closable, .fullSizeContentView]
        self.window = NSWindow(contentRect: winRect, styleMask: styleMask, backing: .buffered, defer: false)
        self.window?.minSize = CGSize(width: 400, height: 300)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        // 设置 rootVC
        self.window?.contentViewController = GMMainVC()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

