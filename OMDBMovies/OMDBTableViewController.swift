//
//  ViewController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit
import Kingfisher

class OMDBTableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: searchResultMovies hold the movie search results
    var searchResultMovies = [Movie]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    //MARK: paging variables for scroll down
    var totalPages: Int = 0 //total pages returned from server
    var selectedScope: Int = 0 // the scope currently selected (movie, series, episode_
    var currentPage: Int = 1 //current page we are scrolling on
    var currentSearchText: String = "" //current page we are scrolling on
    
    var currentMovieSelected: Movie? //movie tapped on
    var myQueue: dispatch_queue_t = dispatch_queue_create("com.queue.my", DISPATCH_QUEUE_CONCURRENT) //queue for timing the search requests
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //setup the scopes to search between
        let string = NSLocalizedString("movietypes.movie", comment: "")
        searchController.searchBar.scopeButtonTitles = [string
, movieTypes.episode.description, movieTypes.movie.description, movieTypes.series.description]
        searchController.searchBar.delegate = self
    }

    //MARK: Navigation, Segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        //return false so we can load our detail data before pushing segue
        return false
    }
    
    //MARK: Navigation, Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        MBProgressLoader.Hide()

        if (segue.identifier == "moviedetails") {
            MBProgressLoader.Hide()
            // initialize new view controller and cast it as your view controller
            let detailView = segue.destinationViewController as! OMDBDetailMovieView
            detailView.movieInfo = self.currentMovieSelected
            
        }
    }
}

//MARK: - UITableViewDataSource
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OMDBTableViewCell") as! OMBDTableCell
        let row = indexPath.row
        
        let movie: Movie
        movie = searchResultMovies[row] //list the search results

        if let poster = movie.Poster,
            let title = movie.Title { //title and poster not nil then display them
            cell.error?.hidden = true
            cell.movieThumbnail?.hidden = false
            cell.title?.hidden = false
            //nice kingfisher POD to help loads and cache images
            cell.movieThumbnail?.kf_setImageWithURL(NSURL(string: poster)!, placeholderImage: UIImage(named: "placeholder"))
            cell.title?.text = title
        } else if let errorMessage = movie.Error{ //if we have error show error messages hide other parts of cell
            cell.error?.text = errorMessage
            cell.movieThumbnail?.hidden = true
            cell.title?.hidden = true
            cell.error?.hidden = false
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultMovies.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //only load more results if the search is still active
        if searchController.active {
            //if we are at the last index of the current table size AND current page is less than total pages then load more results, else don't do anything of course because we got to the end of our results
            if indexPath.row == self.currentPage * OMDBConstants.pagesPerRequest - 1 && self.currentPage < self.totalPages {
                self.currentPage += 1
                if let text = (searchController.searchBar.text) { //check for nil search text then search for more movies that are conatined in the response but not yet paged
                    self.doSearch(text, page: self.currentPage, movieTypeScope: searchController.searchBar.scopeButtonTitles![self.selectedScope])
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //set current movie selected to one selected
        self.currentMovieSelected = self.searchResultMovies[indexPath.row]

        //if there is a movie selected it will have a title and a year
        if let title = currentMovieSelected?.Title {
            MBProgressLoader.Show()
            OMDBSearchService.sharedInstance.searchMovieDetailsDatabase(title, plot: plotTypes.FULL, response: responseTypes.JSON, onCompletion: { (success, errorMessage, errorCode, movie, nil, searchText) in
                if success {
                    if let movie = movie {
                        // your new view controller should have property that will store passed value
                        self.currentMovieSelected = movie
                        self.performSegueWithIdentifier("moviedetails", sender: self)
                    }
                } else { //if error returned show the error in the table by adding it to our search results array and displaying that
                    MBProgressLoader.Hide()
                    self.searchResultMovies = []
                    self.searchResultMovies.append(movie!)
                }
            })
        } else {
            MBProgressLoader.Hide()
        }
    }
}
