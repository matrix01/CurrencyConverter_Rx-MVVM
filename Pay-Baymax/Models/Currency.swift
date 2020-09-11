//
//  Currency.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RealmSwift

struct CurrencyList: Codable {
    let success: Bool?
    let terms: String?
    let privacy: String?
    var currencies: [Currrency]?

    enum CodingKeys: String, CodingKey {
        case success
        case terms
        case privacy
        case currencies
    }

    init(success: Bool?, terms: String?, privacy: String?, currencies: [Currrency]?) {
        self.success = success
        self.terms = terms
        self.privacy = privacy
        self.currencies = currencies
    }
}

extension CurrencyList: RealmRepresentable {
    var uid: String {
        return String(0)
    }

    func asRealm() -> RMCurrencyList {
        return RMCurrencyList.build { object in
            object.success = success ?? false
            object.terms = terms
            object.privacy = privacy
            object.currencies.removeAll()
            let rmCurrencies = currencies?.map({ (currency) -> RMCurrrency in
                return currency.asRealm()
            })
            object.currencies.append(objectsIn: rmCurrencies ?? [])
        }
    }
}

extension CurrencyList {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        terms = try container.decodeIfPresent(String.self, forKey: .terms)
        privacy = try container.decodeIfPresent(String.self, forKey: .privacy)
        let currecyList = try container.decodeIfPresent([String: String].self, forKey: .currencies)

        currencies = currecyList.map {
            $0.map { dictionay in
                Currrency(countryName: dictionay.value, currencyCode: dictionay.key)
            }
        }
    }
}

struct Currrency: Codable {
    let countryName: String?
    let currencyCode: String?

    init(countryName: String?, currencyCode: String?) {
        self.countryName = countryName
        self.currencyCode = currencyCode
    }
}

extension Currrency: RealmRepresentable {
    var uid: String {
        return currencyCode ?? ""
    }

    func asRealm() -> some RMCurrrency {
        return RMCurrrency.build{ object in
            object.countryName = countryName
            object.currencyCode = currencyCode
        }
    }
}
