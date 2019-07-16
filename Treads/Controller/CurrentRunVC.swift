//
//  CurrentRunVC.swift
//  Treads
//
//  Created by MacBook Pro on 7/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import MapKit

//class CurrentRunVC: UIViewController {
class CurrentRunVC: LocationVC {

    @IBOutlet weak var swipeBGImageVIew: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    
    var runDistance: Double = 0.0
    
    var counter = 0
    var timer = Timer()
    
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
    }
    func endRun() {
        manager?.stopUpdatingLocation()
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
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
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
            //distanceLbl.text = "\(runDistance)" //u metrima
            distanceLbl.text = "\(runDistance.metersToMiles(place: 2))" //u miljama
        }
        lastLocation = locations.last
    }
}
