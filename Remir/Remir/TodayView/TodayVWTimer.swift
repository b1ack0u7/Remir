//
//  TodayVWTimer.swift
//  Remir
//
//  Created by Axel Montes de Oca on 22/10/21.
//

import SwiftUI

struct TodayVWTimer: View {
    @Binding var task:STCTasks
    @Binding var showTimer:Bool
    
    private struct STCtimerData {
        var hours:Int
        var minutes:Int
        var seconds:Int
        var combined:Int
        var counter:Int
        var divider:CGFloat
    }
    
    @State private var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timerProgress:CGFloat = 0
    @State private var timerData:STCtimerData = STCtimerData(hours: 0, minutes: 0, seconds: 0, combined: 0, counter: 0, divider: 0)
    
    @State private var buttons:[Bool] = [false, false, false]
    
    
    
    var body: some View {
        ZStack {
            Color("ITF seccion")
                .ignoresSafeArea()
            
            VStack {
                Text("\(task.title)")
                    .foregroundColor(.white)
                    .font(.system(size: 38))
                    .offset(x: 0, y: 60)
                
                Spacer()
                
                ZStack {
                    //Back progress
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Color("MDL icon-bg"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, alignment: .center)
                        .rotationEffect(.init(degrees: 135))
                    
                    //Progress
                    Circle()
                        .trim(from: 0, to: timerProgress)
                        .stroke(AngularGradient(colors: [Color(#colorLiteral(red: 0.16958332061767578, green: 0.4717499017715454, blue: 0.925000011920929, alpha: 1)), Color(#colorLiteral(red: 0.4992806017398834, green: 0.17788195610046387, blue: 0.9083333611488342, alpha: 1))], center: .center, startAngle: .init(degrees: 90), endAngle: .init(degrees: 200)), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, alignment: .center)
                        .rotationEffect(.init(degrees: 135))
                    
                    HStack {
                        Text("\(timerData.hours)")
                        Text(":")
                            .padding(.bottom, 5)
                        Text("\(timerData.minutes)")
                        Text(":")
                            .padding(.bottom, 5)
                        Text("\(timerData.seconds)")
                    }
                    .frame(width: 200, height: 50, alignment: .center)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    
                    Text("+30s")
                        .font(.system(size: 22))
                        .bold()
                        .foregroundColor(Color("MDL cyan"))
                        .offset(x: 0, y: 150)
                }
                
                
                
                Spacer()
                
                HStack {
                    Image("Play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .foregroundColor(buttons[0] ? Color("MDL cyan") : .black)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                buttons[0] = true
                                buttons[1] = false
                                buttons[2] = false
                            }
                        }
                    
                    Spacer()
                    
                    Image("Pause")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .foregroundColor(buttons[1] ? Color("MDL cyan") : .black)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                buttons[0] = false
                                buttons[1] = true
                                buttons[2] = false
                            }
                        }
                    
                    Spacer()
                    
                    Image("Stop")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45)
                        .foregroundColor(buttons[2] ? Color("MDL cyan") : .black)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                buttons[0] = false
                                buttons[1] = false
                                buttons[2] = true
                                
                                showTimer.toggle()
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                        }
                }
                .padding([.leading, .trailing], 60)
                .offset(x: 0, y: -60)
                
            }
        }
        .onAppear {
            timerData.hours = task.hours
            timerData.minutes = task.minutes
            
            timerData.combined = ((task.hours*60)*60) + (task.minutes*60)
            timerData.divider = CGFloat(timerData.combined)/0.75
            
        }
        
        .onReceive(self.time) { (_) in
            if(self.buttons[0]) {
                if(self.timerData.counter != self.timerData.combined) {
                    if(self.timerData.hours != 0 && self.timerData.minutes == 0) {
                        self.timerData.hours -= 1
                        self.timerData.minutes = 60
                    }
                    if(self.timerData.minutes != 0 && self.timerData.seconds == 0) {
                        self.timerData.minutes -= 1
                        self.timerData.seconds = 60
                    }
                    
                    self.timerData.counter += 1
                    
                    self.timerData.seconds -= 1
                    
                    withAnimation(.default) {
                        self.timerProgress = CGFloat(self.timerData.counter) / self.timerData.divider
                    }
                    
                }
                else {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    scheduleNotification()
                    showTimer.toggle()
                }
            }
        }
    }
    
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.subtitle = "Completado"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct TodayVWTimer_Previews: PreviewProvider {
    static var previews: some View {
        TodayVWTimer(task: .constant(STCTasks(title: "Sacar al perro", status: true, timer: true, hours: 1, minutes: 0)), showTimer: .constant(true))
    }
}
