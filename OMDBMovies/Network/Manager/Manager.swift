//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias errorMessage = String?
typealias errorCode = String?

typealias APIServiceResponse = (Bool, BodyDataDictionary?, NSError?) -> Void
typealias APIUserResponse = (Bool, errorMessage, errorCode, SearchResults?) -> Void


struct requestResult {
    var success: Bool
    var errorMessage: String?
    var errorCode: String?
    var serverMessage: String?
    var serverCode: String?
    
    init(success: Bool, errorMessage: String?, errorCode: String?, serverMessage: String?, serverCode: String?)
    {
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.serverMessage = serverMessage
        self.serverCode = serverCode
    }
}

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:BodyDataDictionary = [:]

    private override init() {
        print("Only initialised once only")
    }
    /**
     Helper method to create an NSURLRequest with it's required httpHeader, httpBody and the httpMethod request and return it to be executed
     
     - parameter path: String,
     - parameter body: BodyDataDictionary?,
     - parameter httpHeader: [String:String],
     - parameter httpMethod: httpMethods
     - parameter NSURLRequest, the request created to be executed by makeRequest
     */
    func setupRequest(path: String, body: BodyDataDictionary?, httpHeader: [String:String], httpMethod: httpMethods) throws -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]
        
        if let body = body {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        }
        
        request.HTTPMethod = httpMethod.description
        request.timeoutInterval = 30
        
        return request
    }
    
}

//MARK: - User Manager methods
extension Manager {
    
    /**
     This is a generic method that can make any request to OMBD API. It creates a request with the given parameters and an NSURLSession, then executes the session and gets the responses passing it back as a dictionary and a success or fail of the operation. The body is optional as some request do not require it.
     
     - parameter path: String, The required path to the API service that the user wants to access
     - parameter body: BodyDataDictionary?, The data dictionary of [String: AnyObject] type
     - parameter httpMethod: httpMethods, the http methods that you can do on the API stored in the enum
     - parameter httpHeader:[String:String], the header set to a JSON type
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse)
    {
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil{
                    onCompletion(false, nil, error)
                    return
                }
                if response != nil{
                    if data != nil{
                        do{
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(jsonData  as? BodyDataDictionary, error: error)
                            if requestResult.success == false{
                                //This passes back the errors we retrieve, looks in the different optionals which may or may not be nil
                                let userInfo = [
                                    NSLocalizedDescriptionKey: requestResult.serverMessage ?? requestResult.errorMessage ??  "Unknown Error"
                                ]
                                let omdbError = NSError(domain: requestResult.serverCode ?? requestResult.errorCode ?? "None", code: 600, userInfo: userInfo)
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, omdbError)
                            } else {
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, nil)
                            }
                        } catch let error as NSError{
                            onCompletion(false, nil, error)
                            return
                        }
                        
                    }
                }
            })
            task.resume()
        } catch let error as NSError{
            onCompletion(false, nil, error)
            
        }
    }
}