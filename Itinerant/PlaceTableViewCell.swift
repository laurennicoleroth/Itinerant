//
//  PlaceTableViewCell.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

  @IBOutlet var name: UILabel!
  @IBOutlet weak var openNowLabel: UILabel!
  @IBOutlet var rating: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
}
