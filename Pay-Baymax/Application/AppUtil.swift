//
//  AppUtil.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation

public enum AppUtil {
    public static var lastUpdate: Date {
        get {
            return UserDefaults.standard.value(forKey: "last_update_time") as? Date ?? Date()
        }
        set {
            UserDefaults.standard.set(newValue.addingTimeInterval(60*30), forKey: "last_update_time")
            UserDefaults.standard.synchronize()
        }
    }
}
