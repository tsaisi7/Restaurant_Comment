//
//  RestaurantTableViewCell.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var restaurantImageView: UIImageView!{
        didSet{
            restaurantImageView.layer.cornerRadius = 15
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
