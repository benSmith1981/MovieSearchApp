//
//  ViewController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit

class OMDBTableViewController: UITableViewController, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    var currentMovieSelected: SearchResults?
    private var preparingForSegue = false
    var myQueue: dispatch_queue_t = dispatch_queue_create("com.queue.my", DISPATCH_QUEUE_CONCURRENT)
    var scheduledSearchNow = false
    let SEARCH_DELAY_IN_MS = 1000
    var searchedStrings = [String]()

    var searchResultMovies = [SearchResults]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }

    //MARK: Moview search results
    var savedMovieSearches = [SearchResults]() {
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
        searchController.searchBar.scopeButtonTitles = [movieTypes.all.description, movieTypes.episode.description, movieTypes.movies.description, movieTypes.series.description]
        searchController.searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Navigation, Segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        MBProgressLoader.Show()
        return false
    }
    
    //MARK: Navigation, Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "moviedetails") {
            MBProgressLoader.Hide()
            // initialize new view controller and cast it as your view controller
            let detailView = segue.destinationViewController as! DetailMovieView
            detailView.movieInfo = self.currentMovieSelected
            
        }
    }
    
    func doSearch(searchString: String, year: String?, movieTypeScope: String = "") {
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressLoader.Show()
        }
        
        OMDBSearchService.sharedInstance.searchOMDBDatabaseByTitle(searchString, page: 1, movieType: movieTypeScope) { (success, errorMessage, errorCode, nil, movies, searchText) in
            dispatch_async(dispatch_get_main_queue()) {
                MBProgressLoader.Hide()
            }
            if success {
                print(movies)
                if let movies = movies {
                    self.searchResultMovies = movies
                    
                }
            } else {
                if let errorCode = errorCode,
                    let errorMessage = errorMessage {
                        dispatch_async(dispatch_get_main_queue()) {
                            MBProgressLoader.Hide()
                            self.displayAlertMessage(errorCode, alertDescription: errorMessage)
                        }
                    }
                print(errorMessage!)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OMDBTableViewCell") as! OMBDTableCell
        let row = indexPath.row
        
        let movie: SearchResults
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            movie = searchResultMovies[row] //list the search results
        } else {
            movie = savedMovieSearches[row] //list all the films tapped on
        }
        cell.movieThumbnail!.image = UIImage(named: "placeholder")  //set placeholder image first.
        cell.movieThumbnail!.downloadImageFrom(link: movie.Poster!, contentMode: UIViewContentMode.ScaleAspectFit)  //set your image from link array.
        
        let title = movie.Title
        cell.title!.text = title
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            return searchResultMovies.count
        }
        return self.savedMovieSearches.count;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - UITableViewDelegate
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.currentMovieSelected = self.searchResultMovies[indexPath.row]
        
        OMDBSearchService.sharedInstance.searchMovieDetailsDatabase(currentMovieSelected!.Title!.removeWhitespaceAddPlus(), year: currentMovieSelected!.Year!, plot: plotTypes.FULL, response: responseTypes.JSON, onCompletion: { (success, message, errorcode, movie, nil, searchText) in
            if success {
                if let movie = movie {
                    // your new view controller should have property that will store passed value
                    self.currentMovieSelected = movie
                    self.savedMovieSearches.append(movie)
                    self.performSegueWithIdentifier("moviedetails", sender: self)
                }
            }
        })
    }
}

extension OMDBTableViewController {
    
    func scheduledSearch(searchBar: UISearchBar, scope: String = "") {
        if scheduledSearchNow {
            return
        }
        self.scheduledSearchNow = true
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * NSEC_PER_MSEC))
        dispatch_after(popTime, myQueue, {() -> Void in
            self.scheduledSearchNow = false
            let text = searchBar.text?.removeWhitespaceAddPlus()
            self.doSearch(text!, year: "", movieTypeScope: scope)
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                self.tableView.reloadData()
            })
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            let searchBar = searchController.searchBar
            self.scheduledSearch(searchController.searchBar, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        }
    }
}

extension OMDBTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            self.doSearch((searchController.searchBar.text?.removeWhitespaceAddPlus())!, year: "", movieTypeScope: searchBar.scopeButtonTitles![selectedScope])
        }
    }
}