import Foundation

public struct SupabaseLogConfig: Hashable {
    
    public let session: URLSession?
    
    public let supabaseURL: String
    
    public let supabaseAnonKey: String
    
    public let table: String
    
    public let isDebug: Bool
    
    public init(
        session: URLSession? = nil,
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
}
