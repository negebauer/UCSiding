// https://github.com/Quick/Quick

import Quick
import Nimble
import UCSiding

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        
        /// We can check the login by checking the session headers.
        /// If the login succeeded, the header will contain the proper cookies.
        describe("login") {
            let sessionCorrect = UCSSession(username: UCSTestCredentials.username(), password: UCSTestCredentials.password())
            let sessionIncorrect = UCSSession(username: "", password: "")
            
            sessionCorrect.login()
            sessionIncorrect.login()
            
            it("can login") {
                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    expect(sessionCorrect.headers()) != [:]
                    done()
                }
            }
            
            it("can detect failed login") {
                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    expect(sessionIncorrect.headers()) == [:]
                    done()
                }
            }
        }
    }
}

//        describe("these will fail") {

//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }

//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    dispatch_async(dispatch_get_main_queue()) {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        NSThread.sleepForTimeInterval(0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
