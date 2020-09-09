//
//  RMCurrency.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RealmSwift

class RMCurrencyList: Object {
    @objc dynamic var success: Bool = false
    @objc dynamic var terms: String?
    @objc dynamic var privacy: String?
    var currencies = List<RMCurrrency>()

    override class func primaryKey() -> String? {
        return "#keyPath(id)"
    }
}

extension RMCurrencyList: DomainConvertibleType {
    func asDomain() -> CurrencyList {
        return CurrencyList(success: success,
                            terms: terms,
                            privacy: privacy,
                            currencies: currencies.mapToDomain())
    }
}

class RMCurrrency: Object {
    @objc dynamic var countryName: String?
    @objc dynamic var currencyCode: String?

    override class func primaryKey() -> String? {
        return "currency"
    }
}

extension RMCurrrency: DomainConvertibleType {
    func asDomain() -> Currrency {
        return Currrency(countryName: countryName, currencyCode: currencyCode)
    }
}
