//
//  OMDBMoviesTests.swift
//  OMDBMoviesTests
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import XCTest
@testable import OMDBMovies

class OMDBMoviesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSetServerCodeMessageReturnsRightErrorsToUIWithOMDBTypeError() {
        let errorMessage = "Test error"
        
        let errorDict = ["Error" : errorMessage]
        let requestReult = APIServiceManager.sharedInstance.setServerCodeMessage(errorDict, error: nil)
        
        //we shoudl get the error message we passed in
        XCTAssert(requestReult.errorMessage == errorMessage)
        //the omdb error code
        XCTAssert(requestReult.errorCode == responseCodes.omdbErrorCode.rawValue)
        //and domain
        XCTAssert(requestReult.domain == errorDomains.ombdErrorDomain.rawValue)
        //and a fail because this is an error from OMDB
        XCTAssert(!requestReult.success)
    }
}
