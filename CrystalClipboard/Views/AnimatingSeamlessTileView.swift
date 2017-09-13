//
//  AnimatingSeamlessTileView.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class AnimatingSeamlessTileView: UIView {
    
    // MARK: Private properties
    
    private let seamlessTileView = UIView()
    private let offsetSeamlessTileView = UIView()
    private var imageHeight: CGFloat = 0
    
    // MARK: IBInspectable
    
    @IBInspectable
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            imageHeight = image.size.height
            let color = UIColor(patternImage: image)
            seamlessTileView.backgroundColor = color
            offsetSeamlessTileView.backgroundColor = color
            backgroundColor = color // for its brief appearance during autorotation
        }
    }
    
    @IBInspectable
    var speed: CGFloat = 100
    
    // MARK: Overrides
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(seamlessTileView)
        addSubview(offsetSeamlessTileView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        seamlessTileView.layer.removeAnimation(forKey: AnimatingSeamlessTileView.backgroundAnimationKey)
        offsetSeamlessTileView.layer.removeAnimation(forKey: AnimatingSeamlessTileView.backgroundAnimationKey)
        var newFrame = frame
        newFrame.size.height = imageHeight
        while newFrame.size.height < frame.height {
            newFrame.size.height += imageHeight
        }
        seamlessTileView.frame = newFrame
        offsetSeamlessTileView.frame = newFrame.offsetBy(dx: 0, dy: -newFrame.height)
        seamlessTileView.layer.add(backgroundAnimation(layer: seamlessTileView.layer), forKey: AnimatingSeamlessTileView.backgroundAnimationKey)
        offsetSeamlessTileView.layer.add(backgroundAnimation(layer: offsetSeamlessTileView.layer), forKey: AnimatingSeamlessTileView.backgroundAnimationKey)
    }
}

// MARK: Private

private extension AnimatingSeamlessTileView {
    private static let yPositionKeyPath = "position.y"
    private static let backgroundAnimationKey = "com.jzzocc.crystal-clipboard.animating-seamless-tile-view-background-animation-key"
    
    private func backgroundAnimation(layer: CALayer) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: AnimatingSeamlessTileView.yPositionKeyPath)
        animation.fromValue = layer.position.y
        animation.toValue = layer.position.y + layer.bounds.height
        animation.repeatCount = Float.infinity
        animation.duration = CFTimeInterval(layer.bounds.height / speed)
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}
