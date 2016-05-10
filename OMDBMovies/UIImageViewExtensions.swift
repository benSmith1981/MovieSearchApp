//
//  UIImageViewExtensions.swift
//  OMDBMovies
//
//  Created by Ben Smith on 10/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import UIKit
extension UIImageView {
    func downloadImageFrom(link link:String, contentMode: UIViewContentMode) {
        NSURLSession.sharedSession().dataTaskWithURL( NSURL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode =  contentMode
                if let data = data {
                    self.image = UIImage(data: data)
                }
            }
        }).resume()
    }
}