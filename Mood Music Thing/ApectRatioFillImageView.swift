//
//  ApectRatioFillImageView.swift
//  Mood Music Thing
//
//  Created by Vladimir Danila & Alexsander Akers on 15/10/2016.
//  Copyright © 2016 Vladimir Danila & Alexsander Akers. All rights reserved.
//

import Cocoa

class ApectRatioFillImageView: NSView {

    var image: NSImage? {
        didSet {
            if layer == nil {
                layer = CALayer()
            }

            layer?.contentsGravity = kCAGravityResizeAspectFill
            layer?.contents = image
            self.wantsLayer = true
        }
    }

}
