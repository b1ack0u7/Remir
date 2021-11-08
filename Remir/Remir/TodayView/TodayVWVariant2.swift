//
//  TodayVWVariant2.swift
//  Remir
//
//  Created by Axel Montes de Oca on 07/07/21.
//


import SwiftUI

struct TodayVWVariant2: View {
    @Binding var currentItem:Item
    
    @State private var tasksCountCompleted:Int = 0
    @State private var tasksCountProgressBar:Float = 0
    
    @State private var iconSelected:String = "None"
    @State private var colorSelected:String = "ICN red"
    @State private var textSelected:String = "None"
    
    @State private var showTimer:Bool = false
    @State private var simpleTask:STCSimpleTask = STCSimpleTask(title: "", isCompleted: false, hour: 0, min: 0)
    
    var body: some View {
        ZStack {
            Color("ITF seccion")
            
            VStack {
                //Icon, Title and Notes
                HStack {
                    HStack {
                        Circle()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(Color(currentItem.colorTag!))
                        
                        VStack(alignment: .leading) {
                            Text("\(currentItem.title!)")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                            
                            Text("\(currentItem.note ?? "Notas")")
                                .font(.system(size: 14))
                                .foregroundColor(Color("MDL divisor"))
                        }
                    }
                    
                    Spacer()
                    
                    //Icon Status
                    VStack {
                        Image(iconSelected)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, alignment: .center)
                            .foregroundColor(Color(colorSelected))
                        Text(textSelected)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(.top, -6)
                    }
                }
                .padding([.leading, .trailing], 15)
                
                //Info
                HStack {
                    //Time
                    VStack {
                        Text("\(currentItem.time12HStart!)")
                            .padding(.bottom, -1)
                        Capsule()
                            .frame(width: 3, alignment: .center)
                        Text("\(currentItem.time12HEnd!)")
                    }
                    .foregroundColor(.white)
                    
                    //To-Do
                    VStack {
                        //Todo icon
                        HStack {
                            Image("ToDo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, alignment: .center)
                            Text("To-Do \(tasksCountCompleted)/\(currentItem.tasksCount)")
                            Spacer()
                        }
                        .foregroundColor(Color("MDL divisor"))
                        .padding([.leading, .trailing], 10)
                        
                        //Progress bar                        
                        TodayVWProgressBar(valueSlider: $tasksCountProgressBar, colorBar: currentItem.colorTag!, heightBar: 6)
                        
                        //Tasks
                        ForEach(currentItem.tasks!.indices, id: \.self) { idx in
                            HStack {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    if(currentItem.tasks![idx].isCompleted == false) {
                                        currentItem.tasks![idx].isCompleted = true
                                        tasksCountCompleted += 1
                                        
                                        withAnimation(.spring()) {
                                            tasksCountProgressBar += 1/Float(currentItem.tasksCount)
                                        }
                                    }
                                    else {
                                        currentItem.tasks![idx].isCompleted = false
                                        tasksCountCompleted -= 1
                                        
                                        withAnimation(.interpolatingSpring(mass: 1, stiffness: 60, damping: 10, initialVelocity: 1)) {
                                            tasksCountProgressBar -= 1/Float(currentItem.tasksCount)
                                            if(tasksCountProgressBar < 0.0001) {
                                                tasksCountProgressBar = 0
                                            }
                                        }
                                    }
                                }, label: {
                                    Image(currentItem.tasks![idx].isCompleted ? "Done" : "Check")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, alignment: .center)
                                        .foregroundColor(currentItem.tasks![idx].isCompleted  ? Color("ICN green") : Color(.white))
                                    
                                    Text(currentItem.tasks![idx].title)
                                        .bold()
                                })
                                
                                Spacer()
                                
                                if(currentItem.tasks![idx].isTimer == true) {
                                    Image("Timer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 17, alignment: .center)
                                        .foregroundColor(Color("ICN red"))
                                        .onTapGesture {
                                            showTimer.toggle()
                                            simpleTask = STCSimpleTask(title: currentItem.tasks![idx].title, isCompleted: currentItem.tasks![idx].isCompleted, hour: currentItem.tasks![idx].hour, min: currentItem.tasks![idx].min)
                                        }
                                        .fullScreenCover(isPresented: $showTimer) {
                                            ()
                                        } content: {
                                            TodayVWTimer(task: $simpleTask, showTimerView: $showTimer)
                                        }
                                }
                                
                            }
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 10)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                }
                .padding([.leading, .trailing], 10)
            }
            .padding([.top, .bottom], 15)
        }
        .cornerRadius(15)
        .padding([.leading, .trailing], 20)
        .onAppear {
            let currentDate = formatAct(date: Date())
            let startDate = formatAct(date: currentItem.startDate!)
            let endDate = formatAct(date: currentItem.endDate!)
            
            if(currentDate >= startDate && currentDate <= endDate) {
                iconSelected = "Progress"
                colorSelected = "ICN yellow"
                textSelected = "In Progress"
            }
            else if(currentDate > endDate) {
                iconSelected = "Pending"
                colorSelected = "ICN cyan"
                textSelected = "Pending"
            }
            
            for i in 0..<Int(currentItem.tasksCount) {
                if(currentItem.tasks![i].isCompleted == true) {
                    tasksCountCompleted += 1
                    withAnimation(.spring()) {
                        tasksCountProgressBar += 1/Float(currentItem.tasksCount)
                    }
                }
            }
        }
    }
    
    private func formatAct(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let tmpConvert12H = dateFormatter.string(from: date).components(separatedBy: " ")
        var subConvert12H = tmpConvert12H[0].components(separatedBy: ":")
        if(Int(subConvert12H[0])! > 12) {
            subConvert12H[0] = String(Int(subConvert12H[0])! - 12)
        }
        
        let joinedConverter12H = subConvert12H.joined(separator: ":") + " " + tmpConvert12H[1]
        return joinedConverter12H
    }
}


/*
struct TodayVWVariant2_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWVariant2()
    }
}
*/
