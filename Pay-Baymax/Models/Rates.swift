//
//  Rates.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RealmSwift

//RateList

struct RateList: Codable {
    let privacy: String?
    let terms: String?
    let success: Bool
    let quotes: [Rate]

    enum CodingKeys: String, CodingKey {
        case success
        case terms
        case privacy
        case quotes
    }
}

extension RateList {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        terms = try container.decodeIfPresent(String.self, forKey: .terms)
        privacy = try container.decodeIfPresent(String.self, forKey: .privacy)
        quotes = try container.decode([String:Double].self, forKey: .quotes).map{ dict in
            Rate(key: dict.key, value: dict.value)
        }
    }
}


class RMRateList: Object {
    @objc dynamic var id = 0
    @objc dynamic var privacy: String?
    @objc dynamic var terms: String?
    @objc dynamic var success: Bool = false
    var quotes = List<RMRate>()
}

extension RateList: RealmRepresentable {
    var uid: String {
        return "0"
    }

    func asRealm() -> some RMRateList {
        return RMRate.build{ object in
            object.privacy = privacy
            object.terms = terms
            object.success = success
            object.quotes.removeAll()
            let rates = quotes.map{$0.asRealm()}
            object.quotes.append(objectsIn: rates)
        }
    }
}

extension RMRateList: DomainConvertibleType {
    func asDomain() -> RateList {
        return RateList(privacy: privacy, terms: terms, success: success, quotes: quotes.mapToDomain())
    }
}

//Rate
struct Rate: Codable {
    let source: String?
    let target: String?
    let value: Double

    init(key: String, value: Double) {
        self.source = key.substring(to: 3)
        self.target = key.substring(from: 3)
        self.value = value
    }

    init(source: String?, target: String?, value: Double) {
        self.source = source
        self.target = target
        self.value = value
    }
}

class RMRate: Object {
    @objc dynamic var source: String?
    @objc dynamic var target: String?
    @objc dynamic var value: Double = 0.0

    override class func primaryKey() -> String? {
        return #keyPath(target)
    }
}

extension RMRate: DomainConvertibleType {
    func asDomain() -> Rate {
        return Rate(source: source, target: target, value: value)
    }
}


extension Rate: RealmRepresentable {
    var uid: String {
        return target ?? ""
    }

    func asRealm() -> some RMRate {
        return RMRate.build{ object in
            object.source = source
            object.target = target
            object.value = value
        }
    }
}
