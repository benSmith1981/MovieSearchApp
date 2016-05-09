//
//  APIServiceManager.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias BodyDataDictionary = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
      
    private init() {}
    
    /**
     Calls the manager to make a standard http request using the httpHeader json type, this requires the users password that is stored in the keychain:
     ["Content-Type": "application/json", "Accept-Language": language]
     
     - parameter body: BodyDataDictionary?, the body of the req uest required by some calls, can be nil
     - parameter path: String, the path to the API service call
     - parameter httpMethod: httpMethods, the httpmethod enum (post, get , put, delete)
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func callRequestWithAPIServiceResponse(body: BodyDataDictionary?, path: String, httpMethod: httpMethods, onCompletion:APIServiceResponse){
        
        let langId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        let countryId = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        let language = "\(langId)-\(countryId)"
        
        let httpHeader = ["Content-Type": "application/json", "Accept-Language": language]
        Manager.sharedInstance.makeRequest(path, body: nil, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: onCompletion)
    }

    /**
     Setups up the messages from the server so the UI knows what is going wrong or right
     
     - parameter json:BodyDataDictionary?, the body of the messages from server, if there is an error then there is a message or code key in response
     - parameter code: Int, the http response code we need to check (200-204 success, other is fail
     - parameter none
     */
    func setServerCodeMessage(json:BodyDataDictionary?, error: NSError?) -> requestResult{
        //check if json is empty
        if let jsonUnwrapped = json,
            let message = jsonUnwrapped[serverResponseKeys.Error.description] as? String{
                if let serverCode = jsonUnwrapped[serverResponseKeys.Response.description] as? String{
                    return requestResult.init(success: false, errorMessage: nil, errorCode: nil, serverMessage: message, serverCode: serverCode)
                }
        } else if let error = error {
            if case responseCodes.connectionFail400.rawValue ... responseCodes.connectionFail499.rawValue = error.code {
                return requestResult.init(success: false, errorMessage: responseMessages.networkConnectionProblem.rawValue, errorCode: error.code, serverMessage: nil, serverCode: nil)
            } else if case -1103 ... -998 = error.code {
                return requestResult.init(success: false, errorMessage: responseMessages.networkConnectionProblem.rawValue, errorCode: error.code, serverMessage: nil, serverCode: nil)
            }
            else if case responseCodes.serverProblem500.rawValue ... responseCodes.serverProblem599.rawValue = error.code {
                return requestResult.init(success: false, errorMessage: responseMessages.serverProblem.rawValue, errorCode: error.code, serverMessage: nil, serverCode: nil)
            } else {
                return requestResult.init(success: false, errorMessage: error.description, errorCode: error.code, serverMessage: nil, serverCode: nil)
            }
        }
        return requestResult.init(success: true, errorMessage: nil, errorCode: nil, serverMessage: nil, serverCode: nil)
    }
 }