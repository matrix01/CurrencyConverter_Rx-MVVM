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
import RealmSwift
import NSObject_Rx

class PayHomeViewModel: ViewModel, ViewModelType {

    struct Input {
        let trigger: Driver<Void>
    }

    struct Output {
    }

    fileprivate var currencies = BehaviorRelay<CurrencyList?>(value: nil)

    override init(provider: NetworkManager) {
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {
        input.trigger.asObservable()
            .bind(to: rx.loadList)
            .disposed(by: rx.disposeBag)

        currencies
            .bind(to: rx.saveRealm)
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

    var saveRealm: Binder<CurrencyList?> {
        Binder(self.base) {base, currList in
            base.saveRealmObject(currencyList: currList)
        }
    }
}

fileprivate extension PayHomeViewModel {
    func saveRealmObject(currencyList: CurrencyList?){
        guard let rmCurrency = currencyList?.asRealm() else { return }
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(RMCurrencyList.self))
                realm.add(rmCurrency)
            }
        } catch {
            print("Failed to save realm handover data")
        }
    }
}

fileprivate extension PayHomeViewModel {
    func loadAvailableCountryList() {
        print("loading")
        let listParams = list_get_params(access_key: ApiServer.access_key)
        let listRequest = ApiRequest.list(parameters: listParams)
        provider.request(urlRequest: listRequest.request, type: CurrencyList.self)
            .subscribe(onNext: {[weak self] list in
                guard let this = self else { return }
                this.currencies.accept(list)
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.errorTracker.accept(error)
            }).disposed(by: rx.disposeBag)

    }
}
