//
//  myClasses.swift
//  Remir
//
//  Created by Axel Montes de Oca on 26/06/21.
//

import Foundation
import SwiftUI

class CLSDataTrans: ObservableObject {
    @Published var currentInfo:[String] = []
    //@Published var currentItem:[Item] = []
}

/*
class TaskAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [Task.self]
    }
    
    static func register() {
        let className = String(describing: TaskAttributeTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = TaskAttributeTransformer()
        
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
*/
 
public class Task: NSObject, NSCoding {
    let title:String
    let isCompleted:Bool
    let isTimer:Bool
    let hour:Int
    let min:Int
    
    enum Keys:String {
        case title = "title"
        case isCompleted = "isCompleted"
        case isTimer = "isTimer"
        case hour = "hour"
        case min = "min"
    }
    
    init(title:String, isCompleted:Bool, isTimer:Bool, hour:Int, min:Int) {
        self.title = title
        self.isCompleted = isCompleted
        self.isTimer = isTimer
        self.hour = hour
        self.min = min
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(title, forKey: Keys.title.rawValue)
        coder.encode(isCompleted, forKey: Keys.isCompleted.rawValue)
        coder.encode(isTimer, forKey: Keys.isTimer.rawValue)
        coder.encode(hour, forKey: Keys.hour.rawValue)
        coder.encode(min, forKey: Keys.min.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let Mtitle = coder.decodeObject(forKey: Keys.title.rawValue) as! String
        let MisCompleted = coder.decodeBool(forKey: Keys.isCompleted.rawValue)
        let MisTimer = coder.decodeBool(forKey: Keys.isTimer.rawValue)
        let Mhour = Int(coder.decodeInt32(forKey: Keys.hour.rawValue))
        let Mmin = Int(coder.decodeInt32(forKey: Keys.min.rawValue))
        
        self.init(title: Mtitle, isCompleted: MisCompleted, isTimer: MisTimer, hour: Mhour, min: Mmin)
    }
}
