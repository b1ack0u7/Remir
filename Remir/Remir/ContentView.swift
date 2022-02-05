//
//  ContentView.swift
//  Remir
//
//  Created by Axel Montes de Oca on 25/06/21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var dataTrans = CLSDataTrans()
    @State private var tabIcons:[String] = ["Menu-Today","Menu-Activity","Menu-Settings"]
    @State private var tabIndex:Int = 1
    
    
    var body: some View {
        VStack(spacing: 0) {
            switch tabIndex {
            case 0:
                TodayVW()
            case 1:
                HomeVW()
            case 2:
                SettingsVW()
            default:
                Text("")
            }

            ZStack {
                Color("ITF background")
                Rectangle()
                    .foregroundColor(Color("ITF seccion"))
                    .cornerRadius(25)
                    .shadow(radius: 6)
                    .edgesIgnoringSafeArea(.bottom)
                
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 14) {
                    ForEach(0..<tabIcons.count, id: \.self) { i in
                        Spacer()
                        ZStack {
                            //Selected Option
                            if(i == tabIndex) {
                                Circle()
                                    .foregroundColor(Color("ITF selection"))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                            }
                            
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                tabIndex = i
                            }, label: {
                                Image("\(tabIcons[i])")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25)
                                    .foregroundColor(i == tabIndex ? Color.white : Color("ITF icons-menu"))
                            })
                        }
                        .frame(width: 60, alignment: .center)
                        Spacer()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
        }
        .environmentObject(dataTrans)
        .onAppear {
//            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UIApplication.shared.applicationIconBadgeNumber = 0
            checkLanguage()
            setDateOfLastLoggin()
            checkPermisions()
        }
    }
    
    private func checkLanguage() {
        let currentLan = UserDefaults.standard.string(forKey: "lan")
        
        if(currentLan == nil) {
            if(NSLocale.current.languageCode == "es") {
                UserDefaults.standard.set("es", forKey: "lan")
                dataTrans.currentLan = "es"
            }
            else {
                UserDefaults.standard.set("en", forKey: "lan")
                dataTrans.currentLan = "en"
            }
        }
        else {
            dataTrans.currentLan = currentLan!
        }
    }
    
    private func setDateOfLastLoggin() {
        if(UserDefaults.standard.object(forKey: "lastLogin") as? Date == nil) {
            UserDefaults.standard.set(Date(), forKey: "lastLogin")
        }
        
        if(UserDefaults.standard.object(forKey: "timerData") as? Int == nil) {
            UserDefaults.standard.set(15, forKey: "timerData")
        }
    }
    
    private func checkPermisions() {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { settings in
          switch settings.authorizationStatus {
          case .authorized, .provisional:
              print("DBG authorized")
              
          case .denied:
              print("DBG denied")
              askPermisions()
              
          case .notDetermined:
              print("DBG not determined, ask user for permission now")
              askPermisions()
              
          case .ephemeral:
                ()
          @unknown default:
                ()
          }
        })
    }
    
    private func askPermisions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, .init(identifier: "es"))
            .previewDevice("iPhone 12")
            
    }
}
