//
//  File.swift
//  
//
//  Created by Anton Marini on 4/4/24.
//

import TimecodeKit

extension Fraction
{
    static public func normalizeFraction(numerator: Int, denominator: Int, targetDenominator: Int) -> (Int, Int) {
        let gcd = greatestCommonDivisor(denominator, targetDenominator)
        let multiplier = targetDenominator / gcd
        
        let newNumerator = (numerator * multiplier) / (denominator / gcd)
        let newDenominator = targetDenominator
        
        return (newNumerator, newDenominator)
    }

    public func normalizeTo(targetDenominator:Int) -> Fraction
    {
        let (num, den) = Fraction.normalizeFraction(numerator: self.numerator, denominator: self.denominator, targetDenominator: targetDenominator)
        
        return Fraction(num, den)
    }   
}

// Lame - duplicated from private func in fraction
private func greatestCommonDivisor(_ n1: Int, _ n2: Int) -> Int {
    var x = 0
    var y = max(n1, n2)
    var z = min(n1, n2)
    
    while z != 0 {
        x = y
        y = z
        z = x % y
    }
    
    return y
}
