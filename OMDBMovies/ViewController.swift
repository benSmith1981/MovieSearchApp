//
//  ViewController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 07/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit

class OMDBTableViewController: UITableViewController {

    //MARK: Moview search results
    var searchedMovie: SearchResults? {
        didSet {
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OMDBSearchService.sharedInstance.searchOMDBDatabase("Jaws", year: "", plot: plotTypes.FULL, response: responseTypes.JSON) { (success, errorMessage, errorCode, results) in
            if success {
                if let results = results {
                    self.searchedMovie = results
                }
            } else {
                print(errorMessage!)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.tableView.reloadData()
        }
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
            detailView.movieInfo = self.searchedMovie
        }
    }
}

//MARK: - UITableViewDataSource
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OMDBTableViewCell") as! OMBDTableCell
        let row = indexPath.row
        
        let title = self.searchedMovie?.Title
        cell.title!.text = title
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - UITableViewDelegate
extension OMDBTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        performSegueWithIdentifier("moviedetails", sender: self)
    }
}

