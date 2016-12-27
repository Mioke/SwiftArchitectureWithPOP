//
//  NSDate+Extentsions.swift
//  swiftArchitecture
//
//  Created by Klein Mioke on 5/16/16.
//  Copyright © 2016 KleinMioke. All rights reserved.
//

import Foundation

var dateFormatter: DateFormatter? = nil

extension Date {
    
    var year: Int {
        get {
            return (Calendar.current as NSCalendar).component(NSCalendar.Unit.year, from: self)
        }
    }
    var month: Int {
        get {
            return (Calendar.current as NSCalendar).component(NSCalendar.Unit.month, from: self)
        }
    }
    var day: Int {
        get {
            return (Calendar.current as NSCalendar).component(NSCalendar.Unit.day, from: self)
        }
    }
    
    var weekday: Int {
        get {
            return (Calendar.current as NSCalendar).ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfYear, for: self)
        }
    }
    
    var weekOfMonth: Int {
        get {
            return (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekOfMonth, from: self)
        }
    }
    
    func offsetMonth(_ offset: Int) -> Date {
        guard offset != 0 else { return self }
        var comps = DateComponents()
        comps.month = offset
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: self, options: NSCalendar.Options.wrapComponents)!
    }
    
    func offsetDay(_ offset: Int) -> Date {
        guard offset != 0 else { return self }
        var comps = DateComponents()
        comps.day = offset
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: self, options: NSCalendar.Options.wrapComponents)!
    }
    
    func offsetWeek(_ offset: Int) -> Date {
        guard offset != 0 else { return self }
        var comps = DateComponents()
        comps.weekOfYear = offset
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: self, options: NSCalendar.Options.wrapComponents)!
    }
    
    static func numberOfDaysInMonth(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date).length
    }
    
    var firstWeekdayInMonth: Int {
        get {
            var comps = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month], from: self)
            comps.day = 1
            if let newDate = Calendar.current.date(from: comps) {
                return newDate.weekday
            }
            assert(false, "NSDate.firstWeekdayInMonth error, can't generate the first day in month")
            return 0
        }
    }
    
    func isMonthEqualToDate(_ date: Date) -> Bool {
        let cal = Calendar.current
        let selfComps = (cal as NSCalendar).components([NSCalendar.Unit.year, .month], from: self)
        let other = (cal as NSCalendar).components([.year, .month], from: date)
        
        return selfComps.year == other.year && selfComps.month == other.month
    }
    
    func isDayEqualToDate(_ date: Date) -> Bool {
        let cal = Calendar.current
        let selfComps = (cal as NSCalendar).components([NSCalendar.Unit.year, .month, .day], from: self)
        let other = (cal as NSCalendar).components([.year, .month, .day], from: date)
        
        return selfComps.year == other.year && selfComps.month == other.month && selfComps.day == other.day
    }
    
    func isWeekEqualToDate(_ date: Date) -> Bool {
        let cal = Calendar.current
        let selfComps = (cal as NSCalendar).components([NSCalendar.Unit.year, .weekOfYear, .yearForWeekOfYear], from: self)
        let other = (cal as NSCalendar).components([.year, .month, .yearForWeekOfYear], from: date)
        
        return selfComps.yearForWeekOfYear == other.yearForWeekOfYear && selfComps.weekOfYear == other.weekOfYear
    }
    
    var originTimeOfDay: TimeInterval {
        get {
            let comps = (Calendar.current as NSCalendar).components([.year, .month, .day], from: self)
            return Calendar.current.date(from: comps)!.timeIntervalSince1970
        }
    }
    
    func stringWithFormat(_ format: String) -> String {
        
        if dateFormatter == nil { dateFormatter = DateFormatter() }
        
        let formatter = dateFormatter!
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
