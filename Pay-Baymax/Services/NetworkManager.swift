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
                    #if DEBUG
                    print(response.data)
                    print(response)
                    #endif
                    let response = Response(data: response.data)
                    guard let decoded = response.decode(Result.self) else {
                        obs.onError(NSError(domain: "Failed to parse data!", code: 404, userInfo: nil))
                        return
                    }
                    obs.onNext(decoded)
            },
                onError: {error in
                    obs.onError(error)
            })
        }
    }
}

//Only for testing locally because free plan doesn't support source other than USD
//Please ignore force cast
extension NetworkManager {
    func requestLocal<Result>(urlRequest: URLRequest,
                         type: Result.Type,
                         decoder: JSONDecoder = JSONDecoder()) -> Observable<Result> where Result: Codable {
        return Observable.create { obs in
            var source = "usd"
            if (urlRequest.url?.absoluteString.contains("BDT"))! {
                source = "bdt"
            }else if (urlRequest.url?.absoluteString.contains("JPY"))! {
                source = "jpy"
            }

            if let url = Bundle.main.url(forResource: source, withExtension: "json"), let data = try? Data(contentsOf: url) {
                let response = Response(data: data)
                if let decoded = response.decode(Result.self) {
                    obs.onNext(decoded)
                }
            }else {
                obs.onError(NSError(domain: "Failed to parse data!", code: 404, userInfo: nil))
            }


            return Disposables.create()
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
