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
        let source: Driver<[Currrency]>
    }

    struct Output {
        let sourceTitle: Driver<String>
        let rateItems: Driver<[CurrencySectionModel]>
        let countryItems: Driver<[Currrency]>
        let errorTracker: Driver<Error?>
        let fetching: Driver<Bool>
    }

    var currentInput: Double = 1.0
    var currentSource = BehaviorRelay<String>(value: "USD")

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

        input.source.asObservable()
            .bind(to: rx.newSource)
            .disposed(by: rx.disposeBag)

        let elements = BehaviorRelay<[CurrencySectionModel]>(value: [])
        let rmRates = realm.objects(RMRateList.self)

        Observable.arrayWithChangeset(from: rmRates)
            .subscribe(onNext: {array, _ in
                let arrayBySource = array.first {[weak self] ratelist -> Bool in
                    guard let this = self else { return false}
                    return ratelist.id == this.currentSource.value
                }
                guard let rates = arrayBySource?.asDomain().quotes else {return}
                let newRates = rates.map { (rate) -> Rate in
                    let rmObject = realm.object(ofType: RMCurrrency.self, forPrimaryKey: rate.target)
                    let rmObject1 = realm.object(ofType: RMCurrrency.self, forPrimaryKey: rate.source)
                    return Rate(source: rmObject1?.countryName, target: rmObject?.countryName, value: rate.value)
                }
                let sectioned = CurrencySectionModel(items: newRates.sorted(by: { (first, second) -> Bool in
                    (first.target ?? "") < (second.target ?? "")
                }))
                elements.accept([sectioned])
            }).disposed(by: rx.disposeBag)

        let countryList = BehaviorRelay<[Currrency]>(value: [])
        let rmCurrencies = realm.objects(RMCurrencyList.self)

        Observable.arrayWithChangeset(from: rmCurrencies)
            .subscribe(onNext: {array, _ in
                guard let countries = array.first?.asDomain().currencies?.sorted(by: { (first, second) -> Bool in
                    (first.countryName ?? "") < (second.countryName ?? "")
                }) else {return}
                countryList.accept(countries)
            }).disposed(by: rx.disposeBag)

        return Output(sourceTitle: currentSource.asDriver(),
                      rateItems: elements.asDriver(),
                      countryItems: countryList.asDriver(),
                      errorTracker: errorTracker.asDriver(),
                      fetching: isFetching.asDriver())
    }
}

fileprivate extension Reactive where Base: PayHomeViewModel {
    var loadList: Binder<Void> {
        Binder(self.base){base, _ in
            // Call only if 30 mins has passed since last call
            if AppUtil.lastUpdate > Date() { return }

            base.loadAvailableCountryList()
            base.loadRatesForCountry()
        }
    }

    var newSource: Binder<[Currrency]> {
        Binder(self.base){base, sourceList in
            guard let source = sourceList.first?.currencyCode else { return }
            base.currentSource.accept(source)
            base.loadRatesForCountry(source: source)
        }
    }
}

fileprivate extension PayHomeViewModel {

    //If api return an error calculate locally
    func calculateLocally(from:String, to:String, amount:Double) {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm")
        }
        if currentSource.value == "USD" {
            return
        }
        let rateMain = realm.object(ofType: RMRateList.self, forPrimaryKey: "USD")
        guard let rates = rateMain?.quotes else {return}
        guard let toRate = rates.first(where: {$0.target == to}) else {return}
        let multiplier = 1 / toRate.value

        var newRates:[Rate] = []
        for fromRate in rates {
            let result = multiplier * fromRate.value
            let newRate = Rate(source: currentSource.value, target: fromRate.target, value: result)

            newRates.append(newRate)
        }
        let rateList = RateList.init(privacy: "",
                                     terms: "",
                                     success: false,
                                     source: currentSource.value,
                                     quotes: newRates)
        try! realm.write {
            realm.add(rateList.asRealm(), update: .all)
        }
    }

    //Fetch available countries
    func loadAvailableCountryList() {
        let listParams = list_get_params(access_key: ApiServer.access_key)
        let listRequest = ApiRequest.list(parameters: listParams)

        isFetching.accept(true)
        provider.request(urlRequest: listRequest.request, type: CurrencyList.self)
            .subscribe(onNext: {[weak self] list in
                list.asRealm().save()
                guard let this = self else { return }
                this.isFetching.accept(false)
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.isFetching.accept(false)
                this.errorTracker.accept(error)
            }).disposed(by: rx.disposeBag)

    }

    //Fetch the currency for Source data
    func loadRatesForCountry(source: String = "USD") {
        let liveParams = live_get_params(access_key: ApiServer.access_key, source: source)
        let liveRequest = ApiRequest.live(parameters: liveParams)

        isFetching.accept(true)
        provider.request(urlRequest: liveRequest.request, type: RateList.self)
            .subscribe(onNext: {[weak self] list in
                let rmList = list.asRealm()
                guard let this = self else { return }
                rmList.id = this.currentSource.value
                rmList.save()
                this.isFetching.accept(false)
            }, onError: {[weak self] error in
                guard let this = self else { return }
                this.calculateLocally(from: "", to: source, amount: 1.0)
                this.errorTracker.accept(error)
                this.isFetching.accept(false)
            }).disposed(by: rx.disposeBag)
    }
}
