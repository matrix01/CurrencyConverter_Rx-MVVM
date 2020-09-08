//
//  ViewModelType.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

class ViewModel: NSObject {

    let provider: NetworkManager
    var isFetching = BehaviorRelay<Bool>(value: false)
    let errorTracker = BehaviorRelay<Error?>(value: nil)

    init(provider: NetworkManager) {
        self.provider = provider
        super.init()
    }

    func eraseToViewModel() -> ViewModel {
        self as ViewModel
    }
}
