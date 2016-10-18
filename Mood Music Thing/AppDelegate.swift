//
//  AppDelegate.swift
//  Mood Music Thing
//
//  Created by Vladimir Danila & Alexsander Akers on 10/15/16.
//  Copyright © 2016 Vladimir Danila & Alexsander Akers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func handleURL(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let urlComponents = URLComponents(string: urlString),
            let fragment = urlComponents.fragment
        else {
            return
        }

        let pairs = fragment.characters.split(separator: "&")
        for pair in pairs {
            let components = pair.split(separator: "=")
            let key = String(components[0])
            let value = String(components[1])

            if key == "access_token" {
                UserDefaults.standard.set(value, forKey: SpotifyAccessTokenKey)
            }
        }
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURL), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
    }
}

