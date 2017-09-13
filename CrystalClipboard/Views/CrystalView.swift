//
//  CrystalView.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class CrystalView: UIView {
    
    // MARK: Private properties
    
    let seamlessTileView = UIView()
    let offsetSeamlessTileView = UIView()
    let imageHeight: CGFloat
    
    // MARK: Overrides
    
    required init?(coder aDecoder: NSCoder) {
        guard let image = UIImage(named: "SeamlessAmethyst") else { return nil }
        imageHeight = image.size.height
        
        super.init(coder: aDecoder)
        
        let backgroundColorPatternImage = UIColor(patternImage: image)
        seamlessTileView.backgroundColor = backgroundColorPatternImage
        offsetSeamlessTileView.backgroundColor = backgroundColorPatternImage
        backgroundColor = backgroundColorPatternImage // for its brief appearance during autorotation
        addSubview(seamlessTileView)
        addSubview(offsetSeamlessTileView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        seamlessTileView.layer.removeAnimation(forKey: CrystalView.backgroundAnimationKey)
        offsetSeamlessTileView.layer.removeAnimation(forKey: CrystalView.backgroundAnimationKey)
        var newFrame = frame
        newFrame.size.height = imageHeight
        while newFrame.size.height < frame.height {
            newFrame.size.height += imageHeight
        }
        seamlessTileView.frame = newFrame
        offsetSeamlessTileView.frame = newFrame.offsetBy(dx: 0, dy: -newFrame.height)
        seamlessTileView.layer.add(backgroundAnimation(layer: seamlessTileView.layer), forKey: CrystalView.backgroundAnimationKey)
        offsetSeamlessTileView.layer.add(backgroundAnimation(layer: offsetSeamlessTileView.layer), forKey: CrystalView.backgroundAnimationKey)
    }
}

// MARK: Private

private extension CrystalView {
    private static let yPositionKeyPath = "position.y"
    private static let backgroundAnimationDuration: CFTimeInterval = 6
    private static let backgroundAnimationKey = "com.jzzocc.crystal-clipboard.crystal-view-background-animation-key"
    private static let createSeamlessTileView: () -> UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "SeamlessAmethyst")!)
        return view
    }
    
    private func backgroundAnimation(layer: CALayer) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: CrystalView.yPositionKeyPath)
        animation.fromValue = layer.position.y
        animation.toValue = layer.position.y + layer.bounds.height
        animation.repeatCount = Float.infinity
        animation.duration = CFTimeInterval(layer.bounds.height) / 100.0
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}
