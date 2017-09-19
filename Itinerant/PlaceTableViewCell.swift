//
//  PlaceTableViewCell.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Cosmos
import GooglePlaces

class PlaceTableViewCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var openNowLabel: UILabel!
  @IBOutlet weak var starRatingView: CosmosView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  func setup(place: Place) {
    self.nameLabel.text = place.name
    self.addressLabel.text = place.address
    self.starRatingView.rating = place.rating!
    
    if let openNow : GMSPlacesOpenNowStatus = place.openNow {
      if (openNow == GMSPlacesOpenNowStatus.yes ) {
        openNowLabel.text = "OPEN"
        openNowLabel.textColor = UIColor(hue: 0.2778, saturation: 0.93, brightness: 0.62, alpha: 1.0)
      } else {
        openNowLabel.text = "CLOSED"
        openNowLabel.textColor = UIColor.red
      }
    } else {
      openNowLabel.isHidden = true
    }
  }
  
}
