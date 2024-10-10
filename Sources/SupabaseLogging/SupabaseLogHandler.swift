import Foundation
import Logging

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct SupabaseLogHandler: LogHandler {
    
    public var metadata: Logger.Metadata = [:]
    
    public var logLevel: Logger.Level = .debug
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            self.metadata[key]
        }
        set {
            self.metadata[key] = newValue
        }
    }
    
    private let label: String
    
    private let logManager: SupabaseLogManager
    
    public init(label: String, config: SupabaseLogConfig) {
        self.label = label
        self.logManager = SupabaseLogManager.shared(config)
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let entry = LogEntry(
            label: self.label,
            file: file,
            line: "\(line)",
            source: source,
            function: function,
            level: level.rawValue,
            message: message.description,
            loggedAt: Date(),
            metadata: self.metadata.merging(metadata ?? [:]) { $1 }
        )
        
        self.logManager.log(entry)
    }
}
