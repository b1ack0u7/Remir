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
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], animation: .default) private var items: FetchedResults <Item>
    
    @State private var currentInfo:[String] = ["yyyy", "MMMM", "d", "EEE", "E"]
    @State private var filteredItems:[Item] = []
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            //Top Bar
            VStack {
                VStack {
                    ZStack {
                        Text("\(currentInfo[3].capitalized)")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                    Text("\(currentInfo[1].capitalized) \(currentInfo[0])")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .padding(.top, 1)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())]) {
                        ForEach(filteredItems.indices, id: \.self) {idx in
                            if(filteredItems[idx].tasksCount == 0) {
                                TodayVWVariant1(currentItem: $filteredItems[idx])
                            }
                            else {
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
    }
    
    private func sortingDisplay() {
        DispatchQueue.global(qos: .utility).async {
            let currentDate = Date()
            var tmpFilteredItems:[Item] = []
            
            outerloop: for i in 0..<items.count {
                if(currentDate >= items[i].startDate! && currentDate <= items[i].endDate!) {
                    let weekDays = items[i].weeksSelected?.components(separatedBy: ",")
                    
                    for j in 0..<weekDays!.count {
                        if(weekDays![j] == currentInfo[4]) {
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
    
    
    private func saveChanges() {
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
