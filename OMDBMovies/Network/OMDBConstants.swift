//
//  OMDBConstants.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

struct OMDBConstants {
    
    struct baseUrls {
        static let omdbPath = "http://www.omdbapi.com/?"
        static let omdbPosters = "http://img.omdbapi.com/?apikey=[%@]&"
    }

    struct parameters {
        static let title = "t"
        static let year = "y"
        static let plot = "plot"
        static let responseDataType = "r"
        static let equals = "="
        static let and = "&"
    }
}