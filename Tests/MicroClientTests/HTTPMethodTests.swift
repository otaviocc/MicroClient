import Testing

@testable import MicroClient

@Suite("HTTPMethod Tests")
struct HTTPMethodTests {

    @Test("It should have uppercase GET raw value")
    func haveUppercaseGETRawValue() {
        let method = HTTPMethod.get

        #expect(
            method.rawValue == "GET",
            "It should have uppercase GET as raw value"
        )
    }

    @Test("It should have uppercase POST raw value")
    func haveUppercasePOSTRawValue() {
        let method = HTTPMethod.post

        #expect(
            method.rawValue == "POST",
            "It should have uppercase POST as raw value"
        )
    }

    @Test("It should have uppercase DELETE raw value")
    func haveUppercaseDELETERawValue() {
        let method = HTTPMethod.delete

        #expect(
            method.rawValue == "DELETE",
            "It should have uppercase DELETE as raw value"
        )
    }

    @Test("It should have uppercase PUT raw value")
    func haveUppercasePUTRawValue() {
        let method = HTTPMethod.put

        #expect(
            method.rawValue == "PUT",
            "It should have uppercase PUT as raw value"
        )
    }

    @Test("It should have uppercase PATCH raw value")
    func haveUppercasePATCHRawValue() {
        let method = HTTPMethod.patch

        #expect(
            method.rawValue == "PATCH",
            "It should have uppercase PATCH as raw value"
        )
    }

    @Test("It should be initialized from raw value")
    func beInitializedFromRawValue() {
        let getMethod = HTTPMethod(rawValue: "GET")
        let postMethod = HTTPMethod(rawValue: "POST")
        let deleteMethod = HTTPMethod(rawValue: "DELETE")
        let putMethod = HTTPMethod(rawValue: "PUT")
        let patchMethod = HTTPMethod(rawValue: "PATCH")

        #expect(
            getMethod == .get,
            "It should initialize GET method from raw value"
        )
        #expect(
            postMethod == .post,
            "It should initialize POST method from raw value"
        )
        #expect(
            deleteMethod == .delete,
            "It should initialize DELETE method from raw value"
        )
        #expect(
            putMethod == .put,
            "It should initialize PUT method from raw value"
        )
        #expect(
            patchMethod == .patch,
            "It should initialize PATCH method from raw value"
        )
    }

    @Test("It should return nil for invalid raw value")
    func returnNilForInvalidRawValue() {
        let invalidMethod = HTTPMethod(rawValue: "INVALID")
        let lowercaseMethod = HTTPMethod(rawValue: "get")
        let emptyMethod = HTTPMethod(rawValue: "")

        #expect(
            invalidMethod == nil,
            "It should return nil for invalid method name"
        )
        #expect(
            lowercaseMethod == nil,
            "It should return nil for lowercase method name"
        )
        #expect(
            emptyMethod == nil,
            "It should return nil for empty string"
        )
    }
}
