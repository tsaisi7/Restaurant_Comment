//
//  DetailTableViewCell.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
