# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

MicroClient is a lightweight, zero-dependency Swift networking library designed for type-safe HTTP requests using modern Swift concurrency. The package targets macOS 12+ and iOS 15+, using Swift tools version 6.0.

## Development Commands

### Building and Testing
```bash
# Build the package
swift build

# Run SwiftLint (comprehensive ruleset with 61+ rules)
swiftlint

# Package uses Swift 6.0 tools version
swift package tools-version
```

### Code Quality
The project uses SwiftLint with extensive rules configured in `.swiftlint.yml`. Key requirements include:
- No force unwrapping
- Consistent code style and formatting
- Opt-in to advanced linting rules for better code quality

## Architecture

### Core Components

The library is built around four main types that work together:

1. **NetworkClient** - The main client interface (`NetworkClientProtocol` + `NetworkClient`)
   - Async/await API for making requests
   - Combine integration with status publisher
   - Request interceptor support for middleware

2. **NetworkRequest<RequestModel, ResponseModel>** - Type-safe request definitions
   - Generic constraints: `RequestModel: Encodable`, `ResponseModel: Decodable` 
   - Supports path, method, query items, form data, and JSON bodies
   - Per-request encoder/decoder overrides

3. **NetworkResponse<ResponseModel>** - Wraps decoded response + original URLResponse
   - Provides access to both processed data and raw HTTP metadata

4. **NetworkConfiguration** - Centralized configuration with override capability
   - Default URLSession, encoders/decoders, base URL, interceptor
   - Can be customized per-request

### Key Design Patterns

- **Generic Type System**: Compile-time type safety for requests/responses
- **Configuration Override**: Global defaults with per-request customization  
- **Protocol-Oriented**: Clear interface/implementation separation
- **Extension-Based Organization**: Related functionality grouped in Extensions/ directory

### Directory Structure

```
Sources/MicroClient/
├── NetworkClient.swift           # Main client implementation
├── NetworkRequest.swift          # Request model
├── NetworkResponse.swift         # Response wrapper  
├── NetworkConfiguration.swift    # Configuration
├── Types.swift                   # Core enums and utilities
└── Extensions/
    ├── URLRequest.swift         # Request building logic
    ├── URLComponents.swift      # URL construction
    ├── URLResponse.swift        # Response utilities
    └── Unwrap.swift            # Utility functions
```

## Usage Patterns

### Basic Request Pattern
```swift
let request = NetworkRequest<VoidRequest, ResponseModel>(
    path: "/api/endpoint",
    method: .get
)
let response = try await client.run(request)
```

### Type-Safe Requests
All requests use generic types with `Encodable` request models and `Decodable` response models. Use `VoidRequest`/`VoidResponse` for empty bodies.

### Configuration
Configure defaults in `NetworkConfiguration`, override per-request as needed. The client supports interceptors for middleware functionality.

## Real-World Examples

The package is used by several production API clients:
- **MicroblogAPI**: Micro.blog APIs with photo upload
- **MicroPinboardAPI**: Pinboard API integration  
- **MicropubAPI**: Micropub protocol support

See README.md for detailed usage examples and API documentation.

## Development Patterns

### Testing Structure
Future test implementation will include:
- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test interactions between modules
- **Mock objects**: `*Mock.swift` files provide test doubles
- **Test fixtures**: `*Mother.swift` files provide test data builders

### Unit Testing Guidelines
Future tests will use **Apple's Swift Testing framework** (`import Testing`) with the following conventions:

#### Test Structure and Organization
- Tests are organized using `@Suite("Suite Name")` to group related test cases
- Use descriptive test names with `@Test("It should...")` following the pattern: "It should [expected behavior]"
- Test method names should be descriptive without the `test` prefix (not required in Swift Testing framework)
- Follow **Given/When/Then** structure within test methods for clarity
- Use `try #require()` to avoid force unwrapping. Test method need to be marked with `throws`.
  E.g. `try #require(URL(string:"https://...."))`

#### Assertion Format
- Use `#expect()` for all test assertions with **one argument per line**
- Each `#expect()` should include a descriptive message as the second parameter
- Message format: "It should [describe what is being verified]"

#### Example Test Structure
```swift
@Suite("Component Tests")
struct ComponentTests {
    
    @Test("It should perform expected behavior")
    func performExpectedBehavior() async throws {
        // Given
        let input = setupTestData()
        
        // When
        let result = performOperation(input)
        
        // Then
        #expect(
            result.property == expectedValue,
            "It should have the correct property value"
        )
        #expect(
            result.isValid == true,
            "It should be in a valid state"
        )
    }
}
```

#### Mock and Fixture Usage
- Use `*Mock.swift` files for test doubles with configurable behavior
- Use `*Mother.swift` factories for creating test data consistently
- Follow the Mother pattern: `static func makeObject() -> ObjectType`
- Example: `NetworkClientMother.makeNetworkClient()`

#### Mock Implementation Guidelines
Mocks in this project follow a consistent pattern for capturing method calls and enabling test expectations:

**Call Tracking Pattern:**
- Add `methodNameCalled: Bool` property for call verification
- Add `methodNameCallCount: Int` property for counting calls
- Add `lastMethodParameterName: Type?` properties to capture method parameters
- Increment call counters and set call flags at the start of each mock method

**Error Injection:**
- Check `errorToThrow: Error?` property and throw if set
- This allows tests to verify error handling behavior

**Return Value Stubbing:**
- Use dedicated properties like `resultToReturn: ResultType?` for configurable return values
- Force unwrap (`resultToReturn!`) to crash if not properly stubbed in tests
- This ensures tests explicitly configure expected return values rather than using fallbacks

**Example Mock Method Pattern:**
```swift
func methodName(parameter: String) async throws -> ResultType {
    methodNameCalled = true
    methodNameCallCount += 1
    lastMethodParameter = parameter
    
    if let error = errorToThrow {
        throw error
    }
    
    return resultToReturn!
}
```

This pattern enables tests to:
- Verify methods were called with correct parameters
- Configure specific return values for test scenarios
- Test error handling by injecting errors
- Ensure all return values are explicitly configured (no silent fallbacks)

#### Async Testing
- Use `async throws` for test methods that test async operations
- Properly handle errors with do/catch blocks when testing error conditions
- Use `#expect(Bool(false), "It should throw an error...")` for failure cases in catch blocks

### Code Organization
- Protocol-oriented design with clear interface/implementation separation
- Extension-based feature grouping in Extensions/ directory
- Generic type system for compile-time type safety
- Configuration override pattern for flexible customization

### SwiftLint Integration
All targets include SwiftLintBuildToolPlugin for consistent code style enforcement during builds.
