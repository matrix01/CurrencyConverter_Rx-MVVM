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
        let rateItems: Driver<[CurrencySectionModel]>
    }

    var currentInput: Double = 1.0

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

        let elements = BehaviorRelay<[CurrencySectionModel]>(value: [])
        let rmRates = realm.objects(RMRateList.self)

        Observable.arrayWithChangeset(from: rmRates)
            .subscribe(onNext: {[weak self] array, _ in
                guard let this = self else { return }
                guard let first = array.first?.asDomain() else {return}
                let conversion = first.quotes.map { rate -> CurrencyInfoModel in
                    return CurrencyInfoModel(source: rate.source ?? "",
                                             target: rate.target ?? "",
                                             rate: rate.value,
                                             conversion: this.currentInput * rate.value)
                }
                let sectioned = CurrencySectionModel(items: conversion.sorted(by: { (first, second) -> Bool in
                    first.target < second.target
                }))
                elements.accept([sectioned])
            }).disposed(by: rx.disposeBag)

        return Output(rateItems: elements.asDriver())
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
}

fileprivate extension PayHomeViewModel {
    func loadAvailableCountryList() {
        let listParams = list_get_params(access_key: ApiServer.access_key)
        let listRequest = ApiRequest.list(parameters: listParams)

        provider.request(urlRequest: listRequest.request, type: CurrencyList.self)
            .subscribe(onNext: {list in
                list.asRealm().save()
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.errorTracker.accept(error)
            }).disposed(by: rx.disposeBag)

    }

    func loadRatesForCountry(source: String = "USD") {
        let liveParams = live_get_params(access_key: ApiServer.access_key, source: source)
        let liveRequest = ApiRequest.live(parameters: liveParams)

        provider.request(urlRequest: liveRequest.request, type: RateList.self)
            .subscribe(onNext: {list in
                list.asRealm().save()
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.errorTracker.accept(error)
            }).disposed(by: rx.disposeBag)
    }
}
