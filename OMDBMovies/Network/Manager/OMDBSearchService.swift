//
//  OMDBSearchService.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

class OMDBSearchService {
    
    func searchOMDBDatabase(title: String, year: String, plot: plotTypes, response: responseTypes, onCompletion: APIUserResponse) {
        //example path http://www.omdbapi.com/?t=12&y=&plot=short&r=json
        
        if (title ?? "").isEmpty || (year ?? "").isEmpty{
            let path = OMDBConstants.baseUrls.omdbPath + OMDBConstants.parameters.title + "=" + title + "&" + OMDBConstants.parameters.year + "=" + year + "&" + OMDBConstants.parameters.plot + "=" + plot.description +  "&" + OMDBConstants.parameters.responseDataType + "=" + response.description
            
            APIServiceManager.sharedInstance.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.GET, onCompletion: { (success, jsonResponse, error) in
                if success {
                    
                }
            })
        }

    }

}