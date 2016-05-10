//
//  OMDBConstants.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

struct OMDBConstants {
    
    static let totalPages = 10
    
    struct baseUrls {
        static let omdbPath = "http://www.omdbapi.com/?"
        static let omdbPosters = "http://img.omdbapi.com/?apikey=[%@]&"
    }

    struct parameters {
        static let title = "t"
        static let searchTitle = "s"
        static let year = "y"
        static let plot = "plot"
        static let responseDataType = "r"
        static let page = "page"
        static let movieType = "type"
    }
}