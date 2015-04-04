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
            return e1.id <= e2.id
                && e1.time.compare(e2.time) != NSComparisonResult.OrderedDescending
                && eventOrder1 <= eventOrder2
        })
        var allObjects:[T]=[]
        var obj:T?
        var id = -1
        for e in allEvents {
            if id != e.id {
                //add the finished object
                if obj != nil { //avoid first run case
                    allObjects.append(obj!)
                }
                //create a new object
                obj=T.create()
            }
            //keep applying events to the current object
            obj=e.apply(obj!)
            id=e.id
        }
        if obj != nil {
            //append the final object
            allObjects.append(obj!)
        }
        return allObjects
            
            
            
        
        /*smart merge union
        var indexes:[(Int,Int)]=events.map({(l:[E])->(Int,Int) in return (0,l.count)})
        while any(indexes,{(v:(Int,Int))->Bool in let (index,length) = v; return index+1 < length} {
            var minValues:[E?]=[]
            for i in 0...indexes.count {
                let (index,length) = indexes[i]
                if index+1 < length {
                    minValues.append(events[i][indexes[i].0])
                }
                else {
                    minValues.append(nil)
                }
            }
            var ii=minIndex(minValues,{(e1:E,e2:E)->Bool in
                return e1.id() <= e2.id() && e1.time().compare(e2.time()) != NSComparisonResult.OrderedDescending})
            let event:E = events[ii][indexes[ii].0]
            indexes[ii].0 += 1
            let h = handlers.handlers[event.eventName()]!
            var t=handlers.create()
            return events.reduce(t, combine: {(t:T,e:E)->T in
        
            })

        }
        */
    }
}
public class BareEvent<T:EventLiteObject where T.T == T> {
    let id:Int
    let time:NSDate
    let eventName:String
    let apply:(T)->T
    public init(id:Int,time:NSDate,eventName:String,apply:(T)->T) {
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
    func getId() -> Int
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
