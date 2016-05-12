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
        //if the text too long for textview move to top
        self.synopsis?.setContentOffset(CGPointZero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let movieInfo = movieInfo {
            movieTitle?.text = movieInfo.Title
            synopsis?.text = movieInfo.Plot
            
            poster?.kf_setImageWithURL(NSURL(string: movieInfo.Poster!)!, placeholderImage: UIImage(named: "placeholder"))
            if let director = movieInfo.Director,
                let currentText = self.director?.text{
                self.director?.text = currentText + director
            }
            
            if let actors = movieInfo.Actors,
                let currentText = self.actors?.text{
                self.actors?.text = currentText + actors
            }
            
            if let year = movieInfo.Year,
                let currentText = self.year?.text{
                self.year?.text = currentText + year
            }
            
            if let rottenTomatoeRating = movieInfo.tomatoeRating,
                currentText = self.rottenTomatoeRating?.text{
                self.rottenTomatoeRating?.text = currentText + rottenTomatoeRating
            }
        }
    }
    
}