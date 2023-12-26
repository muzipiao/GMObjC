//
//  main.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/26.
//

import Cocoa

fileprivate let appDelegate = AppDelegate()
NSApplication.shared.delegate = appDelegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
