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
    @IBOutlet weak var lastRunCloseBtn: UIButton!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var lastRunBgView: UIView!
    @IBOutlet weak var lastRunStack: UIStackView!
    
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
        getLastRun()
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        zatvaranjeLastRun(da: true)
    }
    func zatvaranjeLastRun(da: Bool){
        lastRunStack.isHidden = da
        lastRunBgView.isHidden = da
        lastRunCloseBtn.isHidden = da
    }
    
    
    func getLastRun() {
        guard let lastRun = Run.getAllRuns()?.first else {
            zatvaranjeLastRun(da: true)
            return
            
        }
        zatvaranjeLastRun(da: false)
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.metersToKilometers(place: 2)) km"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
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

