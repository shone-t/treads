//
//  CurrentRunVC.swift
//  Treads
//
//  Created by MacBook Pro on 7/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

//class CurrentRunVC: UIViewController {
class CurrentRunVC: LocationVC {

    @IBOutlet weak var swipeBGImageVIew: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var visinaLbl: UILabel!
    
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    
    fileprivate var runDistance: Double = 0.0
    
    fileprivate var counter = 0
    fileprivate var timer = Timer()
    
    fileprivate var pace = 0
    
    fileprivate var koordianteLokacije = List<Location>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let  swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10 //koliko cesto valjda da stavlja tacke, 10metara (metri su po difoltu)
        startRun()
    }
    
    func startRun(){
        manager?.startUpdatingLocation()
        startTimer()
        pauseBtn.setImage(UIImage(named: "pauseButton"), for: .normal)
    }
    func endRun() {
        manager?.stopUpdatingLocation()
        //ovde dodajemo podatke u bazu, odavde tek cuvamo
        Run.addRunToRealm(pace: pace, distance: runDistance, duration: counter, lokacije2: koordianteLokacije)
    }
    
    func startTimer(){
        durationLbl.text = counter.formatTimeDurationToString()
        //skracenica timer selector
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateCounter() {
        counter += 1
        durationLbl.text = counter.formatTimeDurationToString()
    }
    func calculatePace(time second: Int, miles: Double) -> String {
        pace = Int(Double(second) / miles)
//        print("pace1 \(pace)")
//        print("pace2 \(pace.formatTimeDurationToString())")

        return pace.formatTimeDurationToString()
}    
    func pauseRun(){
        
        startLocation = nil
        lastLocation = nil
        timer.invalidate()
        manager?.stopUpdatingLocation()
        pauseBtn.setImage(UIImage(named: "resumeButton"), for: .normal)
        
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid {
            pauseRun()
        } else {
                startRun()
        }
        
    }
    
    @objc func endRunSwiped(sender: UIPanGestureRecognizer) {
        let minAdjust: CGFloat = 80
        let maxAdjust: CGFloat = 130
        //kreiranje pokreta
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizer.State.began || sender.state == UIGestureRecognizer.State.changed {
                let translation = sender.translation(in: self.view)
                if sliderView.center.x >= (swipeBGImageVIew.center.x - minAdjust) && sliderView.center.x <= (swipeBGImageVIew.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if  sliderView.center.x >= (swipeBGImageVIew.center.x + maxAdjust) {
                    sliderView.center.x = swipeBGImageVIew.center.x + maxAdjust
                    //end run code goes here
                    endRun()
                    //end run code goes here
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = swipeBGImageVIew.center.x - minAdjust
                }
                
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == UIGestureRecognizer.State.ended {
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.swipeBGImageVIew.center.x - minAdjust
                }
            }
        }
    }
}


extension CurrentRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            runDistance += lastLocation.distance(from: location)
            
            //ovde na kraju dodajemo ovu lokaciju kako bi upisali i nacrtali putanju
            let newLocation = Location(latitude: Double(lastLocation.coordinate.latitude), longitude: Double(lastLocation.coordinate.longitude))
            koordianteLokacije.insert(newLocation, at: 0)
            //distanceLbl.text = "\(runDistance)" //u metrima
            distanceLbl.text = "\(runDistance.metersToKilometers(place: 2))"
            if counter > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(time: counter, miles: runDistance.metersToKilometers(place: 2))
            }
            visinaLbl.text = "\(location.altitude) m"
//            print(location.altitude)
        }
        lastLocation = locations.last
    }
}
