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
    @State private var dateDetermined:Int = -1
    
    @State private var showTimerView:Bool = false
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
                    
                    //Icon and Text Status
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
                    .frame(width: 80, alignment: .center)
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
                                    //Check the button; completed task
                                    if(currentItem.tasks![idx].isCompleted == false) {
                                        currentItem.tasks![idx].isCompleted = true
                                        tasksCountCompleted += 1
                                        
                                        withAnimation(.spring()) {
                                            tasksCountProgressBar += 1/Float(currentItem.tasksCount)
                                        }
                                    }
                                    //Check the button; uncomplete task
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
                                    
                                    checkCompletedTasks()
                                }, label: {
                                    Image(currentItem.tasks![idx].isCompleted ? "Done" : "Check")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, alignment: .center)
                                        .foregroundColor(currentItem.tasks![idx].isCompleted ? Color("ICN green") : Color(.white))
                                    
                                    Text(currentItem.tasks![idx].title)
                                        .bold()
                                })
                                
                                Spacer()
                                
                                if(currentItem.tasks![idx].isTimer == true) {
                                    Image("Timer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 17, alignment: .center)
                                        .foregroundColor(Color("MDL blue"))
                                        .onTapGesture {
                                            showTimerView.toggle()
                                            simpleTask = STCSimpleTask(title: currentItem.tasks![idx].title, isCompleted: currentItem.tasks![idx].isCompleted, hour: currentItem.tasks![idx].hour, min: currentItem.tasks![idx].min)
                                        }
                                        .fullScreenCover(isPresented: $showTimerView) {
                                            ()
                                        } content: {
                                            TodayVWTimer(task: $simpleTask, showTimerView: $showTimerView)
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
            initializeData()
        }
    }
    
    private func initializeData() {
        let currentDate = ClassesContainer().Format24H(date: Date())
        let startDate = ClassesContainer().Format24H(date: currentItem.startDate!)
        let endDate = ClassesContainer().Format24H(date: currentItem.endDate!)
        
        if(currentDate < startDate) {
            iconSelected = "Pending"
            colorSelected = "ICN cyan"
            textSelected = "Pending"
            dateDetermined = 0
        }
        else if(currentDate >= startDate && currentDate <= endDate) {
            iconSelected = "Progress"
            colorSelected = "ICN yellow"
            textSelected = "In Progress"
            dateDetermined = 1
            checkCompletedTasks()
        }
        else if(currentDate > endDate) {
            dateDetermined = 2
            checkCompletedTasks()
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
    
    private func checkCompletedTasks() {
        if(dateDetermined == 1 || dateDetermined == 2) {
            DispatchQueue.global(qos: .utility).async {
                var completedAllTasks = true
                
                for i in 0..<currentItem.tasks!.count {
                    if(!currentItem.tasks![i].isCompleted) {
                        completedAllTasks = false
                        break
                    }
                }
                
                if(dateDetermined == 1) {
                    DispatchQueue.main.async {
                        if(completedAllTasks) {
                            textSelected = "Done"
                            withAnimation(.interactiveSpring(response: 0.80, dampingFraction: 0.86, blendDuration: 0.25)) {
                                iconSelected = "Done"
                                colorSelected = "ICN green"
                            }
                            
                        }
                        else {
                            textSelected = "In Progress"
                            withAnimation(.interactiveSpring(response: 0.80, dampingFraction: 0.86, blendDuration: 0.25)) {
                                iconSelected = "Progress"
                                colorSelected = "ICN yellow"
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        if(completedAllTasks) {
                            textSelected = "Done"
                            withAnimation(.interactiveSpring(response: 0.80, dampingFraction: 0.86, blendDuration: 0.25)) {
                                iconSelected = "Done"
                                colorSelected = "ICN green"
                            }
                            
                        }
                        else {
                            textSelected = "Not completed"
                            withAnimation(.interactiveSpring(response: 0.80, dampingFraction: 0.86, blendDuration: 0.25)) {
                                iconSelected = "notDone"
                                colorSelected = "ICN red"
                            }
                        }
                    }
                }
                
            }
        }
    }
    
}


/*
struct TodayVWVariant2_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWVariant2()
    }
}
*/
