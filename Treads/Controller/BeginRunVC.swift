//
//  BeginRunVC.swift
//  Treads
//
//  Created by MacBook Pro on 7/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

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
        
        
//        print("here ary my runs: \(Run.getAllRuns())")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //manager?.delegate = self as? CLLocationManagerDelegate  //ne treba nam ovo jer smo dole spustili ekstenziju i nema potrebe za kastovanje
        manager?.delegate = self
        mapView.delegate = self
        manager?.startUpdatingLocation()
        //getLastRun()
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        zatvaranjeLastRun(da: true)
        centerMapOnUserLocation()
    }
    
    func zatvaranjeLastRun(da: Bool){
        lastRunStack.isHidden = da
        lastRunBgView.isHidden = da
        lastRunCloseBtn.isHidden = da
    }
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
            zatvaranjeLastRun(da: false)
        } else {
            zatvaranjeLastRun(da: true)
            centerMapOnUserLocation()
        }
        
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
        
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.metersToKilometers(place: 2)) km"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
        
        var coordinate = [CLLocationCoordinate2D]()
        for location in lastRun.lokacije {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        mapView.userTrackingMode = .none
        mapView.setRegion(centerMapOnPrevRout(locations: lastRun.lokacije), animated: true)
        
        return MKPolyline(coordinates: coordinate, count: lastRun.lokacije.count)
    }
    
//    func getLastRun() {
//
//        //zatvaranjeLastRun(da: false)  //prebaceno u setupMapView
//        paceLbl.text = lastRun.pace.formatTimeDurationToString()
//        distanceLbl.text = "\(lastRun.distance.metersToKilometers(place: 2)) km"
//        durationLbl.text = lastRun.duration.formatTimeDurationToString()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    func centerMapOnUserLocation() {
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPrevRout(locations: List<Location>) -> MKCoordinateRegion{
        guard let initialLocation = locations.first else { return MKCoordinateRegion() }
        var minLat = initialLocation.latitude
        var minLng = initialLocation.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2, longitude: (minLng + maxLng)/2), span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.4, longitudeDelta: (maxLng-minLng)*1.4))
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
}

extension BeginRunVC: CLLocationManagerDelegate {
//    precica didChangeAuthor
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
//            mapView.userTrackingMode = .follow
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let rendered = MKPolylineRenderer(polyline: polyline)
        rendered.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        rendered.lineWidth = 4
        return rendered
    }
}

