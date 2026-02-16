// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Testing
@testable import MicroClient

@Suite("URLFormItem Tests")
struct URLFormItemTests {

    @Test("It should initialize with name and value")
    func initializeWithNameAndValue() {
        let name = "username"
        let value = "john_doe"

        let formItem = URLFormItem(name: name, value: value)

        #expect(
            formItem.name == name,
            "It should store the provided name"
        )
        #expect(
            formItem.value == value,
            "It should store the provided value"
        )
    }

    @Test("It should initialize with name and nil value")
    func initializeWithNameAndNilValue() {
        let name = "optional_field"
        let value: String? = nil

        let formItem = URLFormItem(name: name, value: value)

        #expect(
            formItem.name == name,
            "It should store the provided name"
        )
        #expect(
            formItem.value == nil,
            "It should store nil value when provided"
        )
    }

    @Test("It should conform to Equatable")
    func conformToEquatable() {
        let formItem1 = URLFormItem(name: "key", value: "value")
        let formItem2 = URLFormItem(name: "key", value: "value")
        let formItem3 = URLFormItem(name: "different", value: "value")
        let formItem4 = URLFormItem(name: "key", value: "different")
        let formItem5 = URLFormItem(name: "key", value: nil)

        #expect(
            formItem1 == formItem2,
            "It should be equal when name and value match"
        )
        #expect(
            formItem1 != formItem3,
            "It should not be equal when names differ"
        )
        #expect(
            formItem1 != formItem4,
            "It should not be equal when values differ"
        )
        #expect(
            formItem1 != formItem5,
            "It should not be equal when one value is nil"
        )
    }

    @Test("It should conform to Hashable")
    func conformToHashable() {
        let formItem1 = URLFormItem(name: "key", value: "value")
        let formItem2 = URLFormItem(name: "key", value: "value")
        let formItem3 = URLFormItem(name: "different", value: "value")

        let set: Set<URLFormItem> = [formItem1, formItem2, formItem3]

        #expect(
            set.count == 2,
            "It should have unique hash values for different form items"
        )
        #expect(
            set.contains(formItem1),
            "It should contain the first form item"
        )
        #expect(
            set.contains(formItem3),
            "It should contain the different form item"
        )
    }
}
