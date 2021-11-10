//
//  myClasses.swift
//  Remir
//
//  Created by Axel Montes de Oca on 26/06/21.
//

import Foundation
import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class CLSDataTrans: ObservableObject {
    @Published var currentInfo:[String] = []
    @Published var currentLan:String = ""
}

class ClassesContainer {
    public func daysWeekName(lan:String) -> [String] {
        if(lan == "es") {
            return ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
        }
        else {
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }
    
    public func Format24H(date:Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "HH:mm:ss"
      return dateFormatter.string(from: date)
    }
    
    public func FormatYearMonthDay(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

//Resource https://medium.com/@rezafarahani/store-array-of-custom-object-in-coredata-bea77b9eb629
public class Task: NSObject, NSCoding {
    let title:String
    var isCompleted:Bool
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

//BUG COREDATA: https://www.reddit.com/r/SwiftUI/comments/h0fyck/swiftui_coredata_preview_canvas_asks_for_migration/
