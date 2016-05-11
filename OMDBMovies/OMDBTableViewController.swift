//
//  ViewController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit
import Kingfisher

class OMDBTableViewController: UITableViewController, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    //search delay time
    let SEARCH_DELAY_IN_MS: UInt64 = 500

    //paging variables for scroll down
    var totalPages: Int = 0 //total pages returned from server
    var selectedScope: Int = 0 // the scope currently selected (movie, series, episode_
    var currentPage: Int = 1 //current page we are scrolling on
    var currentSearchText: String = "" //current page we are scrolling on
    
    var currentMovieSelected: Movie? //movie tapped on
    var myQueue: dispatch_queue_t = dispatch_queue_create("com.queue.my", DISPATCH_QUEUE_CONCURRENT) //queue for timing the search requests
    
    //hold the movie search results
    var searchResultMovies = [Movie]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }

    //MARK: Moview search results
    var savedMovieSearches = [Movie]() {
        didSet {
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //setup the scopes to search between
        searchController.searchBar.scopeButtonTitles = [movieTypes.all.description, movieTypes.episode.description, movieTypes.movie.description, movieTypes.series.description]
        searchController.searchBar.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchController.resignFirstResponder()
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
    
    func doSearch(searchString: String, year: String?, page: Int, movieTypeScope: String = "") {
        MBProgressLoader.Show()
        //set current search text
        self.currentSearchText = searchString
        
        OMDBSearchService.sharedInstance.searchOMDBDatabaseByTitle(searchString, page: page, movieType: movieTypeScope) { (success, errorMessage, errorCodeString, movie, movies, totalPages) in
            MBProgressLoader.Hide()
            
            self.totalPages = totalPages!
            if success {
                print(movies)
                if let movies = movies {
                    self.searchResultMovies += movies
                }
            } else {
          
                MBProgressLoader.Hide()
                if let movie = movie{
                    self.searchResultMovies.removeAll()
                    self.searchResultMovies.append(movie)
                }
            }
        }
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.reloadData()
        
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
            let title = movie.Title {
            cell.error?.hidden = true
            cell.movieThumbnail?.hidden = false
            cell.title?.hidden = false
            cell.movieThumbnail?.kf_setImageWithURL(NSURL(string: poster)!, placeholderImage: UIImage(named: "placeholder"))
            cell.title?.text = title
        } else if let errorMessage = movie.Response,
            let error = movie.Error{
            cell.error?.text =  error + ": " + errorMessage
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
        if searchController.active {
            if indexPath.row == self.currentPage * OMDBConstants.pagesPerRequest - 1 && self.currentPage <= self.totalPages {
                self.currentPage += 1
                if let text = (searchController.searchBar.text) {
                    self.doSearch(text, year: "", page: self.currentPage, movieTypeScope: searchController.searchBar.scopeButtonTitles![self.selectedScope])
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

            OMDBSearchService.sharedInstance.searchMovieDetailsDatabase(title, year: (currentMovieSelected?.Year)!, plot: plotTypes.FULL, response: responseTypes.JSON, onCompletion: { (success, errorMessage, errorCode, movie, nil, searchText) in
                if success {
                    if let movie = movie {
                        // your new view controller should have property that will store passed value
                        self.currentMovieSelected = movie
                        self.performSegueWithIdentifier("moviedetails", sender: self)
                    }
                } else {
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

// MARK: - Search Scheduler
extension OMDBTableViewController {
    
    func scheduledSearch2(searchBar: UISearchBar, page: Int, scope: String = "") {
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(SEARCH_DELAY_IN_MS * NSEC_PER_MSEC))
        //the value of text is retained in the thread we spawn off main queue
        let text = searchBar.text ?? ""
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if text == searchBar.text {
                self.doSearch(text, year: "", page: self.currentPage, movieTypeScope: scope)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 && self.currentSearchText != searchController.searchBar.text {
            self.searchResultMovies = []
            let searchBar = searchController.searchBar
            self.scheduledSearch2(searchController.searchBar,page: self.currentPage, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        }
    }
}

// MARK: - Search Delegate

extension OMDBTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.currentPage = 1
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content for search
        self.selectedScope = selectedScope
        self.currentPage = 1
        self.searchResultMovies = []
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            self.doSearch((searchController.searchBar.text)!, year: "", page: self.currentPage, movieTypeScope: searchBar.scopeButtonTitles![selectedScope])
        }
    }
}