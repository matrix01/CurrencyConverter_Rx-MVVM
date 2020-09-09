//
//  CurrencyInfoCell.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class CurrencyInfoCell: UITableViewCell {

    static let reuseIdentifier = "CurrencyInfoCell"

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var conversionLabel: UILabel!

    fileprivate var model: Rate?
    let multiplier = BehaviorRelay<String>(value: "0.0")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindModel(rate: Rate) {
        sourceLabel.text = "Source: \(rate.source ?? "")"
        targetLabel.text = "Target: \(rate.target ?? "")"
        rateLabel.text = "Rate: \(rate.value)"

        multiplier.asDriver()
            .drive(rx.setTotal)
            .disposed(by: rx.disposeBag)

        model = rate
    }
}

fileprivate extension Reactive where Base: CurrencyInfoCell {
    var setTotal: Binder<String> {
        Binder(self.base) {base, input in
            if let value: Double = Double(input), let rate = base.model?.value {
                let total = rate * value
                base.conversionLabel.text = "Result:\n" + total.removeZero
            }else {
                base.conversionLabel.text = "Result:\n 0.0"
            }
        }
    }
}

extension Double {
    var removeZero:String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 5
        return nf.string(from: NSNumber(value: self))!
    }
}
