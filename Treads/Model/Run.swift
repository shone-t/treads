//
//  Run.swift
//  Treads
//
//  Created by MacBook Pro on 7/17/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
import RealmSwift

class Run: Object {
    @objc dynamic public private(set) var id = ""
    @objc dynamic public private(set) var date = NSDate()
    @objc dynamic public private(set) var pace = 0
    @objc dynamic public private(set) var distance = 0.0
    @objc dynamic public private(set) var duration = 0
    public private(set) var lokacije = List<Location>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    override class func indexedProperties() -> [String] {
        return ["pace", "date", "duration"]
    }
    convenience init(pace: Int, distance: Double, duration: Int, lokacije: List<Location>) {
        self.init()
        self.id = UUID().uuidString.lowercased() //dodeljivanje nasumicnog indetifikatora
        self.date = NSDate()
        self.pace = pace
        self.distance = distance
        self.duration = duration
        
        self.lokacije = lokacije
    }
    
    static func addRunToRealm(pace: Int, distance: Double, duration: Int, lokacije2: List<Location>){
        REALM_QUEUE.sync {
            let ourRUn = Run(pace: pace, distance: distance, duration: duration, lokacije: lokacije2)
            do {
                let realm = try Realm(configuration: RealmConfig.runDataConfig)
                try realm.write {
                    realm.add(ourRUn)
                    try realm.commitWrite()
                }
                
            } catch {
                debugPrint("Error adding run to realm")
            }
        }
        
    }
    static func getAllRuns() -> Results<Run>? {
        do {
            let realm = try Realm(configuration: RealmConfig.runDataConfig)
            var runs = realm.objects(Run.self)
            runs = runs.sorted(byKeyPath: "date", ascending: false)
            return runs
        } catch {
            return nil
        }
    }
}
