//
//  OMDBSearchController.swift
//  OMDBMovies
//
//  Created by Ben Smith on 12/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Search Scheduler
extension OMDBTableViewController: UISearchResultsUpdating{
    
    func scheduledSearch(searchBar: UISearchBar, page: Int, scope: String = "") {
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(OMDBConstants.SEARCH_DELAY_IN_MS * NSEC_PER_MSEC))
        //the value of text is retained in the thread we spawn off main queue
        let text = searchBar.text ?? ""
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if text == searchBar.text {
                let scope = self.determineScope(searchBar.scopeButtonTitles![self.selectedScope])
                self.doSearch(text, page: self.currentPage, movieTypeScope: scope)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //Filter content for search
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 && self.currentSearchText != searchController.searchBar.text {
            self.searchResultMovies = []
            let searchBar = searchController.searchBar
            self.scheduledSearch(searchController.searchBar,page: self.currentPage, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        }
    }
}

// MARK: - Search Delegate

extension OMDBTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.currentPage = 1 //when we start typing reset the current page to 1 as new results will be loaded
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.returnKeyType = UIReturnKeyType.Done // because of the update search results automatically being fired keyboard must say done not search
        return true
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content for search
        self.selectedScope = selectedScope
        self.currentPage = 1
        self.searchResultMovies = [] //reset our search results
        if searchController.active && searchController.searchBar.text?.characters.count >= 2 {
            let scope = determineScope(searchBar.scopeButtonTitles![selectedScope])
            self.doSearch((searchController.searchBar.text)!, page: self.currentPage, movieTypeScope: scope)
        }
    }
    
    /** Because of localizable strings the s
     */
    func determineScope(scopeTitle: String) -> String {
        var scope: String
        switch scopeTitle {
        case movieTypesTitles.movie.description:
            scope = movieTypes.movie.description
        case movieTypesTitles.all.description:
            scope = movieTypes.all.description
        case movieTypesTitles.series.description:
            scope = movieTypes.series.description
        case movieTypesTitles.episode.description:
            scope = movieTypes.episode.description
        default:
            scope = movieTypes.all.description
        }
        return scope
    }
}

// MARK: - Search Function

extension OMDBTableViewController {
    /**
     This is called by the search scheduler and calls the OMDB search functions to get a list of results
     - parameter searchString: String, The search string the title of the film in this case
     - parameter page: Int, the page number we want to get from the server, this is calculated from the total pages returned on the search
     - parameter movieTypeScope: String Movie, Episode, Series or All scope type to refine a search
     */
    func doSearch(searchString: String, page: Int, movieTypeScope: String = "") {
        MBProgressLoader.Show()
        //set current search text
        self.currentSearchText = searchString
        
        OMDBSearchService.sharedInstance.searchOMDBDatabaseByTitle(searchString, page: page, movieType: movieTypeScope) { (success, errorMessage, errorCodeString, movie, movies, totalPages) in
            MBProgressLoader.Hide()
            
            self.totalPages = totalPages! //force unwrap as we know will be zero or another INT
            
            if success {
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