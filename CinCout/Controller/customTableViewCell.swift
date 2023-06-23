//
//  customCellTableViewCell.swift
//  CinCout
//
//  Created by Harshil Modi on 24/06/23.
//

import UIKit

class customCellTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var reason: UITextView!
    
    @IBOutlet weak var dest: UITextView!
    
    @IBOutlet weak var timeIn: UITextView!
    @IBOutlet weak var dateIn: UITextView!
    
    @IBOutlet weak var timeOut: UITextView!
    @IBOutlet weak var dateOut: UITextView!
}
