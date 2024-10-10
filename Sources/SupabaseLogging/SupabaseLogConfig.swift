import Foundation
import Pulse

public struct SupabaseLogConfig: Hashable {
    
    public let session: URLSessionProtocol?
    
    public let supabaseURL: String
    
    public let supabaseAnonKey: String
    
    public let table: String
    
    public let isDebug: Bool
    
    public init(
        session: URLSessionProtocol? = nil,
        supabaseURL: String,
        supabaseAnonKey: String,
        table: String = "logs",
        isDebug: Bool = true
    ) {
        self.session = session
        self.supabaseURL = supabaseURL
        self.supabaseAnonKey = supabaseAnonKey
        self.table = table
        
#if DEBUG
        self.isDebug = isDebug
#else
        self.isDebug = false
#endif
    }
    
    public static func == (lhs: SupabaseLogConfig, rhs: SupabaseLogConfig) -> Bool {
        lhs.supabaseURL == rhs.supabaseURL
        && lhs.supabaseAnonKey == rhs.supabaseAnonKey
        && lhs.table == rhs.table
        && lhs.isDebug == rhs.isDebug
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.supabaseURL)
        hasher.combine(self.supabaseAnonKey)
        hasher.combine(self.table)
        hasher.combine(self.isDebug)
    }
}
