//
//  ListTableViewController.swift
//  ASAM
//

import UIKit

class ListTableViewController: UITableViewController {
    
    let model = AsamModelFacade()
    var asams = [Asam]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "\(asams.count) ASAMs"
        
        dateFormatter.dateStyle = .short
        
        clearsSelectionOnViewWillAppear = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return asams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "asamCell", for: indexPath) as! ListViewCell
        
        let asam = asams[indexPath.row]
        
        let theDate = dateFormatter.string(from: asam.date)
        
        cell.aggressor.text = asam.hostility
        cell.victim.text = asam.victim
        cell.date.text = theDate
        cell.detail.text = asam.detail
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        if (segue?.identifier == "singleListAsamDetails") {
            let viewController: AsamDetailsViewController = segue!.destination as! AsamDetailsViewController
            let path = self.tableView.indexPathForSelectedRow!
            viewController.asam = asams[path.row] as Asam
        }
    }
}

