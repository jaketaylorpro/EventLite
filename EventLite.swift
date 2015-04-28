//
//  EventLite.swift
//  ClockCommander
//
//  Created by Jacob Taylor on 3/16/15.
//  Copyright (c) 2015 jaketaylorpro. All rights reserved.
//

import Foundation
public class EventLite {
    let orderedEventNames:[String]
    public init(orderedEventNames:[String]){
        self.orderedEventNames = orderedEventNames
    }
    //public func assembleObjects<T:EventLiteObject,E:EventLiteEvent where E.T == T, T.T == T>(events:[[E]]) -> [T] {
    public func assembleObjects<T:EventLiteObject where T.T == T>(events:[BareEvent<T>]) -> [T] {
        let allEvents=events.sorted({(e1:BareEvent<T>,e2:BareEvent<T>)->Bool in
            let eventOrder1 = find(self.orderedEventNames,e1.eventName)
            let eventOrder2 = find(self.orderedEventNames,e2.eventName)
            return e1.time.compare(e2.time) != NSComparisonResult.OrderedDescending
                && compareIds(e1.id,e2.id) != NSComparisonResult.OrderedDescending
                && eventOrder1 <= eventOrder2
        })
        var allObjects:[Int:T]=[:]
        var obj:T?
        for e in allEvents { //apply each event in chronological order
            switch e.id {
            case .All:
                for id in allObjects.keys { //apply it to every object that exists up to this point
                    allObjects[id]=e.apply(allObjects[id]!)
                }
            case .Single(let eid): //apply it to the specific object
                if allObjects[eid] == nil {
                    allObjects[eid]=T.create()
                }
                allObjects[eid]=e.apply(allObjects[eid]!)
            }
        }
        return allObjects.values.array
    }
}
public class BareEvent<T:EventLiteObject where T.T == T> {
    let id:EventLiteId
    let time:NSDate
    let eventName:String
    let apply:(T)->T
    public init(id:EventLiteId,time:NSDate,eventName:String,apply:(T)->T) {
        self.id=id
        self.time=time
        self.eventName=eventName
        self.apply=apply
    }
}
public protocol EventLiteEvent {
    //class func eventName() -> String
    typealias T:EventLiteObject
    func asBareEvent() -> BareEvent<T>
    func getId() -> EventLiteId
    func getTime() -> NSDate
}
public protocol EventLiteObject {
    typealias T
    static func create() -> T
}
public class EventLiteObjectHandlers<T,E> {
    internal let handlers:Dictionary<String,(T,E)->T>
    internal let create:()->T
    init(create:()->T,handlers:Dictionary<String,(T,E)->T>) {
        self.create=create
        self.handlers=handlers
    }
}
public func minIndex<T>(list:[T?],isSmaller:(T,T)->Bool) -> Int {
    if list.count == 0 {
        return -1
    }
    var minI = 0
    for i in 1...list.count {
        if let v = list[i] {
            if let minV=list[minI] {
                if isSmaller(v,minV) {
                    minI=i
                }
            }
            else {
                minI=i
            }
        }
    }
    return minI
}
public func any<T>(l:[T],f:(t:T)->Bool) -> Bool {
    for t in l {
        if f(t:t) {
            return true
        }
    }
    return false
}
public enum EventLiteId {
    case All
    case Single(Int)
}
public func compareIds(e1:EventLiteId,e2:EventLiteId) -> NSComparisonResult{
    switch e1 {
    case .All:
        switch e2 {
        case .All:
            return NSComparisonResult.OrderedSame
        default:
            return NSComparisonResult.OrderedAscending
        }
    case .Single(let i1):
        switch e2 {
        case .All:
            return NSComparisonResult.OrderedDescending
        case .Single(let i2):
            if i1 < i2 {
                return NSComparisonResult.OrderedAscending
            }
            else if i1 > i2 {
                return NSComparisonResult.OrderedDescending
            }
            else {
                return NSComparisonResult.OrderedSame
            }
        }
    }
}
