//
//  CustomableAlertTopSlideDecorator.swift
//  Comp
//
//  Created by Egehan KARAKÖSE (Dijital Kanallar Uygulama Geliştirme Müdürlüğü) on 27.03.2022.
//

import Foundation

public class CustomableAlertTopSlideDecorator: CustomableAlertDecoratorProtocol {
   
    public var mainView: UIView?
    
    public var customView: UIView?
    
    public var onClose: (() -> Void)?
    
    public var closeTappedAround: Bool = true
    
    public var closeableZoneRatio: CGFloat = 0.3
    
    public var touchBeganPosition: CGPoint?
    
    public var canMove: Bool = true
    
    public var animationTime: TimeInterval = 0.4
    
    private var isMoving: Bool = false
    private var isProcessing: Bool = false
    
    public init() {
        self.canMove = true
        self.animationTime = 0.4
    }
    
    public init(canMove: Bool = true, animationTime: TimeInterval = 0.4) {
        self.canMove = canMove
        self.animationTime = animationTime
    }
    
    public func setConstraints() {
        guard let mainView = self.mainView else { return }
        customView?.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        customView?.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        customView?.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        
        mainView.layoutIfNeeded()
    }
    
    public func openingAnimate() {
        guard let customView = self.customView else { return }
        customView.alpha = 0.0
        customView.frame.origin.y -= customView.frame.height
            
        UIView.animate(withDuration: animationTime, animations: {
            customView.alpha = 1.0
            customView.frame.origin.y = 0
        })
    }
    
    public func closingAnimate() {
        guard let customView = self.customView else { return }
        isProcessing = true
        UIView.animate(withDuration: animationTime, animations: {
            customView.frame.origin.y -= customView.frame.height
            customView.alpha = 0.0
        }) { [weak self] (_) in
            self?.customView = nil
            self?.onClose?()
        }
    }
    
    private func checkViewLocation(touch: UITouch) -> Bool {
        guard let customView = self.customView, let mainView = self.mainView else { return false}
        let location = touch.location(in: mainView)
        
        if location.x >= customView.frame.origin.x && location.x <= customView.frame.origin.x + customView.frame.width {
            if location.y >= customView.frame.origin.y && location.y <= customView.frame.origin.y + customView.frame.height {
                return true
            }
        }
    
        return false
    }
    
    public func touchesBegan(touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchIsInCustomView = checkViewLocation(touch: touch)
        if closeTappedAround && !touchIsInCustomView {
            isProcessing = true
            closingAnimate()
        }

        if canMove && touchIsInCustomView {
            touchBeganPosition = touch.location(in: mainView)
            isMoving = true
        }
    }
    
    public func touchesMoved(touches: Set<UITouch>, event: UIEvent?) {
        guard let customView = self.customView else { return }
        guard let touch = touches.first else { return }
        guard let touchBeganPosition = self.touchBeganPosition else { return }
        guard let mainView = self.mainView else { return }
        if isProcessing { return }
        
        if isMoving && checkViewLocation(touch: touch) {
            let currentTouchLocation = touch.location(in: mainView)
            let distanceY = touchBeganPosition.y - currentTouchLocation.y
           
            if distanceY >= 0 && distanceY <= customView.frame.height {
                customView.frame.origin.y = -distanceY
            
                if customView.frame.origin.y <= customView.frame.height / -2 {
                    closingAnimate()
                }
            }
        }
    }
    
    public func touchesEnd(touches: Set<UITouch>, event: UIEvent?) {
        guard let customView = self.customView, let touch = touches.first, let mainView = self.mainView,
            let touchBeganPosition = self.touchBeganPosition, !isProcessing else { return }
        
        if checkViewLocation(touch: touch) {
            let currentTouchLocation = touch.location(in: mainView)
            let distanceY = currentTouchLocation.y - touchBeganPosition.y
            
            if distanceY > customView.frame.height * closeableZoneRatio {
                resetCustomViewPosition(customView: customView, mainView: mainView)
            }
        } else {
            resetCustomViewPosition(customView: customView, mainView: mainView)
        }
        
        isMoving = false
        self.touchBeganPosition = nil
    }
    
    private func resetCustomViewPosition(customView: UIView, mainView: UIView) {
        isProcessing = true
        UIView.animate(withDuration: animationTime / 2, animations: {
            customView.frame.origin.y = 0
        }, completion: { [weak self] _ in
            self?.isProcessing = false
        })
    }
}
