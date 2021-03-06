//
//  ContentView.swift
//  Remir
//
//  Created by Axel Montes de Oca on 25/06/21.
//

import SwiftUI

struct ContentView: View {
    var dataTrans = CLSDataTrans()
    @State private var tabIcons:[String] = ["Menu-Today","Menu-Activity","Menu-Pomodor","Menu-Settings"]
    @State private var tabIndex:Int = 1
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            switch tabIndex {
            case 0:
                TodayVW()
            case 1:
                HomeVW()
            case 2:
                PomodorVW()
            case 3:
                SettingsVW()
            default:
                Text("Default")
            }

            ZStack {
                Color("ITF background")
                Rectangle()
                    .foregroundColor(Color("ITF seccion"))
                    .cornerRadius(25)
                    .shadow(radius: 6)
                    .edgesIgnoringSafeArea(.bottom)
                
                
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 14) {
                    ForEach(0..<tabIcons.count, id: \.self) { i in
                        Spacer()
                        ZStack {
                            //Selected Option
                            if(i == tabIndex) {
                                Circle()
                                    .foregroundColor(Color("ITF selection"))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                            }
                            
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                withAnimation(.linear) {
                                    tabIndex = i
                                }
                            }, label: {
                                Image("\(tabIcons[i])")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25)
                                    .foregroundColor(i == tabIndex ? Color.white : Color("ITF icons-menu"))
                            })
                        }
                        .frame(width: 60, alignment: .center)
                        Spacer()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
        }
        .environmentObject(dataTrans)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12")
            
    }
}
