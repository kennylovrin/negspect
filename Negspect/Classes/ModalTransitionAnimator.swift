//
//  ModalTransitionAnimator.swift
//  Negspect
//
//  Created by Erik Alfredsson on 29/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

class ModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView() else {
            return
        }

        let centre = presentedView.center
        presentedView.center = CGPoint(x: centre.x, y: presentedView.bounds.size.height)

        containerView.addSubview(presentedView)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10.0, options: .CurveEaseInOut, animations: {
            presentedView.center = centre

            }) { (finished) -> Void in
                transitionContext.completeTransition(finished)
        }
    }
}
