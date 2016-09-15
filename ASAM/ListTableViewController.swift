//
//  ListTableViewController.swift
//  ASAM
//


import UIKit

class ListTableViewController: UITableViewController {
    
    let model = AsamModelFacade()
    var asams = [AsamAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return asams.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("asamCell", forIndexPath: indexPath) as! ListViewCell
        
        let asam = asams[indexPath.row].asam// as Asam
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        
        let theDate = dateFormatter.stringFromDate(asam.date)
        
        cell.aggressor.text = "Aggressor: " + asam.aggressor
        cell.victim.text = "Victim: " + asam.victim
        cell.date.text = theDate
        cell.detail.text = asam.desc
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "singleListAsamDetails") {
            let viewController: AsamDetailsViewController = segue!.destinationViewController as! AsamDetailsViewController
            let path = self.tableView.indexPathForSelectedRow!
            
            let selectedAsam = asams[path.row] as AsamAnnotation
            
           // var location = CLLocationCoordinate2DMake(selectedAsam.lat as Double, selectedAsam.lng as Double)
           // var asamAnnot = AsamAnnotation(coordinate: location, asam: selectedAsam)
            
            viewController.asam = selectedAsam.asam//asamAnnot.asam
        }
    }


}

