import Observation

/// Example model. Replace with real app state.
/// Logic lives in models so it can be unit tested without views.
@Observable
final class CounterModel {
    private(set) var count = 0

    func increment() {
        count += 1
    }

    func reset() {
        count = 0
    }
}
