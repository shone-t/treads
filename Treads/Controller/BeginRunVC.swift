//
//  BeginRunVC.swift
//  Treads
//
//  Created by MacBook Pro on 7/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import MapKit

class BeginRunVC: LocationVC {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        mapView.delegate = self
        
        //print("here ary my runs: \(Run.getAllRuns())")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //manager?.delegate = self as? CLLocationManagerDelegate  //ne treba nam ovo jer smo dole spustili ekstenziju i nema potrebe za kastovanje
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        
    }
    
}

extension BeginRunVC: CLLocationManagerDelegate {
//    precica didChangeAuthor
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

