//
//  CentralNavigationController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/2/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class CentralNavigationController: UINavigationController, UINavigationControllerDelegate {

    internal var application: UIApplication!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    let loadingViewController: LoadingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoadingViewController") as! LoadingViewController
    let mainViewController: CentralTabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainViewController") as! CentralTabBarController

    func displayLoadingScreen() {
        loadingViewController.initializeLabelTimer()
        self.pushViewController(loadingViewController, animated: true)
    }

    func hideLoadingScreen() {
        loadingViewController.stopTimer()
        self.popViewControllerAnimated(true)
    }

    func hideLoadingScreenWithError() {
        loadingViewController.stopTimer()
        self.popViewControllerAnimated(true)

        mainViewController.displayLoadingError()
    }

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == UINavigationControllerOperation.Push {
            return PushAnimator()
        }

        if operation == UINavigationControllerOperation.Pop {
            return PopAnimator()
        }
        return nil
    }

}

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        transitionContext.containerView()?.addSubview(toViewController.view)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toViewController.view.alpha = 1.0
        }) {(finished: Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        transitionContext.containerView()?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            fromViewController.view.alpha = 0.0
        }) {(finished: Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
