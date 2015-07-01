//
//  PresentationController.swift
//  Negspect
//
//  Created by Erik Alfredsson on 30/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {

    let dismissView = UIView()

    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)

        addDismissRecognizer()
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        dismissView.frame = containerView.bounds
        dismissView.alpha = 0.0

        containerView.insertSubview(dismissView, atIndex: 0)
    }

    override func dismissalTransitionWillBegin() {
        self.dismissView.removeFromSuperview()
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let containerView = containerView else {
            return presentingViewController.view.bounds
        }

        return containerView.bounds
    }

    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView, presentedView = presentedView() else {
            return
        }

        dismissView.frame = containerView.bounds
        presentedView.frame = frameOfPresentedViewInContainerView()
    }

    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    private func addDismissRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        dismissView.addGestureRecognizer(tapRecognizer)
    }
}
