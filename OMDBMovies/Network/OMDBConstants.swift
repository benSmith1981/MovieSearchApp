//
//  OMDBConstants.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

struct OMDBConstants {
    //the timeout for the request
    static let timeout: NSTimeInterval = 20
    
    //Max  many pages or results the server can show in one response
    static let pagesPerRequest = 10
    
    //search delay time
    static let SEARCH_DELAY_IN_MS: UInt64 = 500
    
    struct baseUrls {
        static let omdbPath = "http://www.omdbapi.com/?"
        static let omdbPosters = "http://img.omdbapi.com/?apikey=[%@]&"
    }

    //parameters in the search URL
    struct parameters {
        static let imdbID = "i"
        static let title = "t"
        static let searchTitle = "s"
        static let year = "y"
        static let plot = "plot"
        static let responseDataType = "r"
        static let page = "page"
        static let movieType = "type"
        static let tomatoes = "tomatoes"
    }
}