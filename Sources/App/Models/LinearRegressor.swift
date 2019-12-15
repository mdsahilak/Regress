//
//  LinearRegressor.swift
//  App
//
//  Created by Muhammed Sahil on 01/10/19.
//

import Foundation

struct LinearRegressor {
    
    var xArray: [Double]
    var yArray: [Double]
    
    var xMean: Double {
        var sumX: Double = 0
        for x in xArray {
            sumX += x
        }
        let n = Double(xArray.count)
        
        return sumX / n
    }
    
    var yMean: Double {
        var sumY: Double = 0
        for y in yArray {
            sumY += y
        }
        let n = Double(yArray.count)
        
        return sumY / n
    }
    
    var b_XY: Double {
         return sumOf_XDeviations_into_YDeviations / sumOfYDeviationsSquared
    }
    
    var b_YX: Double {
        return sumOf_XDeviations_into_YDeviations / sumOfXDeviationsSquared
    }
    
    
    var regressionEquationOfX_on_Y: String {
        if b_XY < 0 {
            return "X = \((b_XY * -yMean) + xMean) - \(-1 * b_XY)*Y" // To handle double signs in the equation
        } else {
            return "X = \((b_XY * -yMean) + xMean) + \(b_XY)*Y" // Default
        }
    }
    
    var regressionEquationOfY_on_X: String {
        if b_YX < 0 {
            return "Y = \((b_YX * -xMean) + yMean) - \(-1 * b_YX)*X" // To handle double signs in the equation
        } else {
            return "Y = \((b_YX * -xMean) + yMean) + \(b_YX)*X" //Default
        }
    }
    
    var sumOfXDeviationsSquared: Double = 0
    
    var sumOfYDeviationsSquared: Double = 0
    
    var sumOf_XDeviations_into_YDeviations: Double = 0
    
    // <Initializer>
    init(xValues: [Double], yValues: [Double]) {
        self.xArray = xValues
        self.yArray = yValues
        
        //Making the table programmatically and calculating the variables needed in regression equation
        let xDeviations: [Double] = xArray.compactMap { (xVal) -> Double in // x = X -xMean
            return xVal - xMean
        }
        let yDeviations: [Double] = yArray.compactMap { (yVal) -> Double in
            return yVal - yMean
        }
        var xDeviationsSquared: [Double] = xDeviations.compactMap { (xDevVal) -> Double in
            return xDevVal * xDevVal
        }
        var yDeviationsSquared: [Double] = yDeviations.compactMap { (yDevVal) -> Double in
            return yDevVal * yDevVal
        }
        var xDeviations_into_yDeviations: [Double] {
            var index = 0
            var xyArray: [Double] = []
            for _ in 0...xDeviations.count-1{
                let xy = xDeviations[index] * yDeviations[index]
                xyArray.append(xy)
                index += 1
            }
            return xyArray
        }
        //
        sumOfXDeviationsSquared = xDeviationsSquared.reduce(0, { $0 + $1 })
        sumOfYDeviationsSquared = yDeviationsSquared.reduce(0, { $0 + $1 })
        sumOf_XDeviations_into_YDeviations = xDeviations_into_yDeviations.reduce(0, { $0 + $1 })
    }
    // </Initializer>
    
    func predictX(whenY Y: Double) -> Double {
        // Regression Equation of X on Y -> (X - XMean) = b_XY(Y - YMean)
        let ans = b_XY * (Y - yMean) + xMean
        return ans
    }
    
    func predictY(whenX X: Double) -> Double {
        //Regression Equation of Y on X -> (Y - YMean) = b_YX(X - XMean)
        let ans = b_YX * (X - xMean) + yMean
        return ans
    }
    
}

