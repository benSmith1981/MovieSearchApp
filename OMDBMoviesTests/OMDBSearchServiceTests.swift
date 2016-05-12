//
//  OMDBSearchServiceTests.swift
//  OMDBMovies
//
//  Created by Ben Smith on 12/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import XCTest

@testable import OMDBMovies

class OMDBSearchServiceTests: XCTestCase {
    
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
    
    func testSearchOMDBDatabaseByTitleReturnsResults(){
        let searchString = "Jaws"
        let expectation = expectationWithDescription("Waiting to respond")
        
        OMDBSearchService.sharedInstance.searchOMDBDatabaseByTitle(searchString, page: 1, movieType: movieTypes.all.description) { (success, errorMessage, errorCode, movieObject, moviesArray, totalResults) in
            if success {
                XCTAssert(moviesArray!.count > 0) //we expect a lot of results
                expectation.fulfill()
            } else {
                XCTFail(errorMessage!)
            }
        }
        waitForExpectationsWithTimeout(OMDBConstants.timeout, handler:nil)
        
    }
    
    func testSearchMovieDetailsDatabaseReturnsResults(){
        let searchString = "Jaws"
        let expectation = expectationWithDescription("Waiting to respond")
        
        OMDBSearchService.sharedInstance.searchMovieDetailsDatabase(searchString, plot: plotTypes.FULL, response: responseTypes.JSON) { (success, errorMessage, erroCode, movieObject, moviesArray, totalResults) in
            if success {
                XCTAssert(totalResults == 0 ) //this is set to nil on movie details search return completion
                XCTAssert(moviesArray == nil ) //No movie array restults expected a lot of results
                XCTAssert(movieObject != nil) //No movie array restults expected a lot of results
                expectation.fulfill()
            } else {
                XCTFail(errorMessage!)
            }
        }
        waitForExpectationsWithTimeout(OMDBConstants.timeout, handler:nil)
        
    }
    
    func testSearchMovieGenericFailsNicelyWithBadPath(){
        let searchString = "Jaws"
        let path = "http://www.google.com"
        let expectation = expectationWithDescription("Waiting to respond")
        
        OMDBSearchService.sharedInstance.searchMovieGeneric(path, searchString: searchString) { (success, errorMessage, errorCode, movie, movies, totalResults) in
            if success {
                XCTFail(errorCode!)
            } else {
                XCTAssert(!success, errorCode!)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(OMDBConstants.timeout, handler:nil)
        
    }
    
    func testSearchMovieGenericSucceeds(){
        let searchString = "Jaws"
        let path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + searchString + "&" + OMDBConstants.parameters.plot + "=" + plotTypes.FULL.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + responseTypes.JSON.description + "&" + OMDBConstants.parameters.tomatoes + "=true"
        let expectation = expectationWithDescription("Waiting to respond")
        
        OMDBSearchService.sharedInstance.searchMovieGeneric(path, searchString: searchString) { (success, errorMessage, errorCode, movie, movies, totalResults) in
            XCTAssert(success, errorMessage!)
            expectation.fulfill()

        }
        waitForExpectationsWithTimeout(OMDBConstants.timeout, handler:nil)
        
    }
}