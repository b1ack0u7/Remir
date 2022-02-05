//
//  SettingsVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 10/07/21.
//

import SwiftUI

struct SettingsVW: View {
    @EnvironmentObject var dataTrans: CLSDataTrans
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], animation: .default) private var items: FetchedResults <Item>
    
    private var time:[Int] = [5,15,30]
    @State private var showAlert:Bool = false
    
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            VStack {
                Text("Ajustes")
                    .font(.system(size: 30))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                
                VStack {
                    Text("Ajustar Tiempo (Temporizador)")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    Picker("Ajuste del tiempo (Temporizador)", selection: $dataTrans.timerData) {
                        ForEach(time, id:\.self) { dat in
                            Text("\(dat)")
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding([.leading, .trailing], 10)
                
                Spacer()
                
                Button(action: {
                    showAlert.toggle()
                }, label: {
                    Text("Borrar datos")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                })
                    .padding(.bottom, 40)
            }
            
        }
        .alert("¿Desea borrar sus datos?", isPresented: $showAlert) {
            Button("Si", role: .destructive) {}
            Button("No", role: .cancel) {}
        }
    }
    
    private func deleteData() {
        for data in items {
            viewContext.delete(data)
        }
        do {
            try viewContext.save()
        } catch let error as NSError{
            print("DBG: CoreData error: ",error.localizedDescription)
        }
    }
}

struct SettingsVW_Previews: PreviewProvider {
    static var previews: some View {
        SettingsVW()
            .previewDevice("iPhone 12")
            .environmentObject(CLSDataTrans())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
