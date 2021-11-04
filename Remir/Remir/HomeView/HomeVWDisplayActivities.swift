//
//  HomeVWDisplayActivities.swift
//  Remir
//
//  Created by Axel Montes de Oca on 10/07/21.
//

import SwiftUI

struct HomeVWDisplayActivities: View {
    let currentItem:Item
    
    var body: some View {
        ZStack {
            Color("ITF seccion")
            
            //Icon To-Do
            if(currentItem.tasksCount != 0) {
                VStack {
                    Image("Activities-ToDo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("ICN yellow"))
                        .frame(width: 15)
                    Text("\(currentItem.tasksCount) To-Do")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.top, -6)
                }
                .frame(width: 160, alignment: .trailing)
            }
            
            HStack {
                HStack {
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .foregroundColor(Color(currentItem.colorTag!))
                    Text("\(currentItem.title!)")
                        .font(.system(size: 21))
                        .foregroundColor(.white)
                }
                Spacer()
                ZStack {
                    Capsule()
                        .frame(width: 4, height: 20, alignment: .center)
                        .foregroundColor(.white)
                    
                    VStack {
                        Text("\(currentItem.time12HStart!)")
                        Spacer()
                        Text("\(currentItem.time12HEnd!)")
                    }
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 5)
                }
            }
            .padding([.leading, .trailing], 15)
        }
        .frame(height: 70, alignment: .center)
    }
}

/*
struct HomeVWDisplayActivities_Previews: PreviewProvider {
    static var previews: some View {
        HomeVWDisplayActivities()
    }
}
*/
