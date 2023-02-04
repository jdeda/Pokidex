import Foundation

extension Date {
  var elapsedTime: String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.minute, .nanosecond]
    formatter.allowsFractionalUnits = true
    let diff = Date().timeIntervalSince(self)
    let diffDouble = Double(diff)
    if diffDouble < 0.1 {
      return String(format: "%0.fms", (diffDouble * 1000))
    }
    else {
      return String(format: "%0.fs", diffDouble)
    }
  }
}
