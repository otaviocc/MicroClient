import Foundation
import Testing

@testable import MicroClient

@Suite("NetworkRequest HTTP Body Tests")
struct NetworkRequestHTTPBodyTests {

    @Test("It should return form data when form items are present")
    func returnFormDataWhenFormItemsPresent() throws {
        let formItems = [
            URLFormItem(name: "username", value: "john"),
            URLFormItem(name: "email", value: "john@example.com")
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .post,
            formItems: formItems
        )

        let defaultEncoder = JSONEncoder()
        let httpBody = try request.httpBody(defaultEncoder: defaultEncoder)

        #expect(
            httpBody != nil,
            "It should return data when form items are present"
        )

        let bodyString = httpBody.flatMap { String(data: $0, encoding: .utf8) }
        #expect(
            bodyString?.contains("username=john") == true,
            "It should contain form data"
        )
        #expect(
            bodyString?.contains("email=john@example.com") == true,
            "It should contain all form fields"
        )
    }

    @Test("It should return JSON data when body is present")
    func returnJSONDataWhenBodyPresent() throws {
        let testModel = TestModelMother.makeHTTPBodyTestModel(value: "test data")
        let request = NetworkRequest<HTTPBodyTestModel, VoidResponse>(
            method: .post,
            body: testModel
        )

        let defaultEncoder = JSONEncoder()
        let httpBody = try request.httpBody(defaultEncoder: defaultEncoder)

        #expect(
            httpBody != nil,
            "It should return data when body is present"
        )

        let bodyString = httpBody.flatMap { String(data: $0, encoding: .utf8) }
        #expect(
            bodyString?.contains("test data") == true,
            "It should contain JSON encoded data"
        )
    }

    @Test("It should return nil when no body or form items")
    func returnNilWhenNoBodyOrFormItems() throws {
        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get
        )

        let defaultEncoder = JSONEncoder()
        let httpBody = try request.httpBody(defaultEncoder: defaultEncoder)

        #expect(
            httpBody == nil,
            "It should return nil when no body or form items"
        )
    }

    @Test("It should prefer form items over body")
    func preferFormItemsOverBody() throws {
        let testModel = TestModelMother.makeHTTPBodyTestModel(value: "should not appear")
        let formItems = [URLFormItem(name: "field", value: "form data")]

        let request = NetworkRequest<HTTPBodyTestModel, VoidResponse>(
            method: .post,
            formItems: formItems,
            body: testModel
        )

        let defaultEncoder = JSONEncoder()
        let httpBody = try request.httpBody(defaultEncoder: defaultEncoder)

        let bodyString = httpBody.flatMap { String(data: $0, encoding: .utf8) }
        #expect(
            bodyString?.contains("field=form%20data") == true,
            "It should use form data when both form items and body are present"
        )
        #expect(
            bodyString?.contains("should not appear") == false,
            "It should ignore body when form items are present"
        )
    }

    @Test("It should use custom encoder when provided")
    func useCustomEncoderWhenProvided() throws {
        let testModel = TestModelMother.makeHTTPBodyTestModel()

        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase

        let request = NetworkRequest<HTTPBodyTestModel, VoidResponse>(
            method: .post,
            body: testModel,
            encoder: customEncoder
        )

        let defaultEncoder = JSONEncoder()
        let httpBody = try request.httpBody(defaultEncoder: defaultEncoder)

        #expect(
            httpBody != nil,
            "It should return data with custom encoder"
        )
    }
}
