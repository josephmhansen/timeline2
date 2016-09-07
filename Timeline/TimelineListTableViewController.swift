//
//  TimelineListTableViewController.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/5/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import UIKit

class TimelineListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()
        PostController.sharedController.fetchPosts { (_) in
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postsWereUpdated), name: "postsWereUpdated", object: nil)
        
    }
    
    func postsWereUpdated() {
        dispatch_async(dispatch_get_main_queue()) {
        self.tableView.reloadData()    
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func setupSearchController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsController = storyboard.instantiateViewControllerWithIdentifier("resultsTVC")
        
        searchController = UISearchController(searchResultsController: resultsController)
        guard let searchController = searchController else { return }
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search for a post"
        searchController.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let caption = searchController.searchBar.text,
            resultsController = searchController.searchResultsController as? ResultsSearchTableViewController else { return }
        resultsController.filteredPosts = PostController.sharedController.searchForPostWithCaption(caption)
        resultsController.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PostController.sharedController.posts.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell
        let post = PostController.sharedController.posts[indexPath.row]
        cell?.updateWithPost(post)
        
        
        // Configure the cell...

        return cell ?? UITableViewCell()
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toViewPost" {
            let postDetailVC = segue.destinationViewController as? PostDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let post = PostController.sharedController.posts[indexPath.row]
                postDetailVC?.post = post
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
