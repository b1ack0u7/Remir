//
//  PomodorVW.swift
//  Remir
//
//  Created by Axel Montes de Oca on 10/07/21.
//

import SwiftUI

struct PomodorVW: View {
    var body: some View {
        ZStack {
            Color("ITF background")
                .ignoresSafeArea()
            
            Text("Hola")
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


