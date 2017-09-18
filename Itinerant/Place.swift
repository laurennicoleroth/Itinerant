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
  
  var place: GMSPlace
  var marker : GMSMarker {
    get {
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
      marker.title = place.name
      marker.icon = #imageLiteral(resourceName: "locationPin")
      
      return marker
    }
  }
  
  init(place: GMSPlace) {
    self.place = place
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
