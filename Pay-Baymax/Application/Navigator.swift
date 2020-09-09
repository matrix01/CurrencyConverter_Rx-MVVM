//
//  Navigator.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import UIKit

protocol Navigatable {
    var navigator: Navigator? { get set }
}

class Navigator {
    static var `default` = Navigator()

    // MARK: - segues list, all app scenes
    enum Scene {
        case home(viewModel: ViewModel)
    }

    enum Transition {
        case root(in: UIWindow)
        case navigation(type: Int)
        case customModal(type: Int)
        case customPopOver(sourceView: UIView, contentSize: CGSize, arrowDirection: UIPopoverArrowDirection = UIPopoverArrowDirection.up)
        case modal
        case detail
        case alert
        case custom
    }

    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .home(let viewModel):
            let homeVC = UIStoryboard.init(name: "PayHome", bundle: nil).instantiateInitialViewController() as? PayHomeViewController
            homeVC?.setup(viewModel: viewModel, navigator: self)
            return NavigationController(rootViewController: homeVC!)
        }
    }

    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController(animated: true)
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .navigation(type: 0)) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }

    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return
        case .custom: return
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }

        switch transition {
        case .navigation:
            if let nav = sender.navigationController {
                // push controller to navigation stack
                nav.pushViewController(target, animated: true)
            }
        case .customModal:
            // present modally with custom animation
            DispatchQueue.main.async {
                target.modalPresentationStyle = .overFullScreen
                sender.present(target, animated: true, completion: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }
}
