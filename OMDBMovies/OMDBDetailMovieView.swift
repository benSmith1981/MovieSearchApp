//
//  DetailMovieView.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class OMDBDetailMovieView: UIViewController {
    
    @IBOutlet weak var movieTitle: UILabel?
    @IBOutlet weak var synopsis: UITextView?
    @IBOutlet weak var poster: UIImageView?
    @IBOutlet weak var director: UILabel?
    @IBOutlet weak var actors: UILabel?
    @IBOutlet weak var year: UILabel?
    @IBOutlet weak var rottenTomatoeRating: UILabel?

    var movieInfo: Movie?

    override func viewDidAppear(animated: Bool) {
        //if the text too big for view move to top
        self.synopsis?.setContentOffset(CGPointZero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if let movieInfo = movieInfo {
            movieTitle?.text = movieInfo.Title
            synopsis?.text = movieInfo.Plot
            
            poster?.kf_setImageWithURL(NSURL(string: movieInfo.Poster!)!, placeholderImage: UIImage(named: "placeholder"))
            if let director = movieInfo.Director {
                self.director?.text = "Director: " + director
            }
            
            if let actors = movieInfo.Actors {
                self.actors?.text = "Actors: " + actors
            }
            
            if let year = movieInfo.Year {
                self.year?.text = "Year: " + year
            }
            
            if let rottenTomatoeRating = movieInfo.tomatoeRating {
                self.rottenTomatoeRating?.text = "Rotten Tomatoe Rating: " + rottenTomatoeRating
            }
        }
    }
    
}