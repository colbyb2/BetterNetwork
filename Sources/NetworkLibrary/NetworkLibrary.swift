//
//  Network.swift
//  Remmy
//
//  Created by Colby Brown on 1/3/23.
//

import Foundation

@available(iOS 13.0.0, *)
@available(macOS 10.15.0, *)
public class Network {
    var baseURL: String
    
    ///Creates a Network object using baseURL: API url without any routes
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    /**
    - Description: HTTP GET Request
    - Parameters:
     - as: Type to read JSON as, must conform to Codable
     - urlExtension: API Route extension
     - token: (Optional) Authentication Token
     - params: (Optional) Query Paramters
     - completion: Closure triggered on completion, passes decoded JSON object into result
     */
    public func Get<T: Codable>(as: T.Type, urlExtension: String, token:String = "", params: [URLParam] = [], completion: @escaping (_ data: T?) -> Void) async {
        let urlString = baseURL + urlExtension + generateQueryExtension(params)
        
        let url = URL(string: urlString)!;
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }

            let response: T? = self.parseFrom(json: data)
            completion(response)
        }).resume()
    }
    
    /**
    - Description: HTTP POST Request
    - Parameters:
     - urlExtension: API Route extension
     - bodyPayload: Codable Object that will be sent as JSON to API
     - token: (Optional) Authentication Token
     - params: (Optional) Query Paramters
     - completion: Closure triggered on completion, passes a boolean completion status
     */
    public func Post<T: Codable>(urlExtension: String, bodyPayload: T, token: String, params: [URLParam] = [], completion: @escaping (_ status:Bool) -> Void) async {
        let urlString = baseURL + urlExtension + generateQueryExtension(params)
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        let bodyData = parseTo(data: bodyPayload)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        request.addValue(token, forHTTPHeaderField: "token")
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            if let error = error {
                print(error)
                completion(false)
            } else if data != nil {
                completion(true)
            }
        }).resume()
    }
    
    /**
    - Description: HTTP DELETE Request
    - Parameters:
     - urlExtension: API Route extension
     - token: (Optional) Authentication Token
     - params: (Optional) Query Paramters
     - completion: Closure triggered on completion, passes a boolean completion status
     */
    public func Delete(urlExtension: String, token: String, params: [URLParam], completion: @escaping (_ status:Bool) -> Void) async {
        let urlString = baseURL + urlExtension + generateQueryExtension(params)

        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.addValue(token, forHTTPHeaderField: "token")
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            if error != nil {
                completion(false)
            } else if data != nil {
                completion(true)
            }
        }).resume()
    }
    
    /**
    - Description: Parses JSON data to a codable object
    - Parameters:
     - json: JSON Data
    - Returns: Codable Object
     */
    func parseFrom<T: Codable>(json: Data) -> T? {
        let decoder = JSONDecoder()
        
        let data = try? decoder.decode(T.self, from: json)
        return data
    }
    
    /**
    - Description: Parses from a Codable object to JSON Data
    - Parameters:
     - data: Codable Object
    - Returns: JSON Data
     */
    func parseTo<T: Codable>(data: T) -> Data? {
        let encoder = JSONEncoder()
        
        let json = try? encoder.encode(data)
        return json
    }
    
    /**
    - Description: Converts a series of URL Parameters to a url query string
    - Parameters:
     - params: List of URLParam objects
    - Returns: URL Query String
     */
    func generateQueryExtension(_ params: [URLParam]) -> String {
        var queryString:String = "?"
        
        for (index, param) in params.enumerated() {
            if (index != 0) { queryString.append("&") }
            queryString.append("\(param.name)=\(param.value)")
        }
        
        return queryString
    }
}

public struct URLParam {
    let name:String
    let value:Any
    
    public init(name: String, value: Any) {
        self.name = name
        self.value = value
    }
}

