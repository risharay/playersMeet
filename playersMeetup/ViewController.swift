//
//  ViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/25/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Moya


class ViewController: UIViewController, CLLocationManagerDelegate {
//    CURRENT LOCATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     let locationManager = CLLocationManager()
    var long: Double = 0.0
    var lat: Double = 0.0
    @IBAction func getLocation(_ sender: Any) {
          self.locationManager.requestAlwaysAuthorization()

                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization()

                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
           print("locations = \(locValue.latitude) \(locValue.longitude)")
        print("latitude = \(locValue.latitude)")
        print("longitude = \(locValue.longitude)")
        long = locValue.longitude
        lat = locValue.latitude
        
    }
//    UPDATE REALTIME DATABASE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //    var ref = Database.database().reference()
    let conditionRef = Database.database().reference().ref.child("condition")
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionRef.observe(DataEventType.value, with: { (snapshot) in
        ///listen in realtime to whenever it updates
            self.conditionLabel.text = (snapshot.value as AnyObject).description
        })
       conditionRef.observe(DataEventType.value, with: { (snapshot) in
        self.counter = snapshot.value as! Int
        })
    }
    @IBAction func sunnyDidTouch(_ sender: Any) {
        
        counter = counter + 1
        conditionRef.setValue(counter)
    }
    @IBAction func foggyDidTouch(_ sender: Any) {
        counter = counter - 1
        conditionRef.setValue(counter)
    }
    @IBOutlet weak var conditionLabel: UILabel!
    ///    var ref : DatabaseReference!
    
    
//    TESTING YELP ///////////////////////
    let service = MoyaProvider<YelpService.BusinessesProvider>()
    let jsonDecoder = JSONDecoder()
    @IBAction func testYelp(_ sender: Any) {
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase ///letting it know camel case
        service.request(.search(lat: lat , long: long)) { (result) in switch result {
        case .success(let response):
            let root = try? self.jsonDecoder.decode(Root.self, from: response.data)
            let viewModels = root?.businesses.compactMap(CourtListViewModel.init)
///            print(try? JSONSerialization.jsonObject(with: response.data, options: []))
            print(root)
        case .failure(let error):
            print("Error: \(error)")
            }
        }
    }
}

