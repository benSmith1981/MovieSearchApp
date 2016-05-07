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
    var FilmType: String?
    var Response: String?
    var Error: String?

    init(searchResults: BodyDataDictionary){
        
        if let Error = searchResults[serverResponseKeys.Error.description] as? String,
            let Response = searchResults[serverResponseKeys.Response.description] as? String{
            self.Response = Response
            self.Error = Error
            
        } else {
            
            for (key,value) in searchResults {
                print("\(key) = \(value)")
            }
        
            if let title = searchResults[serverResponseKeys.Title.description] as? String{
                self.Title = title
            }
            
            if let Year = searchResults[serverResponseKeys.Year.description] as? String{
                self.Year = Year
            }
            
            if let Rated = searchResults[serverResponseKeys.Rated.description] as? String{
                self.Rated = Rated
            }
                
            if let Released = searchResults[serverResponseKeys.Released.description] as? String{
                self.Released = Released
            }
            
            if let Runtime = searchResults[serverResponseKeys.Runtime.description] as? String{
                self.Runtime = Runtime
            }
            
            if let Genre = searchResults[serverResponseKeys.Genre.description] as? String{
                self.Genre = Genre
            }
            
            if let Director = searchResults[serverResponseKeys.Director.description] as? String{
                self.Director = Director
            }
            
            if let Writer = searchResults[serverResponseKeys.Writer.description] as? String{
                self.Writer = Writer
            }
            
            if let Actors = searchResults[serverResponseKeys.Actors.description] as? String{
                self.Actors = Actors
            }
            
            if let Plot = searchResults[serverResponseKeys.Plot.description] as? String{
                self.Plot = Plot
            }
            
            if let Language = searchResults[serverResponseKeys.Language.description] as? String{
                self.Language = Language
            }
            
            if let Country = searchResults[serverResponseKeys.Country.description] as? String{
                self.Country = Country
            }
            
            if let Awards = searchResults[serverResponseKeys.Awards.description] as? String{
                self.Awards = Awards
            }
            
            if let Posters = searchResults[serverResponseKeys.Posters.description] as? String{
                self.Posters = Posters
            }
            
            if let Metascore = searchResults[serverResponseKeys.Metascore.description] as? String{
                self.Metascore = Metascore
            }
            
            if let imdbRating = searchResults[serverResponseKeys.imdbRating.description] as? String{
                self.imdbRating = imdbRating
            }
            
            if let imdbVotes = searchResults[serverResponseKeys.imdbVotes.description] as? String{
                self.imdbVotes = imdbVotes
            }
            
            if let imdbID = searchResults[serverResponseKeys.imdbID.description] as? String{
                self.imdbID = imdbID
            }
            
            if let FilmType = searchResults[serverResponseKeys.FilmType.description] as? String{
                self.FilmType = FilmType
            }
            
            if let Response = searchResults[serverResponseKeys.Response.description] as? String{
                self.Response = Response
            }
        }
    }
}