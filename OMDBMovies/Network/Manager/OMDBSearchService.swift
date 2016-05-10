//
//  OMDBSearchService.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

class OMDBSearchService {
    
    let APIService = APIServiceManager.sharedInstance
    static let sharedInstance = OMDBSearchService()
    
    private init() {}
    
    func searchMovieGeneric(path: String, searchString: String, onCompletion: APIMovieResponse){
        APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.GET, onCompletion: { (success, jsonResponse, error) in
            if success {
                //parse and store json response
                //if response is an array
                if let jsonResponseArray = jsonResponse!["Search"] as? NSArray{
                    var searchResultsArray = [SearchResults]()
                    for searchResult in jsonResponseArray{
                        if let searchResult = searchResult as? BodyDataDictionary {
                            let omdbSearchResponse = SearchResults.init(searchResults: searchResult, searchString: searchString)
                            searchResultsArray.append(omdbSearchResponse)
                        }
                    }
                    onCompletion(success, nil, nil, nil, searchResultsArray, searchString)
                }
                
                if let jsonResponseObject = jsonResponse {
                    let omdbSearchResponse = SearchResults.init(searchResults: jsonResponseObject, searchString: searchString)
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), omdbSearchResponse, nil, searchString)
                    
                }
            } else {
                onCompletion(false, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, searchString)
                print(error?.userInfo[NSLocalizedDescriptionKey])
            }
        })
    }
    
    func searchMovieDetailsDatabase(searchString: String, year: String, plot: plotTypes, response: responseTypes, onCompletion: APIMovieResponse) {
        //example path http://www.omdbapi.com/?t=12&y=&plot=short&r=json
        let path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + searchString + "&" + OMDBConstants.parameters.year + "=" + year + "&" + OMDBConstants.parameters.plot + "=" + plot.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + response.description
        
        searchMovieGeneric(path, searchString: searchString, onCompletion: onCompletion)
    }
    
    func searchOMDBDatabaseByTitle(searchString: String, page: Int, movieType: String, onCompletion: APIMovieResponse) {
        //http://www.omdbapi.com/?s=jaws&page=1
        let path: String
        if (movieType == movieTypes.all.description){
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.searchTitle + "=" + searchString + "&" + OMDBConstants.parameters.page + "=" + String(page)
        } else {
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.searchTitle + "=" + searchString + "&" + OMDBConstants.parameters.page + "=" + String(page) + "&" + OMDBConstants.parameters.movieType + "=" + movieType
        }

        searchMovieGeneric(path, searchString: searchString, onCompletion: onCompletion)
    }

}