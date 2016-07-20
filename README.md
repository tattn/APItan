# APItan: あぴたん(๑❛ᴗ❛๑)

Lightweight & Kawaii API client in Swift

## Installation

### Carthage

```
github "tattn/APItan"
```

### CocoaPods

not yet...

## Examples

```swift
struct GetRequest: RequestType {
    let method = HTTPMethod.Get
    let path = "https://***.com"
    var parameters: [String: AnyObject] {
        return [
          "user_id": 1,
          "offset": 0,
          "limit": 10,
        ]
    }
}

let request = GetRequest()
APItan.send(request: request) { result in
    switch result {
    case .Success(let json):
        print(json)
    case .Failure(let error):
        print(error)
    }
}
```

### Parallel
```swift
APItan.send(requests: [request1, request2, request3]) { results in
    // all done
    results.forEach { result in
        switch result {
        case .Success(let json):
            print(json)
        case .Failure(let error):
            print(error)
        }
    }
}
```

### Series
```swift
APItan.send(requests: [request1, request2, request3], isSeries: true) { results in
    // all done
    results.forEach { result in
        switch result {
        case .Success(let json):
            print(json)
        case .Failure(let error):
            print(error)
        }
    }
}
```

### Like a promise

```swift
APItan.send(request: request1).next { json -> RequestType? in
    print(json)
    return request2
}.next { json -> RequestType? in
    print(json)
    return request3
    // return nil // finish & go to always
}.next { json -> Void in
    print(json)
}.always {
}.fail { error in
    print(error)
}
```

### HTTP Header

```swift
struct GetRequest: RequestType {
    let method = HTTPMethod.Get
    let path = "https://***.com"
    let headers: [String: String] = [
	    "X-Application-Key": "********************",
	]
}
```

### Mock

```swift
struct GetRequest: RequestType {
    let method = HTTPMethod.Get
    let path = "https://***.com"

    let mockData: AnyObject? = [
        ["id": 1],
        ["id": 2]
    ]

    let mockWaitTime = 1000 // wait for 1000[ms]
}

let request = GetRequest()
APItan.send(request: request) { result in
    switch result {
    case .Success(let json):
        print(json)
    case .Failure(let error):
        print(error)
    }
}
```

### Cancellation

```swift
let request = GetRequest()
APItan.send(request: request) { _ in }
APItan.cancel(request: request) // cancel requests of the http method and the path
```

## Usage With ObjectMapper

```swift
APItan.send(requests: [request1, request2]) { results in
	let values = results.values

	let response1 = Mapper<Request1>().map(values[0])
	let response2 = Mapper<Request2>().map(values[1])
}
```


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

APItan is released under the MIT license. See LICENSE for details.
