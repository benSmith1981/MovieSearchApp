//
//  OMDBSearchService.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

class OMDBSearchService {
    
    static let sharedInstance = OMDBSearchService()
    
    private init() {}
    
    func searchOMDBDatabase(title: String, year: String, plot: plotTypes, movieType: String, response: responseTypes, onCompletion: APIUserResponse) {
        //example path http://www.omdbapi.com/?t=12&y=&plot=short&r=json
        
        let path: String
        if (movieType == movieTypes.all.description){
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + title + "&" + OMDBConstants.parameters.year + "=" + year + "&" + OMDBConstants.parameters.plot + "=" + plot.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + response.description
        } else {
            path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + title + "&" + OMDBConstants.parameters.year + "=" + year + "&" + OMDBConstants.parameters.plot + "=" + plot.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + response.description + "&type=" + movieType
        }

            
        APIServiceManager.sharedInstance.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.GET, onCompletion: { (success, jsonResponse, error) in
            if success {
                //parse and store json response
                //if response is an array
                if let jsonResponseArray = jsonResponse!["totalResults"] as? NSArray{
                    var searchResultsArray = [SearchResults]()
                    for searchResult in jsonResponseArray{
                        if let searchResult = searchResult as? BodyDataDictionary {
                            let omdbSearchResponse = SearchResults.init(searchResults: searchResult)
                            searchResultsArray.append(omdbSearchResponse)
                        }
                    }
                    onCompletion(success, nil, nil, nil, searchResultsArray)
                }
                
                if let jsonResponseObject = jsonResponse {
                    let omdbSearchResponse = SearchResults.init(searchResults: jsonResponseObject)
                    onCompletion(success, nil, nil, omdbSearchResponse, nil)
                    
                }
            } else {
                onCompletion(false, error?.userInfo[NSLocalizedDescriptionKey] as? String, String(error!.code) ?? error!.domain, nil, nil)
                print(error?.userInfo[NSLocalizedDescriptionKey])
            }
        })

    }

}