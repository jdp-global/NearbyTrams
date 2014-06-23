//
//  Copyright (c) 2014 Dblechoc. All rights reserved.
//

import Quick
import Nimble
import NearbyTramsNetworkKit

class NetworkServiceSpec: QuickSpec {
    override func spec() {
        var service: NetworkService!
        
        describe("Init") {
            beforeEach {
                service = NetworkService(baseURL: NSURL(string: "http://www.apple.com"))
            }
            
            it("should have a baseURL") {
                expect(service.baseURL.absoluteString).to.equal("http://www.apple.com")
            }
        }
        
        describe("getStopInformationWithStopId") {
            beforeEach {
                let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
                let urlProcolClass: AnyObject = ClassUtility.classFromType(MockWebServiceURLProtocol.self)
                configuration.protocolClasses = [urlProcolClass]
                
                service = NetworkService(baseURL: NSURL(string: "mock://www.apple.com"), configuration: configuration)
            }
            
            it("should return a session data task") {
                let task = service.getStopInformationWithStopId("123", completionHandler: nil)
                
                expect(task).notTo.beNil()
            }
            
            context("when an error occur") {
                
                var error: NSError!
                
                beforeEach {
                    error = NSError(domain: "au.com.otherTest.domain", code: 150, userInfo: nil)
                    let response = MockWebServiceResponse(body: ["test": "blah"], header: ["Content-Type": "application/json; charset=utf-8"], statusCode: 404, error: error)
                    MockWebServiceURLProtocol.cannedResponse = response
                }
                
                afterEach {
                    MockWebServiceURLProtocol.cannedResponse = nil
                }
                
                it("should complete with an error") {
                    
                    var dictionary: NSDictionary!
                    var completionError: NSError!
                    
                    let stopInfoTask = service.getStopInformationWithStopId("123", {
                        stop, error -> Void in
                        
                        dictionary = stop
                        completionError = error
                        })
                    
                    expect{dictionary}.will.beNil()
                    expect{completionError}.will.equal(error)
                }
            }
            
            context("when successful") {
                
                var responseObject: Dictionary<String, AnyObject>!
                
                beforeEach {
                    responseObject = ["test": "blah"]
                    let response = MockWebServiceResponse(body: ["ResponseObject": responseObject], header: ["Content-Type": "application/json; charset=utf-8"])
                    MockWebServiceURLProtocol.cannedResponse = response
                }
                
                afterEach {
                    MockWebServiceURLProtocol.cannedResponse = nil
                }
                
                it("should complete with a dictionary and no error") {
                    
                    var dictionary: NSDictionary!
                    var completionError: NSError!
                    
                    let task = service.getStopInformationWithStopId("123", {
                        stop, error -> Void in
                        
                        dictionary = stop
                        completionError = error
                        })
                    
                    expect{dictionary}.will.equal(responseObject)
                    expect{completionError}.will.beNil()
                }
            }
        }
    }
}
