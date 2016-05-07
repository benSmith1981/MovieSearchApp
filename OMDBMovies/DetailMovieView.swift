//
//  DetailMovieView.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import UIKit
class DetailMovieView: UIViewController {
    
    @IBOutlet weak var movieTitle: UILabel?
    @IBOutlet weak var synopsis: UITextView?
    
    var movieInfo: SearchResults?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let movieInfo = movieInfo {
            movieTitle?.text = movieInfo.Title
            synopsis?.text = movieInfo.Plot
        }
    }
    
}