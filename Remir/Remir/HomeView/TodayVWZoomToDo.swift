//
//  TodayVWZoomToDo.swift
//  Remir
//
//  Created by Axel Montes de Oca on 29/06/21.
//

import SwiftUI

struct TodayVWZoomToDo: View {
    @Binding var isShowing:Bool
    @Binding var titleName:String
    @Binding var hourSelected:Int
    @Binding var minSelected:Int
    @Binding var timer:Bool
    

    @State private var dismisal:Bool = true
    
    let hour:[Int] = Array(0..<12)
    let minutes:[Int] = Array(0..<60)
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                VStack {
                    HStack {
                        Text("New Task")
                            .foregroundColor(.black)
                            .font(.system(size: 25))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            if(hourSelected != 0 || minSelected != 0) {
                                timer = true
                            }
                            withAnimation(.easeOut) {
                                isShowing = false
                            }
                        }, label: {
                            Text("OK")
                                .font(.title2)
                                .bold()
                                .foregroundColor(dismisal ? Color("MDL divisor") : .blue)
                        })
                        .disabled(dismisal)
                    }
                    TextField("", text: $titleName)
                        .foregroundColor(Color("MDL color-letters"))
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                VStack {
                    Text("Timer")
                        .foregroundColor(.black)
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Picker("H", selection: $hourSelected) {
                            ForEach(hour, id: \.self) { index in
                                Text("\(index) H").tag(index)
                            }
                        }
                        .frame(maxWidth: 100, maxHeight: 30)
                        .clipped()
                        
                        Picker("M", selection: $minSelected) {
                            ForEach(minutes, id: \.self) { index in
                                Text("\(index) M").tag(index)
                            }
                        }
                        .frame(maxWidth: 100, maxHeight: 30)
                        .clipped()
                    }
                }
            }.padding()
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            dismisal = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            dismisal = false
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(width: 300, height: 200, alignment: .center)
        .cornerRadius(20)
        .offset(y: -40)
        .animation(.easeInOut, value: 1)
    }
}

struct TodayVWZoomToDo_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWZoomToDo(isShowing: .constant(true), titleName: .constant(""), hourSelected: .constant(0), minSelected: .constant(0), timer: .constant(false))
    }
}
