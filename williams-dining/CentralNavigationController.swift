//
//  CentralNavigationController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/2/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

public class CentralNavigationController: UINavigationController, UINavigationControllerDelegate {

    internal var application: UIApplication!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    let loadingViewController: LoadingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
    let mainViewController: CentralTabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! CentralTabBarController

    func displayLoadingScreen() {
        loadingViewController.initializeLabelTimer()
        self.pushViewController(loadingViewController, animated: true)
    }

    func hideLoadingScreen() {
        // this is lagging
        loadingViewController.stopTimer()
        self.popViewController(animated: true)
    }

    func hideLoadingScreenWithError() {
        loadingViewController.stopTimer()
        self.popViewController(animated: true)

        mainViewController.displayLoadingError()
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == UINavigationControllerOperation.push {
            return PushAnimator()
        }

        if operation == UINavigationControllerOperation.pop {
            return PopAnimator()
        }
        return nil
    }

}

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        transitionContext.containerView().addSubview(toViewController.view)
        UIView.animate(withDuration: self.transitionDuration(transitionContext), animations: {
            toViewController.view.alpha = 1.0
        }) {(finished: Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        transitionContext.containerView().insertSubview(toViewController.view, belowSubview: fromViewController.view)
        UIView.animate(withDuration: self.transitionDuration(transitionContext), animations: {
            fromViewController.view.alpha = 0.0
        }) {(finished: Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
