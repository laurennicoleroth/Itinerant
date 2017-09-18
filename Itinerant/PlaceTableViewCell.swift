//
//  PlaceTableViewCell.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
  
  @IBOutlet var icon: UIImageView!
  @IBOutlet var name: UILabel!
  @IBOutlet var rating: UILabel!
  @IBOutlet var photo: UIImageView!
  @IBOutlet var priceLevel: UILabel!
  @IBOutlet var starRating: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    //      photo.layer.cornerRadius = 2   //round the corner of photo
    photo.layer.masksToBounds = true
    photo.contentMode = .scaleAspectFill
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
