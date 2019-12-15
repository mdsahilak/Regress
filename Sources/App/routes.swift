import Vapor
import Routing

// Hold the trained regressor model
var regressor: LinearRegressor? = nil
var error_text: String = "Model Training not yet initiated"


// MARK: Register your application's routes here.
public func routes(_ router: Router) throws {
    // "It works" page
    router.get("/welcome") { req in
        return try req.view().render("welcome")
    }
    
    // Says hello
    router.get("hello", String.parameter) { req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
        ])
    }
    
    router.get { req -> Future<View> in
        return try req.view().render("index")
    }
    
    router.get("/prediction") { req -> Future<View> in
        let regressorDescription = String(describing: regressor)
        let constants = "b_XY = \(String(describing: regressor?.b_XY)) and b_YX = \(String(describing: regressor?.b_YX))"
        let formulas = "\(String(describing: regressor?.regressionEquationOfX_on_Y)) and \(String(describing: regressor?.regressionEquationOfY_on_X))"
        let trainingRun = (regressor != nil ? "success" : "failure")
        let errorVal = "\(error_text)"
        
        let context: [String: String] = ["regressor": regressorDescription, "constants": constants, "formulas": formulas, "trainingRun": trainingRun, "error": errorVal]
        
        return try req.view().render("prediction", context)
    }
    
    router.get("/prediction/x", Double.parameter) { req -> String in
        guard let xValue: Double = try? req.parameters.next() else {return "invalid input"}
        guard let regressor = regressor else {return "Please Train the model first"}
        
        let ans = regressor.predictY(whenX: xValue)
        return "When x = \(xValue), y = \(ans)"
    }
    
    router.get("/prediction/y", Double.parameter) { req -> String in
        guard let yValue: Double = try? req.parameters.next() else {return "invalid input"}
        guard let regressor = regressor else {return "Please train the model first!"}
        
        let ans = regressor.predictX(whenY: yValue)
        return "When y = \(yValue), x = \(ans)"
    }
    
    router.post("/inputdata") { req -> Response in
        regressor = nil
        error_text = "Model Training not yet initiated"
        
        guard let data = req.http.body.data else {
            error_text = "Could not recieve the http data body, showing nil value"
            return req.redirect(to: "/prediction")
        }
        let inputStrings = try JSONDecoder().decode(DataStrings.self, from: data)
//        print(inputStrings)
        
        let xValues: String = inputStrings.xColumn
        let yValues: String = inputStrings.yColumn
        
        let valuesX = xValues.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet(charactersIn: ",")).components(separatedBy: ",")
        let valuesY = yValues.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet(charactersIn: ",")).components(separatedBy: ",")
        
//        print(valuesX)
//        print(valuesY)
        
        guard valuesX.count == valuesY.count else {
            error_text = "x and y have unequal number of input values"
            return req.redirect(to: "/prediction")
            
        }
        
        var doublesX: [Double] = []
        var doublesY: [Double] = []
        
        for val in valuesX {
            guard let double = Double(val) else {
                error_text = "Non-Integer/Non-Decimal values found in input data"
                return req.redirect(to: "/prediction")
            }
            doublesX.append(double)
        }
        
        for val in valuesY {
            guard let double = Double(val) else {
                error_text = "Non-Integer/Non-Decimal values found in input data"
                return req.redirect(to: "/prediction")
            }
            doublesY.append(double)
        }
        
        regressor = LinearRegressor(xValues: doublesX, yValues: doublesY)
        error_text = "No detectable errors found"
        
        print(regressor)
        
        return req.redirect(to: "/prediction")
    }
    
    
    router.get("/retrain") { req -> Response in
        regressor = nil
        return req.redirect(to: "/")
    }
    
    
    
    // MARK: Not used anymore - (For Reference)
    // Using get and getting data through the request url
    
    router.get("/inputdata", String.parameter, String.parameter) { req -> Response in
        regressor = nil
        error_text = "Model Training not yet initiated"
        
        let xValues: String = try req.parameters.next()
        let yValues: String = try req.parameters.next()
        
        let valuesX = xValues.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet(charactersIn: ",")).components(separatedBy: ",")
        let valuesY = yValues.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet(charactersIn: ",")).components(separatedBy: ",")
        
        print(valuesX)
        print(valuesY)
        
        guard valuesX.count == valuesY.count else {
            error_text = "x and y have unequal number of input values"
            return req.redirect(to: "/prediction")
            
        }
        
        var doublesX: [Double] = []
        var doublesY: [Double] = []
        
        for val in valuesX {
            guard let double = Double(val) else {
                error_text = "Non-Integer/Non-Decimal values found in input data"
                return req.redirect(to: "/prediction")
            }
            doublesX.append(double)
        }
        
        for val in valuesY {
            guard let double = Double(val) else {
                error_text = "Non-Integer/Non-Decimal values found in input data"
                return req.redirect(to: "/prediction")
            }
            doublesY.append(double)
        }
        
        regressor = LinearRegressor(xValues: doublesX, yValues: doublesY)
        error_text = "No detectable errors found"
        
        print(regressor)
        
        return req.redirect(to: "/prediction")
    }
    
    
}
