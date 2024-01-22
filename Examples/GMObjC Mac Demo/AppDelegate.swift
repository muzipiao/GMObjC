//
//  AppDelegate.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/22.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainVC = GMMainVC()
        let winW = NSWidth(NSScreen.screens[0].frame) * 0.5;
        let winH = NSHeight(NSScreen.screens[0].frame) * 0.5;
        let winRect = NSRect(x: 0, y: 0, width: winW, height: winH);
        let styleMask: NSWindow.StyleMask = [.titled, .resizable, .miniaturizable, .closable, .fullSizeContentView]
        window = NSWindow(contentRect: winRect, styleMask: styleMask, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.minSize = NSMakeSize(winW * 0.5, winH * 0.5)
        window.center()
        window.title = "GMObjC Mac Demo"
        window.contentViewController = mainVC;
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

