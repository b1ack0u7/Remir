//
//  HomeVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 05/07/21.
//

import SwiftUI
import CoreData

private struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day:Int
    var date:Date
    var inicial:String?
}

struct HomeVW: View {
    @EnvironmentObject var dataTrans: CLSDataTrans
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], animation: .default) private var items: FetchedResults<Item>
    
    @State private var currentMonth:Int = 0
    @State private var weekDayNames: [String] = ClassesContainer().daysWeekName(lan: "en")
    @State private var currentInfo: [String] = ["yyyy", "MMMM", "d", "EEE", "E"]
    @State private var dateValues: [DateValue] = []
    
    @State private var selectedDay: Int = 0
    @State private var selectedDayInicial: String = ""
    
    @State private var showModalAdd:Bool = false
    @State private var toggleVisionView:Bool = false
    
    @State private var filteredItems:[Item] = []
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            if(!toggleVisionView) {
                VStack {
                    //Top Bar
                    VStack {
                        ZStack {
                            Text("\(currentInfo[3].capitalized)")
                                .font(.system(size: 30))
                                .bold()
                                .foregroundColor(.white)
                            
                            HStack {
                                //Button Today
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                        selectedDay = Int(currentInfo[2])!
                                        selectedDayInicial = currentInfo[4]
                                        sortingDisplay()
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
                                    showModalAdd = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        toggleVisionView = true
                                    }
                                    
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
                        
                        //Month and Year
                        Text("\(currentInfo[1].capitalized) \(currentInfo[0])")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.bottom, 40)
                    }
                    
                    //Calendar
                    ZStack {
                        Color("ITF seccion")
                        
                        VStack {
                            //WeekNames
                            Capsule()
                                .frame(height: 1, alignment: .center)
                                .foregroundColor(Color("ITF calendar-border"))
                            
                            HStack {
                                ForEach(weekDayNames, id: \.self) { day in
                                    Text(day)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .font(.system(size: 17))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding([.bottom, .top], 4)
                            
                            Capsule()
                                .frame(height: 1, alignment: .center)
                                .foregroundColor(Color("ITF calendar-border"))
                            
                            //Days
                            let columns = Array(repeating: GridItem(.flexible()), count: 7)
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(dateValues) { value in
                                    if(value.day != -1) {
                                        
                                        ZStack {
                                            if(value.day == selectedDay) {
                                                Circle()
                                                    .frame(width: 35, height: 35, alignment: .center)
                                                    .foregroundColor(Color("ITF selection"))
                                            }
                                            
                                            Text("\(value.day)")
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .onTapGesture {
                                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                                    withAnimation(.easeIn(duration: 0.2)) {
                                                        selectedDay = value.day
                                                        selectedDayInicial = value.inicial!
                                                        sortingDisplay()
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 315)
                    
                    //Activities
                    VStack {
                        Text("Your Activities")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: [GridItem(.flexible())]) {
                                ForEach(filteredItems, id: \.self) { currentItem in
                                    HomeVWDisplayActivities(currentItem: currentItem)
                                        .cornerRadius(15)
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
                                        .padding([.leading, .trailing], 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 15)
                }
                .transition(AnyTransition.opacity.animation(.easeInOut))
            }
            
        }
        .sheet(isPresented: $showModalAdd, onDismiss: {
            toggleVisionView = false
            sortingDisplay()
        }, content: {
            HomeVWAddActivity(showModalAddActivity: $showModalAdd, weekDays: weekDayNames, lan: dataTrans.currentLan, currentDayE: currentInfo[4]).environment(\.managedObjectContext, viewContext)
        })
        .onAppear {
            loadInterface()
            sortingDisplay()
           
        }
        
    }
    
    private func sortingDisplay() {
        DispatchQueue.global(qos: .utility).async {
            let currentDate = Date()
            var tmpFilteredItems:[Item] = []
            
            outerloop: for i in 0..<items.count {
                if(currentDate >= items[i].startDate! && currentDate <= items[i].endDate!) {
                    let weekDays = items[i].weeksSelected?.components(separatedBy: ",")
                    
                    for j in 0..<weekDays!.count {
                        if(weekDays![j] == selectedDayInicial) {
                            tmpFilteredItems.append(items[i])
                            continue outerloop
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                filteredItems = tmpFilteredItems
            }
        }
    }
    
    private func deleteItems(idIndex: ObjectIdentifier) {
        for i in 0..<items.count {
            if(idIndex == items[i].id) {
                viewContext.delete(items[i])
                break
            }
        }
        
        for i in 0..<filteredItems.count {
            if(idIndex == filteredItems[i].id) {
                withAnimation(.easeInOut) {
                    _ = filteredItems.remove(at: i)
                }
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
    
    private func loadInterface() {
        //Bar of days
        if(dataTrans.currentLan != "en") {
            weekDayNames = ClassesContainer().daysWeekName(lan: dataTrans.currentLan)
        }
        
        //Get current day info
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: dataTrans.currentLan)
        formatter.dateFormat = "yyyy MMMM d EEEE"

        let date = formatter.string(from: today).capitalized
        
        currentInfo = date.components(separatedBy: " ")
        if(dataTrans.currentLan == "es" && currentInfo[3] == "Miércoles") {
            currentInfo.append("X")
        }
        else {
            currentInfo.append(String(currentInfo[3].first!))
        }
        selectedDay = Int(currentInfo[2])!
        selectedDayInicial = currentInfo[4]
        
        dataTrans.currentInfo = currentInfo
        
        //Get Days
        dateValues = extractDate()
    }
    
    private func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: dataTrans.currentLan)
        formatter.dateFormat = "EE"
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return []
        }
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            var initials = formatter.string(from: date).capitalized
            if(dataTrans.currentLan == "es" && initials == "Mié") {
                initials = "X"
            }
            else {
                initials = String(initials.first!)
            }
            return DateValue(day: day, date: date, inicial: initials)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday-1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

struct HomeVW_Previews: PreviewProvider {
    static var previews: some View {
        HomeVW()
            .environmentObject(CLSDataTrans())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone 12")
    }
}
