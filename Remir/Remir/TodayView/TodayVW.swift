//
//  TodayVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 25/06/21.
//

import SwiftUI

struct STCTasks: Hashable {
    var title:String
    var status:Bool
    var timer:Bool
    var hours:Int
    var minutes:Int
}

struct TodayVW: View {
    @EnvironmentObject var dataTrans: CLSDataTrans
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Item.timeSort, ascending: true)],
          animation: .default) private var items: FetchedResults <Item>
    
    
    @State private var currentInfo:[String] = ["dayNumber","Month","Year","EEEE","EEE"]
    @State private var currentItems:[Item] = []
    
    @State private var dayWTHNamesSelected:String = ""
    
    @State private var tasks:[[STCTasks]] = []
    
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            //Top Bar
            VStack {
                VStack {
                    ZStack {
                        Text("\(currentInfo[3].capitalized)")
                            .font(.system(size: 40))
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                    Text("\(currentInfo[1].capitalized) \(currentInfo[2])")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .padding(.top, 1)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())]) {
                        ForEach(tasks.indices, id: \.self) {index in
                            if(tasks[index].isEmpty) {
                                TodayVWVariant1(currentItem: $currentItems[index])
                            }
                            else {
                                TodayVWVariant2(tasks: $tasks[index], currentItem: $currentItems[index])
                            }
                            
                        }
                    }
                }
            }
        }
        .onAppear {
            currentInfo = dataTrans.currentInfo
            sortingDisplay()
            proccessTasks()
        }
        .onDisappear {
            saveChanges()
        }
    }
    
    
    private func saveChanges() {
        /*
        var tmpTasks:[String] = []
        
        for i in 0..<tasks.count {
            if(tasks[i].isEmpty) {
                tmpTasks.append("")
            }
            else {
                let tmpARR = tasks[i].map {return ("\($0.title),\($0.status),\($0.timer),\($0.hours),\($0.minutes)")}
                tmpTasks.append(tmpARR.joined(separator: "|"))
            }
        }
        
        for i in 0..<currentItem.count {
            for j in 0..<items.count {
                if(currentItem[i].id == items[j].id) {
                    items[j].tasks = tmpTasks[i]
                }
            }
           
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
         */
    }
    
    private func sortingDisplay() {
        /*
        let currentDate = Date()
        var tmpFilteredItems:[Item] = []
        
        outerloop: for i in 0..<items.count {
            if(currentDate >= items[i].startDate! && currentDate <= items[i].endDate!) {
                let weekDays = items[i].weeksSelected?.components(separatedBy: ",")
                
                for j in 0..<weekDays!.count {
                    if(weekDays![j] == dayWTHNameSelected) {
                        currentItems.append(items[i])
                        continue outerloop
                    }
                }
            }
        }
         */
    }
    
    private func proccessTasks() {
        /*
        var tmpTasks:[[STCTasks]] = []
        
        for i in 0..<currentItem.count {
            if(currentItem[i].tasksCount > 1) {
                let tmpArray = currentItem[i].tasks!.components(separatedBy: "|")
                
                let subTmpArray = tmpArray.map { result in
                    return result.components(separatedBy: ",")
                }
                
                let finalArray = subTmpArray.map { res in
                    return STCTasks(title: res[0], status: Bool(res[1])!, timer: Bool(res[2])!, hours: Int(res[3])!, minutes: Int(res[4])!)
                }
                
                tmpTasks.append(finalArray)
            }
            else if(currentItem[i].tasksCount == 1) {
                let res = currentItem[i].tasks?.components(separatedBy: ",")
                tmpTasks.append([STCTasks(title: res![0], status: Bool(res![1])!, timer: Bool(res![2])!, hours: Int(res![3])!, minutes: Int(res![4])!)])
            }
            else {
                tmpTasks.append([])
            }
        }
        
        tasks = tmpTasks
         */
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
