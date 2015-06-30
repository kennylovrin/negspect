//
//  PresentationManager.swift
//  Negspect
//
//  Created by Erik Alfredsson on 30/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

class PresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presentingViewController: source)
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionAnimator()
    }
}
