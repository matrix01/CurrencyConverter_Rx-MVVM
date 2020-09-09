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
import RxRealm
import NSObject_Rx

class PayHomeViewModel: ViewModel, ViewModelType {

    struct Input {
        let trigger: Driver<Void>
    }

    struct Output {
    }

    fileprivate var currencies = BehaviorRelay<CurrencyList?>(value: nil)
    fileprivate var rateList = BehaviorRelay<RateList?>(value: nil)

    override init(provider: NetworkManager) {
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm")
        }

        input.trigger.asObservable()
            .bind(to: rx.loadList)
            .disposed(by: rx.disposeBag)

        currencies
            .bind(to: rx.saveRealm)
            .disposed(by: rx.disposeBag)


        let rmCurrencies = realm.objects(RMCurrencyList.self)

        Observable.arrayWithChangeset(from: rmCurrencies)
            .subscribe(onNext: { array, _ in
                print(array)
            }).disposed(by: rx.disposeBag)

        return Output()
    }
}

fileprivate extension Reactive where Base: PayHomeViewModel {
    var loadList: Binder<Void> {
        Binder(self.base){base, _ in
            if AppUtil.lastUpdate > Date() { return }

            base.loadAvailableCountryList()
            base.loadRatesForCountry()
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
                realm.add(rmCurrency, update: .all)
            }
            print("Saved realm data")
            // last update time
            AppUtil.lastUpdate = Date()
        } catch {
            print("Failed to save realm handover data")
        }
    }
}

fileprivate extension PayHomeViewModel {
    func loadAvailableCountryList() {
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

    func loadRatesForCountry(source: String = "USD") {
        let liveParams = live_get_params(access_key: ApiServer.access_key, source: source)
        let liveRequest = ApiRequest.live(parameters: liveParams)

        provider.request(urlRequest: liveRequest.request, type: RateList.self)
            .subscribe(onNext: {[weak self] list in
                guard let this = self else { return }
                this.rateList.accept(list)
                print(list)
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.errorTracker.accept(error)
            }).disposed(by: rx.disposeBag)
    }
}
