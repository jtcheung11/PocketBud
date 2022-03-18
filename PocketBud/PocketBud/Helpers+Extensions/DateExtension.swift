//
//  DateExtension.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/10/22.
//

import Foundation

    extension Date {
        func stringValue () -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.string(from:self)
        }
        
        func dateAsMonth() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            
            return formatter.string(from: self)
        }
        
        func monthDayYear () -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from:self)
        }
    }
