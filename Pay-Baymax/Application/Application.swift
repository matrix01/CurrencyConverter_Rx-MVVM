//
//  Application.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import UIKit

final class Application: NSObject {
    static let shared = Application()
    var window: UIWindow?
    var provider: NetworkManager?
    let navigator: Navigator

    override private init() {
        navigator = Navigator.default
        super.init()
        updateProvider()
    }

    private func updateProvider() {
        provider = NetworkManager()
    }

    func presentInitialScreen(in window: UIWindow?) {
        guard let window = window, let provider = provider else {
            print("Could not init screen")
            return
        }

        let viewModel = PayHomeViewModel(provider: provider)
        self.navigator.show(segue: .home(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }
}
