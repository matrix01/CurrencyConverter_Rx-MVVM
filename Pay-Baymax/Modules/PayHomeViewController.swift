//  
//  PayHomeViewController.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class PayHomeViewController: ViewController, UIScrollViewDelegate {

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
        let output = viewModel.transform(input: input)

        let dataSource = RxTableViewSectionedAnimatedDataSource<CurrencySectionModel>(
            configureCell: {[weak self] _, tableview, _, item in
                let cell = tableview.dequeueReusableCell(withIdentifier: CurrencyInfoCell.reuseIdentifier)
                guard let currencyCell = cell as? CurrencyInfoCell else { return cell! }
                guard let this = self else { return cell!}
                currencyCell.bindModel(rate: item)
                _ = this.textInput.rx.textInput <-> currencyCell.multiplier
                return currencyCell
        })

        output.rateItems
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }

    func setupViews() {
        tableView.register(UINib(nibName: "CurrencyInfoCell", bundle: nil),
                           forCellReuseIdentifier: CurrencyInfoCell.reuseIdentifier)
    }
}

extension PayHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
