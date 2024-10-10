import Foundation

public final class LogsCache<T: Codable> {
    
    private let isDebug: Bool
    
    private let maximumNumberOfLogsToPopAtOnce: Int = 100
    
    private let queue: DispatchQueue = DispatchQueue(label: "co.binaryscraping.supabase-log-cache", attributes: .concurrent)
    
    private var cachedLogs: [T] = []
    
    public func push(_ log: T) {
        self.queue.sync {
            self.cachedLogs.append(log)
        }
    }
    
    public func push(_ logs: [T]) {
        self.queue.sync {
            self.cachedLogs.append(contentsOf: logs)
        }
    }
    
    public func pop() -> [T] {
        var poppedLogs: [T] = []
        
        self.queue.sync(flags: .barrier) {
            let sliceSize = min(self.maximumNumberOfLogsToPopAtOnce, self.cachedLogs.count)
            
            poppedLogs = Array(self.cachedLogs[..<sliceSize])
            
            self.cachedLogs.removeFirst(sliceSize)
        }
        
        return poppedLogs
    }
    
    public func backupCache() {
        self.queue.sync(flags: .barrier) {
            if JSONSerialization.isValidJSONObject(self.cachedLogs) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: self.cachedLogs)
                    
                    try data.write(to: LogsCache.fileURL())
                    
                    self.cachedLogs = []
                } catch {
                    if self.isDebug {
                        print("Error saving Logs cache.")
                    }
                }
            } else {
                if self.isDebug {
                    print("Invalid JSON object.")
                }
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("supabase-log-cache")
    }
    
    public init(isDebug: Bool) {
        self.isDebug = isDebug
        
        do {
            let data = try Data(contentsOf: LogsCache.fileURL())
            try FileManager.default.removeItem(at: LogsCache.fileURL())
            
            let logs = try decoder.decode([T].self, from: data)
            self.cachedLogs = logs
        } catch {
            if isDebug {
                print("Error recovering logs from cache.")
            }
        }
    }
}
