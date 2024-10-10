import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public final class SupabaseLogManager {
    
    public let cache: LogsCache<LogEntry>
    
    public let config: SupabaseLogConfig
    
    private let minimumWaitTimeBetweenRequests: TimeInterval = 10
    
    private var sendTimer: Timer?
    
    private static let queue = DispatchQueue(label: "co.binaryscraping.supabase-log-manager.instances")
    
    private static var instances: [SupabaseLogConfig: SupabaseLogManager] = [:]
    
    public static func shared(_ config: SupabaseLogConfig) -> SupabaseLogManager {
        self.queue.sync {
            if let manager = self.instances[config] {
                return manager
            }
            
            let manager = SupabaseLogManager(config: config)
            
            self.instances[config] = manager
            
            return manager
        }
    }
    
    private init(config: SupabaseLogConfig) {
        self.config = config
        self.cache = LogsCache(isDebug: config.isDebug)
        
#if os(macOS)
        NotificationCenter.default.addObserver(self, selector: #selector(Self.appWillTerminate), name: NSApplication.willTerminateNotification, object: nil)
#elseif os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // We need to use a delay with these type of notifications because they fire on app load which causes a double load of the cache from disk
            NotificationCenter.default.addObserver(self, selector: #selector(Self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(Self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
#endif
        
        self.startTimer()
    }
    
    private func startTimer() {
        self.sendTimer?.invalidate()
        
        self.sendTimer = Timer.scheduledTimer(
            timeInterval: self.minimumWaitTimeBetweenRequests,
            target: self,
            selector: #selector(Self.checkForLogsAndSend),
            userInfo: nil,
            repeats: true
        )
        
        // Fire the timer to attempt to send any cached logs from a previous session.
        self.checkForLogsAndSend()
    }
    
    public func log(_ payload: LogEntry) {
        self.cache.push(payload)
    }
    
    @objc
    private func checkForLogsAndSend() {
        let logs = self.cache.pop()
        
        guard !logs.isEmpty else {
            return
        }
        
        let data = try! encoder.encode(logs)
        
        guard let url = URL(string: self.config.supabaseURL)?.appendingPathComponent(self.config.table) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(self.config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        let session = self.config.session ?? URLSession(configuration: config)
        
        session.dataTask(with: request) { _, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
            } catch {
                if self.config.isDebug {
                    print(error)
                }
                
                // An error ocurred, put logs back in cache.
                self.cache.push(logs)
            }
        }
        .resume()
    }
}

extension SupabaseLogManager {
    
    @objc
    public func appWillTerminate() {
        if self.config.isDebug {
            print(#function)
        }
        
        self.cache.backupCache()
    }
    
#if os(iOS)
    @objc
    public func didEnterForeground() {
        if self.config.isDebug {
            print(#function)
        }
        
        self.startTimer()
    }
    
    @objc
    public func didEnterBackground() {
        if self.config.isDebug {
            print(#function)
        }
        
        self.sendTimer?.invalidate()
        self.sendTimer = nil
        
        self.cache.backupCache()
    }
#endif
}
