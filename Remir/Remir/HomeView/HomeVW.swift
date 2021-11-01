//
//  HomeVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 05/07/21.
//

import SwiftUI
import CoreData

struct HomeVW: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataTrans: CLSDataTrans
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: []) private var items: FetchedResults <Item>
    
    @State private var filteredItems:[Item] = []
    
    let layout = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var currentInfo:[String] = ["dayNumber","Month","Year","EEEE","EEE"]
    @State private var daySelected:String = ""
    @State private var dayWTHNameSelected:String = ""
    @State private var days:[String] = []
    @State private var daysWTHNames:[String] = []
    @State private var weekDays:[String] = []

    @State private var showModalAddActivity:Bool = false

    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            VStack {
                //Top Bar
                VStack {
                    ZStack {
                        Text("\(currentInfo[3].capitalized)")
                            .font(.system(size: 40))
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            //Button Today
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                    daySelected = currentInfo.first!
                                    dayWTHNameSelected = currentInfo[4].map {String($0)}.first!.uppercased()
                                }
                            }, label: {
                                ZStack {
                                    Capsule()
                                        .frame(width: 70, height: 40, alignment: .center)
                                        .foregroundColor(Color("ITF seccion"))
                                    Text("Today")
                                        .bold()
                                        .foregroundColor(.white)
                                }.padding(.leading, 20)
                            })
                            
                            Spacer()
                            
                            //Button Add
                            Button(action: {
                                showModalAddActivity = true
                            }, label: {
                                Image("Add")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 20)
                            })
                        }
                    }
                    
                    Text("\(currentInfo[1].capitalized) \(currentInfo[2])")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
                
                //Calendar
                ZStack {
                    Color("ITF seccion")
                    
                    //WeekDays
                    VStack {
                        Capsule()
                            .frame(height: 1, alignment: .center)
                            .foregroundColor(Color("ITF calendar-border"))
                        
                        LazyVGrid(columns: layout) {
                            ForEach(weekDays, id: \.self) { days in
                                Text("\(days)")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 5)
                            }
                        }
                        .padding([.bottom, .top], 4)

                        Capsule()
                            .frame(height: 1, alignment: .center)
                            .foregroundColor(Color("ITF calendar-border"))
                        
                        //Days
                        LazyVGrid(columns: layout, spacing: 20) {
                            ForEach(days.indices, id: \.self) { index in
                                ZStack {
                                    if(daySelected == days[index]) {
                                        Circle()
                                            .frame(width: 35, height: 35, alignment: .center)
                                            .foregroundColor(Color("ITF selection"))
                                    }
                                    
                                    Text("\(days[index])")
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .onTapGesture {
                                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                            withAnimation(.easeIn(duration: 0.2)) {
                                                daySelected = days[index]
                                                dayWTHNameSelected = daysWTHNames[index]
                                                sortingDisplay()
                                            }
                                        }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 350)
                
                //Activities
                VStack {
                    Text("Activities")
                        .font(.system(size: 40))
                        .bold()
                        .foregroundColor(.white)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible())]) {
                            ForEach(filteredItems, id: \.self) { currentItem in
                                HomeVWDisplayActivities(currentItem: currentItem)
                                    .contextMenu(menuItems: {
                                        Button(action: {
                                            deleteItems(idIndex: currentItem.id)
                                        }, label: {
                                            Image(systemName: "trash")
                                            Text("Delete")
                                        })
                                        
                                        Button(action: {
                                            ()
                                        }, label: {
                                            Image(systemName: "square.and.pencil")
                                            Text("Edit")
                                        })
                                    })
                            }
                        }
                    }
                }
                .padding(.top, 35)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showModalAddActivity, onDismiss: {
            sortingDisplay()
        }, content: {
            HomeVWAddActivity(showModalAddActivity: $showModalAddActivity, weekDays: weekDays, lan: "es", currentDayE: dayWTHNameSelected).environment(\.managedObjectContext, viewContext)
        })
        .onAppear{
            getWeekDays(lan: "es")
            StartEndOfMonth(lan: "es")
            sortingDisplay()
            
            dataTrans.currentInfo = currentInfo
        }
        
    }
    
    private func sortingDisplay() {
        print("DBG1: \(dayWTHNameSelected)")
        print("DBG2: \(items.count)")
        
    }
    
    private func getWeekDays(lan: String) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        var days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }  // use `flatMap` in Xcode versions before 9.3

        days.insert(days.first!, at: days.count)
        days.removeFirst()

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: lan)

        let strings = days.map { formatter.string(from: $0).capitalized }
        weekDays = strings
    }
    
    private func StartEndOfMonth(lan: String) {
        var tmpWeekDays:[String] = weekDays
        if(lan == "es") {
            tmpWeekDays[2] = "Xiércoles"
        }
        
        let currentDate = format(date: Date(), lan: lan).components(separatedBy: "/")
        for i in 0..<currentDate.count {
            if(lan == "es" && i == 4 && currentDate[4] == "mié") {
                currentInfo[i] = "xíe"
            }
            else {
                currentInfo[i] = currentDate[i]
            }
        }
        
        let tmpCheck0 = Array(currentInfo.first!)
        if(tmpCheck0[0] == "0"){ currentInfo[0] = String(tmpCheck0[1]) }
        
        daySelected = currentInfo.first!
        dayWTHNameSelected = currentInfo[4].map {String($0)}.first!.uppercased()
        
        var components = Calendar.current.dateComponents([.year, .month], from: Date())
        let tempStart = Calendar.current.date(from: components)
        let startString = format(date: tempStart!, lan: lan).components(separatedBy: "/")

        let startName = startString.last?.capitalized
        
        components.month = (components.month ?? 0) + 1
        components.hour = (components.hour ?? 0) - 1
        let tempEnd = Calendar.current.date(from: components)
        let endString = format(date: tempEnd!, lan: lan).components(separatedBy: "/")
        
        var index:Int = 0
        for (idx,value) in tmpWeekDays.enumerated() {
            if(value == startString.last) {
                index = idx
                break
            }
        }
        
        var tempDays:[String] = []
        var tempDaysWTHNames:[String] = []
        for i in Int(startString[0])!...Int(endString[0])! {
            tempDays.append(String(i))
            tempDaysWTHNames.append(tmpWeekDays[index].map {String($0)}.first!)
            index += 1
            if(index == tmpWeekDays.count) {index = 0}
        }
        
        //Fix preDays
        var ii = 0
        for i in 0..<tmpWeekDays.count {
            if(startName == tmpWeekDays[i]) {
                ii = i
                break
            }
        }

        for _ in 1...ii {
            tempDays.insert("", at: 0)
            tempDaysWTHNames.insert("", at: 0)
        }
        days = tempDays
        daysWTHNames = tempDaysWTHNames
    }
    
    private func format(date: Date, lan: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MMMM/yyyy/EEEE/EEE"
        dateFormatter.locale = Locale(identifier: lan)
        return dateFormatter.string(from: date)
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
    
    private func deleteItems(idIndex: ObjectIdentifier) {
        withAnimation {
            for i in 0..<items.count {
                if(idIndex == items[i].id) {
                    viewContext.delete(items[i])
                    break
                }
            }
            
            for i in 0..<filteredItems.count {
                if(idIndex == filteredItems[i].id) {
                    filteredItems.remove(at: i)
                    break
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct HomeVW_Previews: PreviewProvider {
    static var previews: some View {
        HomeVW()
            .environmentObject(CLSDataTrans())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.locale, .init(identifier: "es"))
            .previewDevice("iPhone 12")
    }
}
