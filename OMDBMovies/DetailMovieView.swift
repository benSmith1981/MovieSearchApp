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
    @IBOutlet weak var poster: UIImageView?
    @IBOutlet weak var director: UILabel?
    @IBOutlet weak var actors: UILabel?
    @IBOutlet weak var year: UILabel?
    @IBOutlet weak var rottenTomatoeRating: UILabel?

    var movieInfo: SearchResults?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.synopsis?.setContentOffset(CGPointZero, animated: false)
        
        if let movieInfo = movieInfo {
            movieTitle?.text = movieInfo.Title
            synopsis?.text = movieInfo.Plot
            poster?.image = UIImage(named: "placeholder")  //set placeholder image first.
            poster?.downloadImageFrom(link: movieInfo.Poster!, contentMode: UIViewContentMode.ScaleAspectFit)  //set your image from link array.
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