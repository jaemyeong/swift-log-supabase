import Foundation
import Logging

public struct LogEntry: Codable {
    
    public let label: String
    
    public let file: String
    
    public let line: String
    
    public let source: String
    
    public let function: String
    
    public let level: String
    
    public let message: String
    
    public let loggedAt: Date
    
    public let metadata: Logger.Metadata?
}
