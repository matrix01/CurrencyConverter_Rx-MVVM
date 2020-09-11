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
import RxGesture

class PayHomeViewController: ViewController, UIScrollViewDelegate {

    @IBOutlet private weak var textInput: UITextField!
    @IBOutlet fileprivate weak var sourceButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet fileprivate weak var pickerView: UIPickerView!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet private weak var sourceView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupViews()
        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = self.viewModel as? PayHomeViewModel else { return }
        let willAppear = rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()

        let input = PayHomeViewModel.Input(trigger: willAppear,
                                           source: pickerView.rx.modelSelected(Currrency.self).asDriver())
        let output = viewModel.transform(input: input)

        let dataSource = RxTableViewSectionedAnimatedDataSource<CurrencySectionModel>(
            configureCell: {[weak self] _, tableview, _, item in
                let cell = tableview.dequeueReusableCell(withIdentifier: CurrencyInfoCell.reuseIdentifier)
                guard let currencyCell = cell as? CurrencyInfoCell else { return cell! }
                guard let this = self else { return cell!}

                currencyCell.bindModel(rate: item)
                this.textInput.rx.text.orEmpty
                    .bind(to: currencyCell.multiplier)
                    .disposed(by: currencyCell.disposeBag)
                return currencyCell
        })

        output.rateItems
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        output.countryItems
            .asObservable()
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return ((element.currencyCode ?? "") + "-" + (element.countryName ?? ""))
        }
        .disposed(by: rx.disposeBag)

        output.errorTracker
            .skip(1)
            .drive(rx.showError)
            .disposed(by: rx.disposeBag)

        output.sourceTitle
            .drive(rx.setSourceTitle)
            .disposed(by: rx.disposeBag)

        output.fetching
            .drive(rx.setFetch)
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }

    func setupViews() {
        tableView.register(UINib(nibName: "CurrencyInfoCell", bundle: nil),
                           forCellReuseIdentifier: CurrencyInfoCell.reuseIdentifier)

        pickerView.isHidden = true
        doneButton.isHidden = true
        noteLabel.isHidden = true

        sourceView.rx.tapGesture()
            .skip(1)
            .mapToVoid()
            .bind(to: rx.showPicker)
            .disposed(by: rx.disposeBag)

        doneButton.rx.tap
            .bind(to: rx.donePicker)
            .disposed(by: rx.disposeBag)
    }
}

fileprivate extension Reactive where Base: PayHomeViewController {
    var showPicker: Binder<Void> {
        Binder(self.base){base, _ in
            base.pickerView.isHidden = false
            base.doneButton.isHidden = false
        }
    }

    var donePicker: Binder<Void> {
        Binder(self.base){base, _ in
            base.pickerView.isHidden = true
            base.doneButton.isHidden = true
        }
    }

    var showError: Binder<Error?> {
        Binder(self.base){base, error in
            print(error?.localizedDescription ?? "")
            base.noteLabel.isHidden = false
        }
    }

    var setSourceTitle: Binder<String> {
        Binder(self.base){base, title in
            base.sourceButton.setTitle(title, for: .normal)
        }
    }

    var setFetch: Binder<Bool> {
        Binder(self.base){base, fetch in
            if fetch {
                base.noteLabel.isHidden = true
            }
        }
    }
}

extension PayHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//RxDataSourceModel
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
