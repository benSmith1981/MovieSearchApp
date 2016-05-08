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

    //MARK: Moview search results
    var searchedMovies = [SearchResults]() {
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
    
    func doSearch(title: String, year: String?) {
        MBProgressLoader.Show()
        OMDBSearchService.sharedInstance.searchOMDBDatabase(title, year: year ?? "", plot: plotTypes.FULL, response: responseTypes.JSON) { (success, errorMessage, errorCode, movie) in
            MBProgressLoader.Hide()
            
            if success {
                if let movie = movie {
                    self.searchedMovies.append(movie)
                }
            } else {
                if let errorCode = errorCode,
                    let errorMessage = errorMessage {
                    self.displayAlertMessage(errorCode, alertDescription: errorMessage)
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
        
        let title = self.searchedMovies[row].Title
        cell.title!.text = title
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedMovies.count;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - UITableViewDelegate
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.detailMovie = self.searchedMovies[indexPath.row]
        performSegueWithIdentifier("moviedetails", sender: self)
    }
}

extension OMDBTableViewController {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            doSearch(searchController.searchBar.text!, year: "")
        }
    }
}

