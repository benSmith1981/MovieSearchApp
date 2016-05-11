//
//  OMDBSearchService.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

class OMDBSearchService {
    
    var totalResults:String? //total search results
    var totalPages: Int = 0 // total pages calculated from total results
    let APIService = APIServiceManager.sharedInstance //Shorter common call
    static let sharedInstance = OMDBSearchService()
    
    private init() {}
    
    /** Generic function that contains commmonly used code to deal with the response from the APIService layer, so that the UI can have a nice movie object(s) and user friendly error messages
     - parameter path: String, 
     - parameter searchString: String, 
     - parameter onCompletion: APIMovieResponse
     */
    func searchMovieGeneric(path: String, searchString: String, onCompletion: APIMovieResponse){
        APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.GET, onCompletion: { (success, jsonResponse, error) in
            if success {
                //we get a response array
                if let jsonResponseArray = jsonResponse![serverResponseKeys.Search.description] as? NSArray,
                    let totalResults = jsonResponse![serverResponseKeys.totalResults.description] as? String{
                    
                    //Calculate total pages by looking at the remainder of the division
                    self.totalPages = Int(totalResults)!%OMDBConstants.pagesPerRequest != 0 ? Int(totalResults)!/OMDBConstants.pagesPerRequest + 1 : Int(totalResults)!/OMDBConstants.pagesPerRequest
                    
                    var searchResultsArray = [Movie]()
                    for searchResult in jsonResponseArray{
                        if let searchResult = searchResult as? BodyDataDictionary {
                            //parse and store json response
                            let omdbSearchResponse = Movie.init(searchResults: searchResult, searchString: searchString)
                            searchResultsArray.append(omdbSearchResponse)
                        }
                    }
                    //return the array of movie results
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.getErrorCodeDescription(error), nil, searchResultsArray, self.totalPages ?? 0)
                    
                }
                //we get a response object back
                if let jsonResponseObject = jsonResponse {
                    //parse and store json response
                    let omdbSearchResponse = Movie.init(searchResults: jsonResponseObject, searchString: searchString)
                    //return the movie object
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.getErrorCodeDescription(error), omdbSearchResponse, nil, self.totalPages ?? 0)
                    
                    
                }
            } else { //the request failed return the error
                if let jsonResponseObject = jsonResponse {
                    //send back a movie object so the errors are displayed nicely on the table
                    let omdbSearchResponse = Movie.init(searchResults: jsonResponseObject, searchString: searchString)
                    onCompletion(false, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.getErrorCodeDescription(error), omdbSearchResponse, nil, self.totalPages ?? 0)
                } else {
                    //send back a movie object so the errors are displayed nicely on the table
                    let omdbSearchResponse = Movie.init(searchResults: [serverResponseKeys.Response.description : (error?.userInfo[NSLocalizedDescriptionKey])! , serverResponseKeys.Error.description : self.APIService.getErrorCodeDescription(error)], searchString: searchString)
                    onCompletion(false, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.getErrorCodeDescription(error), omdbSearchResponse, nil, self.totalPages ?? 0)
                }
            }
        })
    }
    
    /**
     Searches the movie database for specific details of a movie that the user selects in the table
     
     - parameter searchString: String The string searched for, stored with the result
     - parameter year: String Year of the movie
     - parameter plot: plotTypes FULL or SHORT plottype so we can display lots or some text to the user
     - parameter response: responseTypes Do we want a JSON or an XML response
     - parameter onCompletion: APIMovieResponse the UI friendly response block with messages and codes and data
     */
    func searchMovieDetailsDatabase(searchString: String, plot: plotTypes, response: responseTypes, onCompletion: APIMovieResponse) {
        //example path http://www.omdbapi.com/?t=12&y=&plot=short&r=json
        let path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + searchString + "&" + OMDBConstants.parameters.plot + "=" + plot.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + response.description + "&" + OMDBConstants.parameters.tomatoes + "=true"
        
        searchMovieGeneric(path, searchString: searchString, onCompletion: onCompletion)
    }
    
    /**
     Searches the movie database for a movie with a given name returning a list of results
     
     - parameter searchString: String The string searched for, stored with the result
     - parameter page: There maybe multiple pages of results so get what ever page specified
     - parameter movieType: this is the scope type (movie, episode or series) so used can search more specifially
     - parameter onCompletion: APIMovieResponse the UI friendly response block with messages and codes and data
     */
    func searchOMDBDatabaseByTitle(searchString: String, page: Int, movieType: String, onCompletion: APIMovieResponse) {
        //example path http://www.omdbapi.com/?s=jaws&page=1
        let path: String
        //if we have selected all then don't include scope type
        if (movieType == movieTypes.all.description){
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.searchTitle + "=" + searchString + "&" + OMDBConstants.parameters.page + "=" + String(page)
        } else {
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.searchTitle + "=" + searchString + "&" + OMDBConstants.parameters.page + "=" + String(page) + "&" + OMDBConstants.parameters.movieType + "=" + movieType
        }

        searchMovieGeneric(path, searchString: searchString, onCompletion: onCompletion)
    }

}