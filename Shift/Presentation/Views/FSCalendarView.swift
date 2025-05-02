//
//  FSCalendarView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import FSCalendar
import SwiftUI

struct FSCalendarView: UIViewRepresentable {

    
    func makeUIView(context: Context) -> some UIView {
        let fsCalendar = FSCalendar()
        fsCalendar.scrollDirection = .vertical
        
        
        let preferredLanguage = Locale.preferredLanguages.first ?? "ja"
        let locale = Locale(identifier: preferredLanguage)
        fsCalendar.locale = locale
        
        return fsCalendar
    }
    
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
