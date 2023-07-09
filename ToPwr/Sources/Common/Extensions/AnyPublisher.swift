#if DEBUG
import Combine
import XCTestDynamicOverlay

public enum AsyncError: Error {
    case finishedWithoutValue
}

// TODO: temporary solution until we actually rewrite stuff do do away with Combine
public extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            
            cancellable = first()
                .sink(
                    receiveCompletion: { result in
                        switch result {
                        case .finished:
                            if finishedWithoutValue {
                                continuation.resume(throwing: AsyncError.finishedWithoutValue)
                            }
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        finishedWithoutValue = false
                        continuation.resume(with: .success(value))
                    }
                )
        }
    }
}


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
