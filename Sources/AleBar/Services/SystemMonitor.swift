import Foundation
import IOKit.ps
import Network

public final class SystemMonitor: @unchecked Sendable {
    public static let shared = SystemMonitor()
    
    private let pathMonitor = NWPathMonitor()
    private let pathMonitorQueue = DispatchQueue(label: "alebar.network")
    
    public var onBatteryStateChange: ((_ isLow: Bool, _ isCharging: Bool, _ level: Int) -> Void)?
    public var onNetworkStateChange: ((_ isConnected: Bool) -> Void)?
    
    private var timer: DispatchSourceTimer?
    private var lastCharging: Bool = false
    private var lastLevel: Int = 100
    private var lastConnected: Bool = true
    
    private init() {
        startNetworkMonitoring()
        startPeriodicMonitor()
    }
    
    private func startNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isConnected = (path.status == .satisfied)
            if isConnected != self.lastConnected {
                self.lastConnected = isConnected
                DispatchQueue.main.async {
                    self.onNetworkStateChange?(isConnected)
                }
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
    }
    
    private func startPeriodicMonitor() {
        let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        t.schedule(deadline: .now(), repeating: .seconds(4))
        t.setEventHandler { [weak self] in
            self?.checkBattery()
        }
        t.resume()
        self.timer = t
    }
    
    public func getBatteryInfo() -> (level: Int, isCharging: Bool) {
        let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef] ?? []
        
        for ps in sources {
            if let desc = IOPSGetPowerSourceDescription(blob, ps)?.takeUnretainedValue() as? [String: Any] {
                let current = desc[kIOPSCurrentCapacityKey] as? Int ?? 100
                let max = desc[kIOPSMaxCapacityKey] as? Int ?? 100
                let isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
                let percent = max > 0 ? Int((Double(current) / Double(max)) * 100.0) : 100
                return (percent, isCharging)
            }
        }
        return (100, false)
    }
    
    private func checkBattery() {
        let (level, isCharging) = getBatteryInfo()
        let isLow = level <= 20 && !isCharging
        
        if isCharging != lastCharging || abs(level - lastLevel) >= 5 {
            lastCharging = isCharging
            lastLevel = level
            DispatchQueue.main.async { [weak self] in
                self?.onBatteryStateChange?(isLow, isCharging, level)
            }
        }
    }
    
    public func getSystemStats() -> (cpu: Double, ram: Double) {
        var cpuUsage: Double = 0.0
        var ramUsage: Double = 0.0
        
        // Approximate CPU load using host_statistics
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        var cpuInfo = host_cpu_load_info()
        let kerr = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let total = Double(cpuInfo.cpu_ticks.0 + cpuInfo.cpu_ticks.1 + cpuInfo.cpu_ticks.2 + cpuInfo.cpu_ticks.3)
            let used = Double(cpuInfo.cpu_ticks.0 + cpuInfo.cpu_ticks.1 + cpuInfo.cpu_ticks.2)
            if total > 0 {
                cpuUsage = min(max((used / total) * 100.0, 5.0), 95.0)
            }
        }
        
        // RAM usage
        var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var vmStats = vm_statistics64()
        let vmErr = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(vmCount)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &vmCount)
            }
        }
        if vmErr == KERN_SUCCESS {
            let pageSize = Double(getpagesize())
            let active = Double(vmStats.active_count) * pageSize
            let wire = Double(vmStats.wire_count) * pageSize
            let totalRam = Double(ProcessInfo.processInfo.physicalMemory)
            if totalRam > 0 {
                ramUsage = min(max(((active + wire) / totalRam) * 100.0, 10.0), 90.0)
            }
        }
        
        return (cpuUsage, ramUsage)
    }
}
