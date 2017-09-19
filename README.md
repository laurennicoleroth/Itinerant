# Itinerant

Itinerant is for people who like to plan trips! So say your going to Paris, or another wonderful place in the world, and have a ton of places you want to see. You can just add them to the map. Once you add them to the map, you can view some more details in a tableview, reorder them, and then click one of them to send to your traveling companion!

Future plans for Itinerant: add directions calculations and pathing from ordered places. For now you can send a vcard of an individual place, but the next step is to persist places/trips on more than just CoreData. I hooked up Firebase login with this in mind. I will probably add a "Get Directions" feature that assembles your itinerary in the order you added the places. The next step after that would be to add helpers for the most efficient path through the places, then give you a map with the whole thing drawn out for you. Eventually I'd hook up url-schemes, etc.. to make the whole itinerary shareable through the UIActivityViewController.

Here are some screenshots!

![signin-signup-firebase](https://github.com/laurennicoleroth/Itinerant/blob/readme/screenshots/image5.png)
![where-to-screenshot](https://github.com/laurennicoleroth/Itinerant/blob/readme/screenshots/image1.png)
![where-to-screenshot](https://github.com/laurennicoleroth/Itinerant/blob/readme/screenshots/image2.png)
![where-to-screenshot](https://github.com/laurennicoleroth/Itinerant/blob/readme/screenshots/image3.png)
![where-to-screenshot](https://github.com/laurennicoleroth/Itinerant/blob/readme/screenshots/image4.png)

## Getting Started

Itinerant uses pods, so pod install. One file is missing, on purpose, and that is the Keys.plist file.

```Swift
<key>googleMapsAPIKey</key>
  <string>Your Google Maps Key</string>
  <key>googlePlacesAPIKey</key>
  <string>Your Google Places Key - Be sure to restrict access to com.Itinerant</string>
```

### Prerequisites

A love of travel and Xcode 8+

### Installing

```
1. Add that Keys.plist
2. pod install
3. open Itinerant.xcworkspace
4. create an account - name, email, password (persisted on firebase)
5. accept location sharing
6. start building an itinerary!
```

## Built With

* [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [RxGoogleMaps](https://github.com/RxSwiftCommunity/RxGoogleMaps)
* [GoogleMaps](https://github.com/googlemaps/)
* [GooglePlaces](https://developers.google.com/places/ios-api/start)
* [Firebase](https://firebase.google.com/docs/ios/setup)
* [Cosmos](https://github.com/evgenyneu/Cosmos)

## Authors

* **Lauren N. Roth** - *Initial work on a bigger idea*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Google(Maps/Places/Firebase - thanks!) - UIKit - CoreData - Computers That Fit In Your Pocket