# NetworkLibrary


Gives a better networking object for SwiftUI. This library is intended to help with Rest API networking by providing a wrapper object on top of Swift's native URLSession API.

**Note: This is the first release and some features are still in development**  

## Features:

- Intuitive API

- Compatible with SwiftUI or UIKit

- Easy integration using SPM

- Automatic conversions between any Codable objects and JSON Data

- Built in Error Handling

  

## Installation:

1. Open XCode Project

2. Go to File -> Add Packages...

3. Use this download URL: `https://github.com/colbyb2/BetterNetwork.git`

## Usage:

Getting started with the library is extremely simple.

First import the library to your file using `import NetworkLibrary`.

Then, you have to create a Network object. The network object does all the work for you, all you have to do is pass the constructor the API's base url. The base url is your API's url without any routes. This is done to make routing extremely simple.

```
import NetworkLibrary

class ViewController {
    let network: Network = Network(baseURL: [YOUR_API_URL])
}
```

Once you have your network instance, it is easy to make any requests.

**Note: All requests are asynchronous and must be handled as such. More on this below.**

Since each request does not happen immediately, it is import to handle them using concurrency. For this, I recommend making all requests from within a Task.

```
class ViewController {
    let network: network = Network(baseURL: [YOUR-API-URL])
    
    func makeRequest() async {
        Task {
            //Make request and do work
        }
    }
}
```

I also recommend using completion handlers, however this is optional.

```
class ViewController {
    let network: network = Network(baseURL: [YOUR-API-URL])
    
    func makeRequest(completion: @escaping () -> Void) async {
        Task {
            //Make request and do work
            completion() //This will serve as an async return statement
        }
    }
}
```

### Get Request:
The Network.Get function is used to conduct an HTTP GET Request.

The Get function takes 3 parameters and two optional parameters.

1. as: This will be your custom object that represents the data structure returned from the API. It must conform to the native Codable protocol.
2. urlExtension: This string will be appended onto the baseURL to create the final API route.
    Example: baseUrl="https://fakeapi.io/" and extension="users/[UID]" gives us "https://fakeapi.io/users/[UID]"
3. token: (Optional) This param contains an AuthToken to be passed. If no authentication is required, you can ignore this. **Note: Due to iOS configurations, authTokens cannot be passed directly through the Authentication header. Because of this, authTokens are passed in a custom header called "token". If you are an admin of the server, be sure to retrieve the token through that header.**
4. params: (Optional) These are optional query parameters.
5. completion: This function will be called on completion of the request. It will be passed the decoded data retrieved by the request.

Example:

Here is our response object. It represents the data we are expecting from the API.
```
struct APIResponse: Codable {
    let status: Bool
    let message: String
}
```

The equivalent JSON Data would look like:
```
{
    "status": true,
    "message: "Successful Request"
}
```
Now we can make a GET Request to the baseURL (no extension).

```
class ViewController {
    let network: network = Network(baseURL: [YOUR-API-URL])
    
    func makeRequest(completion: @escaping (_:Bool) -> Void) async {
        Task {
            await self.network.Get(as: APIResponse.self, urlExtension: "") {response in 
                if (response == nil) {
                    completion(false)
                } else {
                    //Use data from response
                    completion(true)
                }
            }
        }
    }
}
```
Notice that the completion parameter is written as a closure and passed the decoded response.

### POST Request
The Post function also takes 3 params and an optional token param as well as an optional list of query parameters.
1. urlExtension: Same as GET
2. bodyPayload: This will be an instance of the data that you want to send to the API. It has to be conform to Codable.
3. token: (Optional) Same as GET
4. params: (Optional) Query Parameters
4. completion: Same as GET but passes a boolean status instead of response data.

Example:
```
class ViewController {
    let network: network = Network(baseURL: [YOUR-API-URL])
    
    func makeRequest(payload: [SOME_CODABLE], completion: @escaping (_:Bool) -> Void) async {
        Task {
            await self.network.Post(urlExtension: "newData", bodyPayload: payload, token: [AUTH_TOKEN])
            {status in 
                completion(status)
            }
        }
    }
}
```
Here is an example of the POST Request. Notice how we are using a urlExtension in this case. The computed path for the API call would be "baseURL/newData". Also notice how we simply passed the authToken here to the token parameter.

### Delete Request

The Delete request is similar to the others except that it takes a unique parameter called "params".

1. urlExtension: Same as Get and Post
2. token: (Optional) Same as Get and Post
3. params: This takes an array of URLParam objects (See later section on URLParam object). These will be converted into a url query. **The use of URLParams are necessary for a Delete request because there is no request body to pass deletion data through.**
4. completion: Same as Post

Example:
```
class ViewController {
    let network: network = Network(baseURL: [YOUR-API-URL])
    
    func makeRequest(completion: @escaping (_:Bool) -> Void) async {
        let params = [URLParam(name: "id", value: "ID_VALUE"]
        Task {
            await self.network.Delete(urlExtension: "data", token: [AUTH_TOKEN], params: params)
            {status in 
                completion(status)
            }
        }
    }
}
```
The full generated URL would be "baseUrl/data?id=[ID_VALUE]". Your API/Server can retrieve these params through the url query parameters on server side.

### URLParam
The URLParam object is used to easily pass query parameters to your API Call.

URLParam can take any key value pair and translate it into a query string to be appended to your URL.
Examples:
`let param: URLParam = URLParam(name: "uid", value: "3FB9CE5E")`
This would be come the query extension of "?uid=3FB9CE5E".

We can also do multiple params:
`let param2: URLParam(name: "age", value: 21)`
Then if we pass `[param, param2]` into the function, it will generate the query extension of
"?uid=3FB9CE5E&age=21".

### Patch Request

**COMING SOON...**

