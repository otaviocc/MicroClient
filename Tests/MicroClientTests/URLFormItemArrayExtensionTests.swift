import Testing
@testable import MicroClient

@Suite("URLFormItem Array Extension Tests")
struct URLFormItemArrayExtensionTests {

    @Test("It should encode single form item to URL encoded data")
    func encodeSingleFormItemToURLEncodedData() {
        let formItems = [URLFormItem(name: "username", value: "john_doe")]

        let encodedData = formItems.urlEncoded()
        let encodedString = encodedData.flatMap { String(data: $0, encoding: .utf8) }

        #expect(
            encodedData != nil,
            "It should return encoded data"
        )
        #expect(
            encodedString == "username=john_doe",
            "It should encode the form item correctly"
        )
    }

    @Test("It should encode multiple form items to URL encoded data")
    func encodeMultipleFormItemsToURLEncodedData() {
        let formItems = [
            URLFormItem(name: "username", value: "john_doe"),
            URLFormItem(name: "email", value: "john@example.com"),
            URLFormItem(name: "age", value: "30")
        ]

        let encodedData = formItems.urlEncoded()
        let encodedString = encodedData.flatMap { String(data: $0, encoding: .utf8) }

        #expect(
            encodedData != nil,
            "It should return encoded data"
        )
        #expect(
            encodedString?.contains("username=john_doe") == true,
            "It should contain the username parameter"
        )
        #expect(
            encodedString?.contains("email=john@example.com") == true,
            "It should contain the email parameter"
        )
        #expect(
            encodedString?.contains("age=30") == true,
            "It should contain the age parameter"
        )
    }

    @Test("It should handle form items with nil values by filtering them out")
    func handleFormItemsWithNilValues() {
        let formItems = [
            URLFormItem(name: "username", value: "john_doe"),
            URLFormItem(name: "optional_field", value: nil),
            URLFormItem(name: "email", value: "john@example.com")
        ]

        let encodedData = formItems.urlEncoded()
        let encodedString = encodedData.flatMap { String(data: $0, encoding: .utf8) }

        #expect(
            encodedData != nil,
            "It should return encoded data"
        )
        #expect(
            encodedString?.contains("username=john_doe") == true,
            "It should contain the username parameter"
        )
        #expect(
            encodedString?.contains("optional_field") == false,
            "It should not contain the nil value parameter"
        )
        #expect(
            encodedString?.contains("email=john@example.com") == true,
            "It should contain the email parameter"
        )
    }

    @Test("It should handle empty array")
    func handleEmptyArray() {
        let formItems: [URLFormItem] = []

        let encodedData = formItems.urlEncoded()

        #expect(
            encodedData != nil,
            "It should return data for empty array"
        )
        #expect(
            encodedData?.isEmpty == true,
            "It should return empty data for empty array"
        )
    }

    @Test("It should handle array with only nil values")
    func handleArrayWithOnlyNilValues() {
        let formItems = [
            URLFormItem(name: "field1", value: nil),
            URLFormItem(name: "field2", value: nil)
        ]

        let encodedData = formItems.urlEncoded()

        #expect(
            encodedData != nil,
            "It should return data even when all values are nil"
        )
        #expect(
            encodedData?.isEmpty == true,
            "It should return empty data when all values are nil"
        )
    }

    @Test("It should properly encode special characters")
    func properlyEncodeSpecialCharacters() {
        let formItems = [
            URLFormItem(name: "message", value: "Hello World!"),
            URLFormItem(name: "symbols", value: "@#$%^&*()"),
            URLFormItem(name: "spaces", value: "value with spaces")
        ]

        let encodedData = formItems.urlEncoded()
        let encodedString = encodedData.flatMap { String(data: $0, encoding: .utf8) }

        #expect(
            encodedData != nil,
            "It should return encoded data"
        )
        #expect(
            encodedString?.contains("message=Hello%20World!") == true,
            "It should URL encode spaces in the message"
        )
        #expect(
            encodedString?.contains("symbols=@%23$%25%5E%26*()") == true,
            "It should URL encode specific symbols"
        )
        #expect(
            encodedString?.contains("spaces=value%20with%20spaces") == true,
            "It should URL encode spaces"
        )
    }

    @Test("It should handle form items with empty string values")
    func handleFormItemsWithEmptyStringValues() {
        let formItems = [
            URLFormItem(name: "empty_field", value: ""),
            URLFormItem(name: "normal_field", value: "value")
        ]

        let encodedData = formItems.urlEncoded()
        let encodedString = encodedData.flatMap { String(data: $0, encoding: .utf8) }

        #expect(
            encodedData != nil,
            "It should return encoded data"
        )
        #expect(
            encodedString?.contains("empty_field=") == true,
            "It should include empty string values"
        )
        #expect(
            encodedString?.contains("normal_field=value") == true,
            "It should include normal values"
        )
    }
}
