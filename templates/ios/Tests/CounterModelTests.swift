import Testing
@testable import __APP_NAME__

struct CounterModelTests {
    @Test func startsAtZero() {
        let model = CounterModel()
        #expect(model.count == 0)
    }

    @Test func incrementAddsOne() {
        let model = CounterModel()
        model.increment()
        model.increment()
        #expect(model.count == 2)
    }

    @Test func resetReturnsToZero() {
        let model = CounterModel()
        model.increment()
        model.reset()
        #expect(model.count == 0)
    }
}
