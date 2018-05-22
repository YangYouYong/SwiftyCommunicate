//
//  BMWRxMoyaAPI.swift
//  NetworkLayer
//
//  Created by yangyouyong on 2018/5/22.
//  Copyright © 2018年 cpbee. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire
import Reachability


open class BMWRxProvider<Target> where Target: TargetType {
    
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false,
         online: Observable<Bool> = connectedToInternetOrStubbing()) {
        
        self.online = online
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    func request(_ token: Target) -> Observable<Moya.Response> {
        let actualRequest = provider.rx.request(token)
        return online
            .ignore(value: false)  // Wait until we're online
            .take(1)        // Take 1 to make sure we only invoke the API once.
            .flatMap { _ in // Turn the online state into a network request
                return actualRequest
        }
    }
    
    open static func baseProvider() -> BMWRxProvider<Target> {
        let provider = BMWRxProvider<Target>(endpointClosure: Networking.endpointsClosure(),
                                             requestClosure: Networking.endpointResolver(),
                                             stubClosure: Networking.APIKeysBasedStubBehaviour,
                                             manager:MoyaProvider<Target>.defaultAlamofireManager(),
                                             plugins: Networking.plugins,
                                             trackInflights:false,
                                             online: connectedToInternetOrStubbing())
        return provider
    }
    
}

protocol NetworkingType {
    associatedtype T: TargetType
    var provider: BMWRxProvider<T> { get }
}

public struct Networking: NetworkingType {
    typealias T = BMW
    let provider: BMWRxProvider<BMW>
}

extension NetworkingType {
    
    static func endpointsClosure<T>(_ xAccessToken: String? = nil) -> (T) -> Endpoint where T: TargetType {
        return { target in
            let endpoint: Endpoint = Endpoint(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: nil)
            return self.configHeaders(target: target , endpoint: endpoint)
        }
    }
    
    static func configHeaders<T>(target:T , endpoint: Endpoint)-> Endpoint where T: TargetType {
        
        let newEndpoint = endpoint.adding(newHTTPHeaderFields: ["SignVerion": "1"])
        
        return newEndpoint
    }
    
    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        return .never
    }
    
    static var plugins: [PluginType] {
        return [
            NetworkLogger(whitelist: { (target) -> Bool in
               return false
            }, blacklist: { target -> Bool in
                return false
            }),
        ]
    }
    
    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch let error {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
}

extension NetworkingType {
    
    static func newDefaultNetworking() -> Networking {
        return Networking(provider: newProvider(plugins))
    }
}

private func newProvider<T>(_ plugins: [PluginType]) -> BMWRxProvider<T> {
    return BMWRxProvider(endpointClosure: Networking.endpointsClosure(),
                          requestClosure: Networking.endpointResolver(),
                          stubClosure: Networking.APIKeysBasedStubBehaviour,
                          plugins: plugins)
}

// "Public" interfaces
extension Networking {

    func request(_ token: BMW, defaults: UserDefaults = UserDefaults.standard) -> Observable<Moya.Response> {
        
        let actualRequest = self.provider.provider.rx.request(token)
        return actualRequest.asObservable()
    }
}

// MARK: - Online
private let reachabilityManager = ReachabilityManager()
func connectedToInternetOrStubbing() -> Observable<Bool> {
    
    let stubbing = Observable.just(false)
    
    guard let online = reachabilityManager?.reach else {
        return stubbing
    }
    
    return [online, stubbing].combineLatestOr()
}

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (e) -> Bool in
            return value != e
        }
    }
}

protocol BooleanType {
    var boolValue: Bool { get }
}
extension Bool: BooleanType {
    var boolValue: Bool { return self }
}

extension Collection where Iterator.Element: ObservableType, Iterator.Element.E: BooleanType {
    
    func combineLatestAnd() -> Observable<Bool> {
        return Observable.combineLatest(self) { bools -> Bool in
            return bools.reduce(true, { (memo, element) in
                return memo && element.boolValue
            })
        }
    }
    
    func combineLatestOr() -> Observable<Bool> {
        return Observable.combineLatest(self) { bools in
            bools.reduce(false, { (memo, element) in
                return memo || element.boolValue
            })
        }
    }
}

private class ReachabilityManager {
    
    private let reachability: Reachability
    
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }
    
    init?() {
        guard let r = Reachability() else {
            return nil
        }
        self.reachability = r
        
        do {
            try self.reachability.startNotifier()
        } catch {
            return nil
        }
        
        self._reach.onNext(self.reachability.connection != .none)
        
        self.reachability.whenReachable = { _ in
            DispatchQueue.main.async { self._reach.onNext(true) }
        }
        
        self.reachability.whenUnreachable = { _ in
            DispatchQueue.main.async { self._reach.onNext(false) }
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

// MARK: - Formatter

class LoggerFormatter: Formatter {
    class func cURLCommandFromURLRequest(request: NSURLRequest) -> String {
        var command = "curl"
        let args = "-X \(request.httpMethod!)"
        command = command.appendCommandLineArgument(arg: args)
        
        if (request.httpBody != nil) {
            
            let HTTPBodyString = NSMutableString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)
            HTTPBodyString?.replaceOccurrences(of: "\\", with: "\\\\", options: .numeric, range: NSMakeRange(0, (HTTPBodyString?.length)!))
            HTTPBodyString?.replaceOccurrences(of: "`", with: "\\`", options: .numeric, range: NSMakeRange(0, (HTTPBodyString?.length)!))
            HTTPBodyString?.replaceOccurrences(of: "\"", with: "\\\"", options: .numeric, range: NSMakeRange(0, (HTTPBodyString?.length)!))
            HTTPBodyString?.replaceOccurrences(of: "$", with: "\\$", options: .numeric, range: NSMakeRange(0, (HTTPBodyString?.length)!))
            
            let formattedBodyString = "-d \"\(HTTPBodyString!)\""
            command = command.appendCommandLineArgument(arg: formattedBodyString)
        }
        
        let acceptEncodingHeader = request.allHTTPHeaderFields!["Accept-Encoding"]
        if(nil != acceptEncodingHeader && ((acceptEncodingHeader! as NSString).contains("gzip"))){
            command = command.appendCommandLineArgument(arg: "--compressed")
        }
        if let _ = request.url {
            let cookies = HTTPCookieStorage.shared.cookies(for: request.url!)
            if let cos = cookies, cos.count > 0 {
                let mutableCookieString = NSMutableString()
                for cookie: HTTPCookie in cookies! {
                    mutableCookieString.appendFormat("%@=%@;", cookie.name,cookie.value)
                }
                
                let formattedCookieString = "--cookie\"\(mutableCookieString)\""
                command = command.appendCommandLineArgument(arg: formattedCookieString)
            }
        }
        
        for (fieldKey,fieldValue) in request.allHTTPHeaderFields! {
            let valueString = (fieldValue as NSString).replacingOccurrences(of: "\'", with: "\\\'")
            let args = "-H '\(fieldKey): \(valueString)'"
            command = command.appendCommandLineArgument(arg: args)
        }
        
        command = command.appendCommandLineArgument(arg: "\"\(request.url!.absoluteString)\"")
        
        return command
    }
}

extension String {
    func appendCommandLineArgument(arg: String) -> String {
        let validArg = arg.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let appendArgs = self + " \(validArg)"
        return appendArgs
    }
}

// MARK: - Logger
class Logger {
    let destination: NSURL
    var handler: FileHandle?
    var dFormatter: DateFormatter?
    init(destination: NSURL) {
        self.destination = destination
    }
    
    func dateFormatter() -> DateFormatter {
        if dFormatter != nil {
            return dFormatter!
        }
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dFormatter = formatter
        return formatter
    }
    
    func fileHandler() -> FileHandle? {
        if handler != nil {
            return handler
        }
        if let path = self.destination.path {
            if !FileManager.default.fileExists(atPath: path) {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            }
            
            if let fileHandle = try? FileHandle(forWritingTo: self.destination as URL) {
                print("Successfully logging to: \(path)")
                handler = fileHandle
                return fileHandle
            } else {
                print("Serious error in logging: could not open path to log file.")
            }
        } else {
            print("Serious error in logging: specified destination (\(self.destination)) does not appear to have a path component.")
        }
        
        return nil
    }
    
    deinit {
        fileHandler()?.closeFile()
    }
    
    func log(message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let logMessage = stringRepresentation(message: message, function: function, file: file, line: line)
        
        printToConsole(logMessage: logMessage)
        printToDestination(logMessage: logMessage)
    }
}

private extension Logger {
    func stringRepresentation(message: String, function: String, file: String, line: Int) -> String {
        let dateString = dateFormatter().string(from: Date())
        
        let file = NSURL(fileURLWithPath: file).lastPathComponent ?? "(Unknown File)"
        return "\(dateString) [\(file):\(line)] \(function): \(message)\n"
    }
    
    func printToConsole(logMessage: String) {
        print(logMessage)
    }
    
    func printToDestination(logMessage: String) {
        if let data = logMessage.data(using: String.Encoding.utf8) {
            fileHandler()?.seekToEndOfFile()
            fileHandler()?.write(data)
        } else {
            print("Serious error in logging: could not encode logged string into data.")
        }
    }
}

let logger = Logger(destination: logPath())

