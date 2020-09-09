//  
//  PayHomeViewController.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import UIKit
import RxDataSources

class PayHomeViewController: ViewController {

    @IBOutlet private weak var textInput: UITextField!
    @IBOutlet private weak var sourceButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray

        setupViews()
        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = self.viewModel as? PayHomeViewModel else { return }
        let willAppear = rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()

        let input = PayHomeViewModel.Input(trigger: willAppear)
        _ = viewModel.transform(input: input)

        
    }

    func setupViews() {
        tableView.register(UINib(nibName: "CurrencyInfoCell", bundle: nil),
                           forCellReuseIdentifier: CurrencyInfoCell.reuseIdentifier)
    }
}

struct CurrencySectionModel {
    var items: [Rate]
}

extension CurrencySectionModel: AnimatableSectionModelType, IdentifiableType {
    typealias Identity = String

    var identity: String {
        return "CurrencySectionModel"
    }

    init(original: CurrencySectionModel, items: [Rate]) {
        self = original
        self.items = items
    }
}
