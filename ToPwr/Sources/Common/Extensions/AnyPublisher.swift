#if DEBUG
import Combine
import XCTestDynamicOverlay

public extension AnyPublisher {
    static func failing(file: StaticString = #file, line: UInt = #line) -> Self {
        Deferred {
            Future { promise in
                XCTFail(file: file, line: line)
            }
        }
        .eraseToAnyPublisher()
    }
}

public func failing0<S, F: Error>() -> AnyPublisher<S, F> {
        .failing()
}

public func failing1<S, F: Error, P>(
    _ p: P
) -> AnyPublisher<S, F> {
        .failing()
}

public func failing2<S, F: Error, P, Q>(
    _ p: P,
    _ q: Q
) -> AnyPublisher<S, F> {
        .failing()
}

public func failing3<S, F: Error, P, Q, R>(
    _ p: P,
    _ q: Q,
    _ r: R
) -> AnyPublisher<S, F> {
        .failing()
}

#endif
