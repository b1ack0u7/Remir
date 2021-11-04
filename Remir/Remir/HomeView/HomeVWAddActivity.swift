//
//  HomeVWAddActivity.swift
//  Remir
//
//  Created by Axel Montes de Oca on 27/06/21.
//

import SwiftUI

struct HomeVWAddActivity: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showModalAddActivity:Bool
    @State var weekDays:[String]
    @State var lan:String
    let currentDayE:String

    
    @State private var activityTitle = ""
    @State private var activityNote = ""
    
    @State private var colorTags:[String] = ["MDL red", "MDL green", "MDL blue", "MDL orange", "MDL purple", "MDL cyan", "MDL default"]
    @State private var selectedTag:Int = 6
    
    @State private var selectedDays:[Bool] = Array(repeating: false, count: 7)
    @State private var selectedDaysARR:[String] = []
    
    @State private var startDate:Date = Date()
    @State private var endDate:Date = Date()
    
    @State private var taskContainer:[STCTaskContainer] = []
    @State private var addItem:Bool = false
    
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()

            VStack {
                //Top bar
                Capsule()
                    .frame(width: 100, height: 4, alignment: .top)
                    .padding(.top, 15)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading) {
                        TextField("Activity Name", text: $activityTitle)
                            .placeholder(when: activityTitle.isEmpty) {
                                Text("Activity Name").foregroundColor(.gray)
                            }
                            .font(.system(size: 35, weight: .bold))
                            
                        TextField("", text: $activityNote)
                            .placeholder(when: activityNote.isEmpty) {
                                Text("+ Add Note").foregroundColor(.white)
                            }
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, alignment: .center)
                            .foregroundColor(Color("MDL icon-bg"))
                        Image("Search-Icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, alignment: .center)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 25)
                .padding([.leading, .trailing], 20)
                
                //Color Tags
                HStack {
                    ForEach(colorTags.indices, id: \.self) { index in
                        ZStack {
                            Circle()
                                .foregroundColor(Color(colorTags[index]))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, alignment: .center)
                                .padding([.trailing, .leading], 5)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedTag = index
                                    }
                                }
                            if(index == selectedTag) {
                                Image("Select")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, alignment: .center)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.bottom, 15)
                
                //Week Selector
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("MDL week-selector-bg"))
                        .cornerRadius(10)
                    HStack(spacing: 0) {
                        ForEach(weekDays.indices, id: \.self) { index in
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color(.clear))
                                    .background(index == 0 || index == 6 ? RoundedCorners(tl: index == 0 ? 10 : 0, tr: index == 0 ? 0 : 10, bl: index == 0 ? 10 : 0, br: index == 0 ? 0 : 10).fill(selectedDays[index] ? Color("MDL week-selected") : Color(.clear)) : RoundedCorners().fill(selectedDays[index] ? Color("MDL week-selected") : Color(.clear)))
                                    
                                Text("\(weekDays[index])")
                                    .font(.system(size: 20))
                                    .bold()
                                    .foregroundColor(Color("MDL color-letters"))
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedDays[index].toggle()
                                }
                            }
                        }  
                    }
                }
                .frame(width: 350, height: 45, alignment: .center)
                .padding(.bottom, 40)
                
                //Time Selector
                VStack {
                    HStack {
                        Text("Initial date")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 25))
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .colorScheme(.dark)
                    }
                    .padding(.bottom, 30)
                    
                    HStack {
                        Text("End date")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 25))
                        Spacer()
                        DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .colorScheme(.dark)
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding([.leading, .trailing], 20)
                .padding(.bottom, 20)

                //To-Do
                VStack(alignment: .leading) {
                    HStack {
                        Image("ToDo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundColor(Color("MDL divisor"))
                        Text("To-Do")
                            .font(.system(size: 22))
                            .foregroundColor(Color("MDL divisor"))
                    }
                    .padding(.leading, 40)
                    
                    GeometryReader() {geo in
                        Line(geometry: geo, X: 20)
                            .stroke(Color("MDL divisor"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .shadow(radius: 5, y: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 5)
                }
                .padding(.bottom, 15)
                
                //List
                ScrollView(.vertical, showsIndicators: true) {
                    ForEach(taskContainer.indices, id: \.self) { idx in
                        HStack {
                            Image("Check")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .foregroundColor(.white)
                             
                            Text("\(taskContainer[idx].title)")
                                .foregroundColor(.white)
                                .bold()
                                .font(.system(size: 20))
                            
                            Spacer()
                            
                            HStack {
                                Image("Timer")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 19)
                                    .foregroundColor(taskContainer[idx].thereIsTimer ? Color.blue : Color("MDL divisor"))
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .onTapGesture {deleteTasks(index: idx)}
                            }
                            
                        }
                        .padding([.leading, .trailing], 30)
                        .padding(.bottom, 10)
                    }
                    
                    //Button add To-do
                    Button(action: {
                        taskContainer.append(STCTaskContainer())
                        addItem = true
                    }, label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(Color("MDL divisor"))
                            
                            Text("Add To-Do")
                                .font(.system(size: 20))
                                .foregroundColor(Color("MDL divisor"))
                        }
                        .padding(.leading, 30)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                
            }.disabled(addItem)
            
            if addItem {
                TodayVWZoomToDo(isShowing: $addItem, taskContainer: $taskContainer.last!)
                    .transition(AnyTransition.scale.animation(.easeInOut))
                    .shadow(radius: 5)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if(lan == "es") {
                weekDays[2] = "Xiércoles"
            }
            for i in 0..<weekDays.count {
                weekDays[i] = weekDays[i].map {String($0)}.first!
            }
        }
        .onDisappear {saveItem()}
    }
    
    private func deleteTasks(index: Int) {
        withAnimation(.easeInOut){
            _ = taskContainer.remove(at: index)
        }
    }
    
    private func saveTasks() -> [Task] {
        if(taskContainer.count != 0) {
            var newTask:[Task] = []
            
            for i in 0..<taskContainer.count {
                newTask.append(Task(title: taskContainer[i].title, isCompleted: false, isTimer: taskContainer[i].thereIsTimer, hour: taskContainer[i].hours, min: taskContainer[i].mins))
            }
            
            return newTask
        }
        else {return []}
    }
    
    private func saveItem() {
        for i in 0..<weekDays.count {
            if(selectedDays[i] == true) {
                selectedDaysARR.append(weekDays[i])
            }
        }
        
        let joinedSelectedDays = selectedDaysARR.joined(separator: ",")
        
        if(activityTitle != "" && joinedSelectedDays != "") {
            let newItem = Item(context: viewContext)
            newItem.title = activityTitle
            newItem.note = activityNote
            newItem.colorTag = colorTags[selectedTag]
            newItem.weeksSelected = joinedSelectedDays
            newItem.startDate = startDate
            newItem.endDate = endDate
            
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate)
            newItem.timeSort = "\(timeComponents.hour! as Int):\(timeComponents.minute! as Int)"
            newItem.time12HStart = formatAct(date: startDate)
            newItem.time12HEnd = formatAct(date: endDate)
            newItem.tasks = saveTasks()
            newItem.tasksCount = Int32(taskContainer.count)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("DBGE: Unresolved error \(nsError), \(nsError.userInfo)")
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

struct HomeVWAddActivity_Previews: PreviewProvider {
    static var previews: some View {
        HomeVWAddActivity(showModalAddActivity: .constant(true), weekDays: ["Mon","Tue","Wed", "Thu","Fri","Sat","Sun"], lan: "es", currentDayE: "S")
    }
}
