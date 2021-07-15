//
//  TodayVWVariant1.swift
//  Remir
//
//  Created by Axel Montes de Oca on 07/07/21.
//

import SwiftUI

struct TodayVWVariant1: View {
    @Binding var currentItem:Item
    
    var body: some View {
        ZStack {
            Color("ITF seccion")
            
            HStack {
                HStack {
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .foregroundColor(Color(currentItem.colorTag!))
                    VStack {
                        Text("\(currentItem.title!)")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                        
                        Text("\(currentItem.note ?? "Notas")")
                            .font(.system(size: 14))
                            .foregroundColor(Color("MDL divisor"))
                    }
                    
                }
                Spacer()
                ZStack {
                    Capsule()
                        .frame(width: 3, height: 18, alignment: .center)
                    
                    VStack {
                        Text(currentItem.time12HStart!)
                        Spacer()
                        Text(currentItem.time12HEnd!)
                    }
                    .padding([.top, .bottom], 5)
                }
                .foregroundColor(.white)
            }
            .padding([.leading, .trailing], 15)
        }
        .cornerRadius(15)
        .frame(height: 70, alignment: .center)
        .padding([.leading, .trailing], 20)
    }
}

/*
struct TodayVWVariant1_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWVariant1()
    }
}
*/
