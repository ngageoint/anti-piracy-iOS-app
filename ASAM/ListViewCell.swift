//
//  ListViewCell.swift
//  ASAM
//


import UIKit

class ListViewCell: UITableViewCell {
    
    @IBOutlet weak var aggressor: UILabel!
    @IBOutlet weak var victim: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
