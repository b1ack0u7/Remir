//
//  PomodorVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 10/07/21.
//

import SwiftUI

public class Datas: NSObject, NSCoding {
    let data1:String
    let data2:String
    let data3:String
    
    enum Keys:String {
        case data1 = "data1"
        case data2 = "data2"
        case data3 = "data3"
    }
    
    init(data1: String, data2: String, data3: String) {
        self.data1 = data1
        self.data2 = data2
        self.data3 = data3
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(data1, forKey: Keys.data1.rawValue)
        coder.encode(data2, forKey: Keys.data2.rawValue)
        coder.encode(data3, forKey: Keys.data3.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let mdata1 = coder.decodeInt32(forKey: Keys.data1.rawValue)
        let mdata2 = coder.decodeInt32(forKey: Keys.data2.rawValue)
        let mdata3 = coder.decodeInt32(forKey: Keys.data3.rawValue)
        
        self.init(data1: String(mdata1), data2: String(mdata2), data3: String(mdata3))
    }
}

struct PomodorVW: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Myobj.entity(), sortDescriptors: [], animation: .default) private var obj: FetchedResults <Myobj>
    
    @State private var test = ""
    @State private var test2 = ""
    @State private var test3 = ""
    @State private var test4 = ""
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Name: ")
                    TextField("Data1", text: $test)
                }
                
                HStack {
                    Text("Data 2: ")
                    TextField("Data2", text:$test2)
                }
                
                HStack {
                    Text("Data 3: ")
                    TextField("Data3", text:$test3)
                }
                
                HStack {
                    Text("Data 4: ")
                    TextField("Data4", text:$test4)
                }
                
                Button {
                    saveData()
                } label: {
                    Text("Save")
                }
                
                Button {
                    read()
                } label: {
                    Text("Read")
                }
                
                
            }.padding()
        }
    }
    
    private func saveData() {
        let newData = Myobj(context: viewContext)
        newData.name = test
        newData.datarray = Datas(data1: test2, data2: test3, data3: test4)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func read() {
        for i in 0..<obj.count {
            print("DBG: \(String(describing: obj[i].name))")
            
            if(obj[i].datarray != nil) {
                let d1 = obj[i].datarray?.data1
                let d2 = obj[i].datarray?.data2
                let d3 = obj[i].datarray?.data3
                
                print("DBGR: \(String(describing: d1)), \(String(describing: d2)), \(String(describing: d3))")
            }
        }
    }
    
}

struct PomodorVW_Previews: PreviewProvider {
    static var previews: some View {
        PomodorVW()
    }
}
