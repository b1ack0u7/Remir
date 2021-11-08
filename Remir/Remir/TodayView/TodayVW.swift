//
//  TodayVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 25/06/21.
//

import SwiftUI
import CoreData

struct TodayVW: View {
    @EnvironmentObject var dataTrans: CLSDataTrans
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], animation: .default) private var items: FetchedResults <Item>
    
    @State private var currentInfo:[String] = ["yyyy", "MMMM", "d", "EEE", "E"]
    @State private var filteredItems:[Item] = []
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            VStack {
                //Top Bar
                VStack {
                    ZStack {
                        Text("\(currentInfo[3].capitalized)")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Spacer()
                            //Button Add
                            Button(action: {
                                saveChanges()
//                                showModalAdd = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    toggleVisionView = true
//                                }
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
                
                //Content
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())]) {
                        ForEach(filteredItems.indices, id: \.self) {idx in
                            if(filteredItems[idx].tasksCount == 0) {
                                //No Sub-Tasks
                                TodayVWVariant1(currentItem: $filteredItems[idx])
                            }
                            else {
                                //Sub-Tasks
                                TodayVWVariant2(currentItem: $filteredItems[idx])
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            currentInfo = dataTrans.currentInfo
            sortingDisplay()
        }
        .onDisappear {
            saveChanges()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            saveChanges()
        }
    }
    
    private func sortingDisplay() {
        DispatchQueue.global(qos: .utility).async {
            //Get items of current day
            let currentDate = Date()
            var tmpFilteredItems:[Item] = []
            
            for i in 0..<items.count {
                if(currentDate >= items[i].startDate! && currentDate <= items[i].endDate!) {
                    let weekDays = items[i].weeksSelected?.components(separatedBy: ",")
                    
                    for j in 0..<weekDays!.count {
                        if(weekDays![j] == currentInfo[4]) {
                            tmpFilteredItems.append(items[i])
                            break
                        }
                    }
                }
            }
            
            //Sort first to last
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss a"
            tmpFilteredItems.sort(by: {formatter.string(from: $0.startDate!) < formatter.string(from: $1.startDate!)})
            
            //Reset User Activity Completition every day (RUAC)
            let lastLogin = UserDefaults.standard.object(forKey: "lastLogin") as! Date
            let resetDataDays = Calendar.current.dateComponents([.day], from: lastLogin, to: Date()).day! > 0 ? true : false
            
            if(resetDataDays) {
                for i in 0..<filteredItems.count {
                    if(filteredItems[i].tasks?.count != 0) {
                        for j in 0..<filteredItems[i].tasks!.count {
                            filteredItems[i].tasks![j].isCompleted = false
                        }
                    }
                }
                UserDefaults.standard.set(Date(), forKey: "lastLogin")
            }
            //(RUAC)
            
            DispatchQueue.main.async {
                filteredItems = tmpFilteredItems
                if(resetDataDays) {saveChanges()}
            }
        }
    }
    
    private func saveChanges() {
        DispatchQueue.global(qos: .background).async {
            for i in 0..<filteredItems.count {
                for j in 0..<items.count {
                    if(filteredItems[i].id == items[j].id) {
                        items[j].tasks = filteredItems[i].tasks
                    }
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("DBGERR: Unresolved error \(nsError), \(nsError.userInfo)")
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



struct TodayVW_Previews: PreviewProvider {
    static var previews: some View {
        TodayVW()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.locale, .init(identifier: "es"))
            .environmentObject(CLSDataTrans())
    }
}
