//
//  SwitchControl.swift
//  FCComponents Framework
//
//  Created by Alejandro Barros Cuetos on 03/07/14.
//  Copyright (c) 2014 Alejandro Barros Cuetos. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

@IBDesignable public class SwitchControl: NSButton {
    
    let kDefaultTintColor = NSColor.blueColor()
    let kBorderWidth : CGFloat = 1.0
    let kGoldenRatio : CGFloat = 1.61803398875
    let kDecreasedGoldenRatio : CGFloat = 1.38
    let knobBackgroundColor = NSColor(calibratedWhite: 1, alpha: 1)
    let kDisabledBorderColor = NSColor(calibratedWhite: 0, alpha: 0.2)
    let kDisabledBackgroundColor = NSColor.clearColor()
    let kAnimationDuration = 0.4
    let kEnabledOpacity: CFloat = 0.8
    let kDisabledOpacity: CFloat = 0.5
    
    @IBInspectable var isOn : Bool {
        didSet{
            self.refreshLayer()
        }
    }
    @IBInspectable var tintColor : NSColor {
        didSet {
            self.refreshLayer()
        }
    }
    
    var isActive: Bool = false
    var hasDragged: Bool = false
    var isDragginToOn: Bool = false
    var rootLayer: CALayer = CALayer()
    var backgroundLayer: CALayer = CALayer()
    var knobLayer: CALayer = CALayer()
    var knobInsideLayer: CALayer = CALayer()
    
    override public var frame: NSRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.refreshLayerSize()
        }
    }
    
    override public var acceptsFirstResponder: Bool { get { return true } }
    
    override public var enabled: Bool {
        get { return super.enabled }
        set{
            super.enabled = newValue
            self.refreshLayer()
        }
    }
    
    // MARK: - Initializers
    init(isOn: Bool, frame: NSRect, textOn: String?, textOff: String?, tintColor: NSColor?) {
        
        self.isOn = isOn
        if let optionalTintColor = tintColor {
            self.tintColor = optionalTintColor
        } else {
            self.tintColor = kDefaultTintColor
        }
        
        super.init(frame: frame)
        
        self.setupLayers()
    }
    
    init(coder: NSCoder!) {
        self.isOn = false;
        self.tintColor = kDefaultTintColor
        
        super.init(coder: coder)
    }
    
    convenience init(frame frameRect: NSRect) {
        self.init(isOn: false, frame: frameRect, textOn: nil, textOff: nil, tintColor: nil)
    }
    
    // MARK: -  Setup
    func setupLayers() {
        layer = rootLayer
        wantsLayer = true

        backgroundLayer.bounds = rootLayer.bounds
        backgroundLayer.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundLayer.borderWidth = kBorderWidth
        
        rootLayer.addSublayer(backgroundLayer)
        
        knobLayer.frame = rectForKnob()
        knobLayer.autoresizingMask = CAAutoresizingMask.LayerHeightSizable
        knobLayer.backgroundColor = knobBackgroundColor.CGColor
        knobLayer.shadowColor = NSColor.blackColor().CGColor
        knobLayer.shadowOffset = CGSize(width: 0, height: -2)
        knobLayer.shadowRadius = 1
        knobLayer.shadowOpacity = 0.3
        
        rootLayer.addSublayer(knobLayer)
        
        knobInsideLayer.frame = knobLayer.bounds
        knobInsideLayer.backgroundColor = NSColor.whiteColor().CGColor
        knobInsideLayer.shadowColor = NSColor.blackColor().CGColor
        knobInsideLayer.shadowOffset = CGSize(width: 0, height: 0)
        knobInsideLayer.shadowRadius = 1
        knobInsideLayer.shadowOpacity = 0.35
        
        knobLayer.addSublayer(knobInsideLayer)
        
        refreshLayerSize()
        refreshLayer()
    }
    
    func rectForKnob() -> CGRect {
        let height = knobHeightForSize(backgroundLayer.bounds.size)
        let width = (!self.isActive) ? (NSWidth(backgroundLayer.bounds) - 2 * kBorderWidth) * 1 / kGoldenRatio : (NSWidth(backgroundLayer.bounds) - 2 * kBorderWidth) * 1 / kDecreasedGoldenRatio
        
        let x = ((!hasDragged && !isOn) || (hasDragged && !isDragginToOn)) ? kBorderWidth : NSWidth(backgroundLayer.bounds) - width - kBorderWidth
        
        return CGRect(x: x, y: kBorderWidth, width: width, height: height)
    }
    
    func knobHeightForSize(size: NSSize) -> CGFloat {
        return size.height - kBorderWidth * 2
    }
    
    func refreshLayerSize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        knobLayer.frame = rectForKnob()
        knobInsideLayer.frame = knobLayer.bounds
            
        backgroundLayer.cornerRadius = backgroundLayer.bounds.size.height / 2
        knobLayer.cornerRadius = knobLayer.bounds.size.height / 2
        knobInsideLayer.cornerRadius = knobLayer.bounds.size.height / 2

        CATransaction.commit()
    }
    
    func refreshLayer () {
        CATransaction.begin()
        CATransaction.setAnimationDuration(kAnimationDuration)
        
        if (hasDragged && isDragginToOn) || (!hasDragged && isOn) {
            backgroundLayer.borderColor = tintColor.CGColor
            backgroundLayer.backgroundColor = tintColor.CGColor
        } else {
            backgroundLayer.borderColor = kDisabledBorderColor.CGColor
            backgroundLayer.backgroundColor = kDisabledBackgroundColor.CGColor
        }
        
        if !isActive {
            rootLayer.opacity = kEnabledOpacity
        } else {
            rootLayer.opacity = kDisabledOpacity
        }
        
        if !hasDragged {
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.25, 1.5, 0.5, 1.0))
        }
        
        knobLayer.frame = rectForKnob()
        knobInsideLayer.frame = knobLayer.bounds
        
        CATransaction.commit()
    }
    
    // MARK: - NSView
    override public func acceptsFirstMouse(theEvent: NSEvent!) -> Bool {
        return true
    }
    
    // MARK: - NSResponder
    override public func mouseDown(theEvent: NSEvent!) {
        if !super.enabled {
            isActive = true
            refreshLayer()
        }
    }
    
    override public func mouseDragged(theEvent: NSEvent!)  {
        if super.enabled {
            hasDragged = true
            
            let dragginPoint: NSPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
            isDragginToOn = dragginPoint.x >= NSWidth(bounds) / 2.0
            
            refreshLayer()
        }
    }
    
    override public func mouseUp(theEvent: NSEvent!)  {
        if super.enabled {
            isActive = false
            
            let isOn: Bool = (!hasDragged) ? !self.isOn : isDragginToOn
            let invokeTargetAction: Bool = isOn != self.isOn
            
            self.isOn = isOn
            
            hasDragged = false
            isDragginToOn = false
            
            refreshLayer()
            if invokeTargetAction {
                cell().performClick(self)
            }
        }
    }
}
