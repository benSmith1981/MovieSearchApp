//
//  Enums.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

enum responseTypes {
    case JSON
    case XML
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .JSON: return "JSON";
        case .XML: return "XML";
        }
    }
}

enum movieTypes {
    case movie
    case series
    case episode
    case all
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .movie:
            let localizedString = NSLocalizedString("movietypes.movie", comment: "")
            return localizedString;
        case .series:
            let localizedString = NSLocalizedString("movietypes.series", comment: "")
            return localizedString;
        case .episode:
            let localizedString = NSLocalizedString("movietypes.episode", comment: "")
            return localizedString;
        case .all:
            let localizedString = NSLocalizedString("movietypes.all", comment: "")
            return localizedString;
        }
    }
}

enum plotTypes {
    case SHORT
    case FULL
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .SHORT: return "SHORT";
        case .FULL: return "FULL";
        }
    }
}

enum httpMethods{
    case POST
    case DELETE
    case GET
    case PUT
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .POST: return "POST";
        case .DELETE: return "DELETE";
        case .GET: return "GET";
        case .PUT: return "PUT";
        }
    }
}


enum responseCodes: Int{
    case ok200 = 200
    case ok399 = 399
    case connectionFail400 = 400
    case connectionFail499 = 499
    case serverProblem500 = 500
    case serverProblem599 = 599
    case omdbErrorCode = 600
}

enum errorDomains: String {
    case ombdErrorDomain = "OMDB.Domain"
    case networkErrorDomain = "Network.Domain"
    case successDomain = "Success"
}

enum responseMessages: String{
    case networkConnectionProblem
    case serverProblem
    case ombdError
    case success
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .networkConnectionProblem: return NSLocalizedString("responseMessages.networkConnectionProblem", comment: "");
        case .serverProblem: return NSLocalizedString("responseMessages.serverProblem", comment: "");
        case .ombdError: return NSLocalizedString("responseMessages.ombdError", comment: "");
        case .success: return NSLocalizedString("responseMessages.success", comment: "");
        }
    }
}

enum serverResponseKeys {
    case Title
    case Year
    case Rated
    case Released
    case Runtime
    case Genre
    case Director
    case Writer
    case Actors
    case Plot
    case Language
    case Country
    case Awards
    case Poster
    case Metascore
    case imdbRating
    case imdbVotes
    case imdbID
    case FilmType
    case Response
    case Error
    case totalResults
    case Search
    case tomatoUserRating
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .Title: return "Title"
        case .Year: return "Year"
        case .Rated: return "Rated"
        case .Released: return "Released"
        case .Runtime: return "Runtime"
        case .Genre: return "Genre"
        case .Director: return "Director"
        case .Writer: return "Writer"
        case .Actors: return "Actors"
        case .Plot: return "Plot"
        case .Language: return "Language"
        case .Country: return "Country"
        case .Awards: return "Awards"
        case .Poster: return "Poster"
        case .Metascore: return "Metascore"
        case .imdbRating: return "imdbRating"
        case .imdbVotes: return "imdbVotes"
        case .imdbID: return "imdbID"
        case .FilmType: return "Type"
        case .Response: return "Response"
        case .Error: return "Error"
        case .totalResults: return "totalResults"
        case .Search: return "Search"
        case .tomatoUserRating: return "tomatoUserRating"

        }
    }
}