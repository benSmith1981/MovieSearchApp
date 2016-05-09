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
    var detailMovie: SearchResults?

    var searchResultMovies = [SearchResults]() {
        didSet {
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "moviedetails") {
            // initialize new view controller and cast it as your view controller
            let detailView = segue.destinationViewController as! DetailMovieView
            // your new view controller should have property that will store passed value
            detailView.movieInfo = self.detailMovie
        }
    }
    
    func doSearch(title: String, year: String?, scope: String = "") {
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressLoader.Show()
        }
        
        OMDBSearchService.sharedInstance.searchOMDBDatabase(title, year: year ?? "", plot: plotTypes.FULL, movieType: scope,  response: responseTypes.JSON) { (success, errorMessage, errorCode, movie, movies) in
            dispatch_async(dispatch_get_main_queue()) {
                MBProgressLoader.Hide()
            }
            if success {
                if let movie = movie {
                    self.searchResultMovies.append(movie)
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
        let title = movie.Title
        cell.title!.text = title
        
        return cell
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
        self.detailMovie = self.searchResultMovies[indexPath.row]
        savedMovieSearches.append(self.detailMovie!)
        performSegueWithIdentifier("moviedetails", sender: self)
    }
}

extension OMDBTableViewController {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            let searchBar = searchController.searchBar
            doSearch((searchController.searchBar.text?.removeWhitespaceAddPlus())!, year: "", scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        }
    }
}

extension OMDBTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        self.tableView.reloadData()
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            doSearch((searchController.searchBar.text?.removeWhitespaceAddPlus())!, year: "", scope: searchBar.scopeButtonTitles![selectedScope])
        }
    }
}