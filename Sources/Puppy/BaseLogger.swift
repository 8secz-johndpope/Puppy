import Foundation

public protocol Loggerable {

    var label: String { get }

    func log(_ level: LogLevel, string: String)
}

public class BaseLogger: Loggerable {

    public var enabled: Bool = true
    public var logLevel: LogLevel = .trace

    public func isLogging(_ level: LogLevel) -> Bool {
        return level.rawValue >= logLevel.rawValue
    }

    public var format: LogFormattable?

    @inlinable
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) {
        if !enabled { return }

        var formattedMessage = ""
        if let format = format {
            formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
        } else {
            formattedMessage = message
        }

        if let queue = queue, asynchronous {
            queue.async {
                self.log(level, string: formattedMessage)
            }
        } else {
            log(level, string: formattedMessage)
        }
    }

    public var asynchronous: Bool = true

    public var label: String
    public var queue: DispatchQueue? { return nil }

    public init(_ label: String) {
        self.label = label
    }

    public func log(_ level: LogLevel, string: String) {

    }
}

extension BaseLogger: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }

    public static func == (lhs: BaseLogger, rhs: BaseLogger) -> Bool {
        return lhs.label == rhs.label
    }
}
