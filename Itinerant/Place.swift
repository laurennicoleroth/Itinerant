//
//  Place.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

class Place {

  var name: String?
  var rating: Double?
  var latitude: Double?
  var longitude: Double?
  var iconName: String?
  var placeID: String?
  var photoReference: String?
  var photo: UIImage?
  var icon: UIImage?
  var priceLevel: Double?
  var website: String?
  var phoneNumber: String?
  var address: String?
  var openNow: Bool?
  
  var marker : GMSMarker {
    get {
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
      marker.title = name
      marker.icon = #imageLiteral(resourceName: "locationPin")
      
      return marker
    }
  }
  
  init(place: GMSPlace) {
    self.name = place.name
    self.rating = Double(place.rating)
    self.latitude = place.coordinate.latitude
    self.longitude = place.coordinate.longitude
    self.placeID = place.placeID
    self.priceLevel = Double(place.priceLevel.rawValue)
    self.website = String(describing: place.website)
    self.phoneNumber = place.phoneNumber
    self.address = place.formattedAddress
    
    if place.openNowStatus.rawValue == 2 {
      self.openNow = true
    } else {
      self.openNow = false
    }
  }
  
  
  func makeShareable() -> [Any] {
    
    let placeString = "\(marker.title!): \n\(marker.position.latitude), \(marker.position.longitude)\n"
    var objectsToShare = [Any]()
    
    let lat = marker.position.latitude
    let lon = marker.position.longitude
    
    let vcardString = [
      "BEGIN:VCARD",
      "VERSION:3.0",
      "N:;Shared Location;;;",
      "FN:Shared Location",
      "item1.URL;type=pref:http://maps.apple.com/?ll=\(lat),\(lon)",
      "item1.X-ABLabel:map url",
      "END:VCARD"
      ].joined(separator: "\n")
    
    print("Vcard string is:", vcardString)
    
    let directory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask)
    
    let path = directory.first!.path + "_vcard_for_location_sharing.loc.vcf"
    do {
      try vcardString.write(toFile: path, atomically: true, encoding: .ascii)
      let url = NSURL(fileURLWithPath: path)
      
      objectsToShare = [url, placeString] as [Any]
      
    }
    catch   {
      print("problem saving vcard: \(error.localizedDescription)")
    }
    
    return objectsToShare
  }
}
