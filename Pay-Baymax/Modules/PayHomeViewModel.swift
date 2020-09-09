//  
//  PayHomeViewModel.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx

class PayHomeViewModel: ViewModel, ViewModelType {

    struct Input {
        let trigger: Driver<Void>
    }

    struct Output {
    }

    override init(provider: NetworkManager) {
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {
        input.trigger.asObservable()
            .bind(to: rx.loadList)
            .disposed(by: rx.disposeBag)
        return Output()
    }
}

fileprivate extension Reactive where Base: PayHomeViewModel {
    var loadList: Binder<Void> {
        Binder(self.base){base, _ in
            base.loadAvailableCountryList()
        }
    }
}

fileprivate extension PayHomeViewModel {
    func loadAvailableCountryList() {
        print("loading")
        let listParams = list_get_params(access_key: ApiServer.access_key)
        let listRequest = ApiRequest.list(parameters: listParams)
        provider.request(urlRequest: listRequest.request, type: CurrencyList.self)
            .subscribe(onNext: { (list) in
                print(list)
            }, onError: { (error) in
                print(error)
            }).disposed(by: rx.disposeBag)

    }
}
