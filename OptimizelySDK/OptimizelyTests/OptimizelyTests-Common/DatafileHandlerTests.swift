/****************************************************************************
* Copyright 2019, Optimizely, Inc. and contributors                        *
*                                                                          *
* Licensed under the Apache License, Version 2.0 (the "License");          *
* you may not use this file except in compliance with the License.         *
* You may obtain a copy of the License at                                  *
*                                                                          *
*    http://www.apache.org/licenses/LICENSE-2.0                            *
*                                                                          *
* Unless required by applicable law or agreed to in writing, software      *
* distributed under the License is distributed on an "AS IS" BASIS,        *
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
* See the License for the specific language governing permissions and      *
* limitations under the License.                                           *
***************************************************************************/

import XCTest

class DatafileHandlerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if (!FileManager.default.fileExists(atPath: url.path)) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                }
                catch {
                    print(error)
                }
                
            }
        }

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDatafileHandler() {
        
        let handler = DefaultDatafileHandler()
        
        let data = handler.downloadDatafile(sdkKey: "fakeSDKKey")
        XCTAssertNil(data)
        
        let notLoaded = handler.loadSavedDatafile(sdkKey: "asdfdasfafafsafdsadf")
        
        XCTAssertNil(notLoaded)
        
        var saved = handler.isDatafileSaved(sdkKey: "fakeSDKKey")
        
        XCTAssertFalse(saved)
        
        handler.saveDatafile(sdkKey: "fakeSDKKey", dataFile: "{}".data(using: .utf8)!)
        
        saved = handler.isDatafileSaved(sdkKey: "fakeSDKKey")
        
        XCTAssertTrue(saved)
        
        let loaded = handler.loadSavedDatafile(sdkKey: "fakeSDKKey")
        
        let empty = String(data: loaded!, encoding: .utf8)
        
        XCTAssertEqual(empty, "{}")
        
        handler.removeSavedDatafile(sdkKey: "fakeSDKKey")
        
        saved = handler.isDatafileSaved(sdkKey: "fakeSDKKey")
        
        XCTAssertFalse(saved)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPeriodicDownload() {
        class FakeDatafileHandler : DefaultDatafileHandler {
            let data = Data()
            override func downloadDatafile(sdkKey: String, resourceTimeoutInterval: Double?, completionHandler: @escaping DatafileDownloadCompletionHandler) {
                completionHandler(.success(data))
            }
        }
        let expection = XCTestExpectation(description: "Expect 10 periodic downloads")
        let handler = FakeDatafileHandler()
        let now = Date()
        var count = 0;
        var seconds = 0
        handler.startPeriodicUpdates(sdkKey: "notrealkey", updateInterval: 1) { (data) in
            count += 1
            if count == 10 {
                handler.stopPeriodicUpdates()
                expection.fulfill()
                seconds = Int(abs(now.timeIntervalSinceNow))
            }
        }
        
        wait(for: [expection], timeout: 20)
        
        XCTAssert(count == 10)
        XCTAssert(seconds == 10)
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}