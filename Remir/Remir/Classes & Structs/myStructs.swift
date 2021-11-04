//
//  myStructs.swift
//  Remir
//
//  Created by Axel Montes de Oca on 28/06/21.
//

import Foundation
import SwiftUI

//Resources: https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}

struct Line : Shape {
    let geometry: GeometryProxy
    var X: CGFloat = 0
    var Y:CGFloat = 0
    var orientation: String = "Default"
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: X, y: orientation == "Default" ? Y : geometry.size.height + Y))
        path.addLine(to: CGPoint(x: geometry.size.width-X, y: orientation == "Default" ? 0 : geometry.size.height + Y))
        return path
       }
   }

//Used: HomeVWAddActivity, TodayVWZoomToDo
struct STCTaskContainer {
    var title:String = ""
    var thereIsTimer:Bool = false
    var hours:Int = 0
    var mins:Int = 0
}

struct STCSimpleTask {
    let title:String
    var isCompleted:Bool
    let hour:Int
    let min:Int
}
