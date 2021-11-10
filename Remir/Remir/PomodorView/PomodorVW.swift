//
//  PomodorVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 10/07/21.
//

import SwiftUI

struct PomodorVW: View {
    @State private var day = 8
    @State private var colorTags = ["MDL red", "MDL green", "MDL blue", "MDL orange", "MDL purple", "MDL cyan"]

    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            VStack {
                Text("Hola")
                    .foregroundColor(.white)
                
                let columns = Array(repeating: GridItem(.flexible()), count: colorTags.count)
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(colorTags.indices, id: \.self) { idx in
                        Circle()
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundColor(Color(colorTags[idx]))
                    }
                }
                
            }
            
            
        }
    }
}

struct PomodorVW_Previews: PreviewProvider {
    static var previews: some View {
        PomodorVW()
            .environment(\.locale, .init(identifier: "es"))
            .previewDevice("iPhone 12")
    }
}


