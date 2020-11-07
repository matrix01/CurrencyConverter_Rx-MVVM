//
//  Pay_BaymaxTests.swift
//  Pay-BaymaxTests
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Pay_Baymax

class Pay_BaymaxTests: XCTestCase {

    let provider = NetworkManager()

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testLocalData() {
        //test local data call
        let sources = ["USD", "BDT", "JPY"]
        for source in sources {
            let liveParams = live_get_params(access_key: ApiServer.access_key, source: source)
            let liveRequest = ApiRequest.live(parameters: liveParams)
            let errorMessage = "The operation couldn’t be completed. (Failed to parse data! error 404.)"

            let expectation = XCTestExpectation(description: "Waiting for the API call to return")

            provider.requestLocal(urlRequest: liveRequest.request, type: RateList.self)
                .subscribe(onNext: {list in
                    defer { expectation.fulfill() }
                    let rmList = list.asRealm() // cast to realm success
                    XCTAssert(!rmList.quotes.isEmpty, "Successfully fetched data and converted to Realm object")
                }, onError: { error in
                    defer { expectation.fulfill() }
                    // Error fields are the same as the ones we set above
                    XCTAssertEqual(error.localizedDescription, errorMessage)
                }).disposed(by: rx.disposeBag)

            wait(for: [expectation], timeout: 2.0)
        }
    }

    func test_network_success_Data() {
        //test network api call
        let liveParams = live_get_params(access_key: ApiServer.access_key, source: "USD")
        let liveRequest = ApiRequest.live(parameters: liveParams)
        let errorMessage = "The operation couldn’t be completed. (Failed to parse data! error 404.)"

        let expectation = XCTestExpectation(description: "Waiting for the API call to return")

        provider.request(urlRequest: liveRequest.request, type: RateList.self)
            .subscribe(onNext: {list in
                defer { expectation.fulfill() }
                let rmList = list.asRealm() // cast to realm success
                XCTAssert(!rmList.quotes.isEmpty, "Successfully fetched data and converted to Realm object")
            }, onError: { error in
                defer { expectation.fulfill() }
                // Error fields are the same as the ones we set above
                XCTAssertEqual(error.localizedDescription, errorMessage)
            }).disposed(by: rx.disposeBag)

        wait(for: [expectation], timeout: 2.0)
    }

    func test_network_fail_Data() {
        //test network api call
        let liveParams = live_get_params(access_key: ApiServer.access_key, source: "BDT")
        let liveRequest = ApiRequest.live(parameters: liveParams)
        let errorMessage = "The operation couldn’t be completed. (Failed to parse data! error 404.)"

        let expectation = XCTestExpectation(description: "Waiting for the API call to return")

        provider.request(urlRequest: liveRequest.request, type: RateList.self)
            .subscribe(onNext: {list in
                defer { expectation.fulfill() }
                let rmList = list.asRealm() // cast to realm success
                XCTAssert(!rmList.quotes.isEmpty, "Successfully fetched data and converted to Realm object")
            }, onError: { error in
                defer { expectation.fulfill() }
                // Error fields are the same as the ones we set above
                XCTAssertTrue(errorMessage == error.localizedDescription, errorMessage)
            }).disposed(by: rx.disposeBag)

        wait(for: [expectation], timeout: 2.0)
    }

}
