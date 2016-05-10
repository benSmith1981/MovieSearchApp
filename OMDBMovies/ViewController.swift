//
//  ViewController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit

class OMDBTableViewController: UITableViewController {//, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    let SEARCH_DELAY_IN_MS: UInt64 = 500

    var totalPages: Int = 0
    var selectedScope: Int = 0
    var currentPage: Int = 1
    var currentMovieSelected: SearchResults?
    var myQueue: dispatch_queue_t = dispatch_queue_create("com.queue.my", DISPATCH_QUEUE_CONCURRENT)
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
//        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = [movieTypes.all.description, movieTypes.episode.description, movieTypes.movie.description, movieTypes.series.description]
        searchController.searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Navigation, Segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    //MARK: Navigation, Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        MBProgressLoader.Hide()

        if (segue.identifier == "moviedetails") {
            MBProgressLoader.Hide()
            // initialize new view controller and cast it as your view controller
            let detailView = segue.destinationViewController as! DetailMovieView
            detailView.movieInfo = self.currentMovieSelected
            
        }
    }
    
    func doSearch(searchString: String, year: String?, page: Int, movieTypeScope: String = "") {
        MBProgressLoader.Show()
        
        OMDBSearchService.sharedInstance.searchOMDBDatabaseByTitle(searchString, page: page, movieType: movieTypeScope) { (success, errorMessage, errorCode, nil, movies, totalPages) in
            MBProgressLoader.Hide()
            
            if success {
                print(movies)
                if let movies = movies {
                    self.searchResultMovies += movies
                    
                }
            } else {
          
                MBProgressLoader.Hide()
                self.displayAlertMessage(errorCode == responseCodes.omdbErrorCode.rawValue ? responseMessages.ombdError.rawValue : responseMessages.networkConnectionProblem.rawValue, alertDescription: errorMessage ?? "")
                
                print(errorMessage!)
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
        
        let movie: SearchResults
        movie = searchResultMovies[row] //list the search results

        cell.movieThumbnail!.image = UIImage(named: "placeholder")  //set placeholder image first.
        cell.movieThumbnail!.downloadImageFrom(link: movie.Poster!, contentMode: UIViewContentMode.ScaleAspectFit)  //set your image from link array.
        
        let title = movie.Title
        cell.title!.text = title
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            return searchResultMovies.count
        //}
        //return self.savedMovieSearches.count;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == OMDBConstants.totalPages - 1 {
            self.currentPage += 1
            if let text = (searchController.searchBar.text) {
                self.doSearch(text, year: "", page: self.currentPage, movieTypeScope: searchController.searchBar.scopeButtonTitles![self.selectedScope])
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.currentMovieSelected = self.searchResultMovies[indexPath.row]
        MBProgressLoader.Show()

        OMDBSearchService.sharedInstance.searchMovieDetailsDatabase(currentMovieSelected!.Title!.removeWhitespaceAddPlus(), year: currentMovieSelected!.Year!, plot: plotTypes.FULL, response: responseTypes.JSON, onCompletion: { (success, errorMessage, errorCode, movie, nil, searchText) in
            if success {
                if let movie = movie {
                    // your new view controller should have property that will store passed value
                    self.currentMovieSelected = movie
//                    self.savedMovieSearches.append(movie)
                    self.performSegueWithIdentifier("moviedetails", sender: self)
                }
            } else {
                MBProgressLoader.Hide()
                self.displayAlertMessage(errorCode == responseCodes.omdbErrorCode.rawValue ? responseMessages.ombdError.rawValue : responseMessages.networkConnectionProblem.rawValue, alertDescription: errorMessage ?? "")
                
            }
        })
    }
}

// MARK: - Search Scheduler
extension OMDBTableViewController {
    
//    func scheduledSearch(searchBar: UISearchBar, scope: String = "") {
//        if scheduledSearchNow {
//            return
//        }
//        self.scheduledSearchNow = true
//        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * NSEC_PER_MSEC))
//        dispatch_after(popTime, myQueue, {() -> Void in
//            self.scheduledSearchNow = false
//            let text = searchBar.text?.removeWhitespaceAddPlus()
//            self.doSearch(text!, year: "", movieTypeScope: scope)
//            dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                self.tableView.reloadData()
//            })
//        })
//    }
    
    
    func scheduledSearch2(searchBar: UISearchBar, page: Int, scope: String = "") {
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(SEARCH_DELAY_IN_MS * NSEC_PER_MSEC))
        let text = searchBar.text ?? ""
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if text == searchBar.text {
                self.doSearch(text, year: "", page: self.currentPage, movieTypeScope: scope)
            }
        }
    }
    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        //Filter content for search
//        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
//            let searchBar = searchController.searchBar
//            self.scheduledSearch2(searchController.searchBar, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
//        }
//    }
}

// MARK: - Search Delegate

extension OMDBTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.currentPage = 1
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            let searchBar = searchController.searchBar
            self.scheduledSearch2(searchController.searchBar, page: self.currentPage, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        }
    }
        
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content for search
        self.selectedScope = selectedScope
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            self.doSearch((searchController.searchBar.text)!, year: "", page: self.currentPage, movieTypeScope: searchBar.scopeButtonTitles![selectedScope])
        }
    }
}