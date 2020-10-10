//
//  SlideInTransition.swift
//  cropTriage
//
//  Created by Blake Carr on 9/26/20.
//

import UIKit

class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = false
    
    let dimmingView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        
//        let tapReg = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let finalWidth = toViewController.view.bounds.width * 0.3
        let finalHeight = toViewController.view.bounds.height
        
        if isPresenting{
            // add gesture to dimming view
//            dimmingView.addGestureRecognizer(tapReg)
            
            // add dimming view
            containerView.addSubview(dimmingView)
            dimmingView.frame = containerView.bounds
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.0
            
            // add menu view controller to container
            containerView.addSubview(toViewController.view)
            // Init frame off screen
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeight)
        }
        
        // animate onto screen
        let transform = {
            self.dimmingView.alpha = 0.5
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
        }
        
        // animate off screen
        let identity = {
            self.dimmingView.alpha = 0.0
            fromViewController.view.transform = .identity
        }
        
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        
        UIView.animate(withDuration: duration, animations: {self.isPresenting ? transform() : identity() } ) {
            (_) in transitionContext.completeTransition(!isCancelled)
        }
        
        
       
    }

}
