//
//  NetworkManager.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import RxSwift

class NetworkManager {
    func request<Result>(urlRequest: URLRequest,
                         type: Result.Type,
                         decoder: JSONDecoder = JSONDecoder()) -> Observable<Result> where Result: Codable {
        return Observable.create { obs in
            URLSession.shared.rx.response(request: urlRequest).subscribe(
                onNext: { response in
                    print(response.data)
                    let response = Response(data: response.data)
                    guard let decoded = response.decode(Result.self) else {
                        obs.onError(NSError(domain: "Failed to parse data!", code: 404, userInfo: nil))
                        return
                    }
                    return obs.onNext(decoded)
            },
                onError: {error in
                    obs.onError(error)
            })
        }
    }
}


struct Response {
    fileprivate var data: Data
    init(data: Data) {
        self.data = data
    }
}

struct PError: Decodable {
    let code: Int
    let description: String
}


extension Response {
    public func decode<T: Codable>(_ type: T.Type) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let response = try jsonDecoder.decode(T.self, from: data)
            return response
        } catch let error {
            return PError(code: 404, description: error.localizedDescription) as? T
        }
    }
}
