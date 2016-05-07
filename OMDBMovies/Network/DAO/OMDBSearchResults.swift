//
//  OMDBSearchResults.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

struct SearchResults {
    var Title: String?
    var Year: String?
    var Rated: String?
    var Released: String?
    var Runtime: String?
    var Genre: String?
    var Director: String?
    var Writer: String?
    var Actors: String?
    var Plot: String?
    var Language: String?
    var Country: String?
    var Awards: String?
    var Posters: String?
    var Metascore: String?
    var imdbRating: String?
    var imdbVotes: String?
    var imdbID: String?
    var Type: String?
    var Response: String?
    var Error: String?

    init(searchResults: BodyDataDictionary){
        
        if let title = searchResults[serverResponseKeys.Title.description] as? String{
            self.Title = title
        }
        
        if let Year = searchResults[serverResponseKeys.Year.description] as? String{{
            self.Year = Year
        }
        
        if let Rated = searchResults[serverResponseKeys.Year.description] as? String{
            self.Year = Year
        }
            
        if let Rated = searchResults[serverResponseKeys.Year.description] as? String{
            self.Year = Year
        }
    }
}