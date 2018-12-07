//
//  Arbitrary.swift
//  WritingHelper
//
//  Created by Jason Howlin on 1/22/16.
//  Copyright © 2016 Aol. All rights reserved.
//

import Foundation

protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    public static func arbitrary() -> Int {
        return Int.random(in: 0...Int.max)
    }
}

extension Bool: Arbitrary {
    public static func arbitrary() -> Bool {
        return Bool.random()
    }
}

extension Character: Arbitrary {
    public static func arbitrary() -> Character {
        let letter = random(from: 97, to: 122)
        let char = Character(UnicodeScalar(letter)!)
        return char
    }
}

extension String: Arbitrary {
    public static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 8)
        let randomChar = tabulate(times: randomLength) {
            num in
            Character.arbitrary()
        }
        return randomChar.reduce("") {$0 + String($1)}
    }
    
    
    public static func arbitraryWords(_ words:Int) -> String {
        
        var result = ""
        for _ in 0...words {
            result += String.arbitrary() + " "
        }
        return result
    }
}

public func random(from:Int, to:Int) -> Int {
    return Int.random(in: from...to)
}

public func tabulate<A>(times:Int, f:(Int)->A) -> [A] {
    return Array(0..<times).map(f)
}
