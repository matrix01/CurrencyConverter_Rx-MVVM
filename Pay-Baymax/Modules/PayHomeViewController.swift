//  
//  PayHomeViewController.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import UIKit

class PayHomeViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray

        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = self.viewModel as? PayHomeViewModel else { return }
        let willAppear = rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()

        let input = PayHomeViewModel.Input(trigger: willAppear)
        _ = viewModel.transform(input: input)
    }
}
