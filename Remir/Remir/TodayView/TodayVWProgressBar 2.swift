//
//  TodayVWProgressBar.swift
//  Remir
//
//  Created by Axel Montes de Oca on 08/07/21.
//

import SwiftUI

struct TodayVWProgressBar: View {
    @Binding var valueSlider:Float
    let colorBar:String
    var heightBar:CGFloat = 20
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Capsule()
                    .frame(height: heightBar, alignment: .center)
                    .foregroundColor(Color("MDL divisor"))
                
                Capsule()
                    .frame(width: min(CGFloat(valueSlider)*geometry.size.width, geometry.size.width), height: heightBar, alignment: .center)
                    .foregroundColor(Color(colorBar))
            }
        }
    }
}

/*
struct TodayVWProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWProgressBar(valueSlider: .constant(0.25), colorBar: "MDL purple")
    }
}
 */
