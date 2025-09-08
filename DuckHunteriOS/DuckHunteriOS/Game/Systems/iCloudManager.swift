//
//  iCloudManager.swift
//  DuckHunteriOS_Full
//
//  iCloud integration for data synchronization
//

import CloudKit
import AppKit

class iCloudManager {

    // MARK: - Properties
    static let shared = iCloudManager()

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase

    private var isICloudAvailable = false

    // Record types
    private let gameStatsRecordType = "GameStats"
    private let playerSettingsRecordType = "PlayerSettings"

    // MARK: - Initialization
    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
        sharedDatabase = container.sharedCloudDatabase

        checkICloudAvailability()
        setupNotifications()
    }

    // MARK: - iCloud Availability
    private func checkICloudAvailability() {
        container.accountStatus { [weak self] status, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("☁️ iCloud is available")
                    self.isICloudAvailable = true
                case .noAccount:
                    print("⚠️ No iCloud account available")
                    self.isICloudAvailable = false
                case .restricted:
                    print("⚠️ iCloud access restricted")
                    self.isICloudAvailable = false
                case .couldNotDetermine:
                    print("❓ Could not determine iCloud status")
                    self.isICloudAvailable = false
                @unknown default:
                    print("❓ Unknown iCloud status")
                    self.isICloudAvailable = false
                }
            }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accountChanged),
                                               name: .CKAccountChanged,
                                               object: nil)
    }

    @objc private func accountChanged() {
        print("☁️ iCloud account changed, rechecking availability...")
        checkICloudAvailability()
    }

    // MARK: - Game Stats Synchronization
    func saveGameStats(highScore: Int, totalDucks: Int, accuracy: Double, completion: @escaping (Error?) -> Void) {
        guard isICloudAvailable else {
            completion(NSError(domain: "iCloudManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "iCloud not available"]))
            return
        }

        let recordID = CKRecord.ID(recordName: "gameStats")
        let record = CKRecord(recordType: gameStatsRecordType, recordID: recordID)

        record["highScore"] = highScore as CKRecordValue
        record["totalDucks"] = totalDucks as CKRecordValue
        record["accuracy"] = accuracy as CKRecordValue
        record["lastUpdated"] = Date() as CKRecordValue

        let saveOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        saveOperation.savePolicy = .allKeys

        saveOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                print("❌ Failed to save game stats to iCloud: \(error.localizedDescription)")
            } else {
                print("✅ Game stats saved to iCloud")
            }
            completion(error)
        }

        privateDatabase.add(saveOperation)
    }

    func loadGameStats(completion: @escaping (Int?, Int?, Double?, Error?) -> Void) {
        guard isICloudAvailable else {
            completion(nil, nil, nil, NSError(domain: "iCloudManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "iCloud not available"]))
            return
        }

        let recordID = CKRecord.ID(recordName: "gameStats")
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                print("❌ Failed to load game stats from iCloud: \(error.localizedDescription)")
                completion(nil, nil, nil, error)
                return
            }

            if let record = record {
                let highScore = record["highScore"] as? Int
                let totalDucks = record["totalDucks"] as? Int
                let accuracy = record["accuracy"] as? Double

                print("✅ Game stats loaded from iCloud")
                completion(highScore, totalDucks, accuracy, nil)
            } else {
                print("ℹ️ No game stats found in iCloud")
                completion(nil, nil, nil, nil)
            }
        }
    }

    // MARK: - Player Settings Synchronization
    func savePlayerSettings(settings: [String: Any], completion: @escaping (Error?) -> Void) {
        guard isICloudAvailable else {
            completion(NSError(domain: "iCloudManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "iCloud not available"]))
            return
        }

        let recordID = CKRecord.ID(recordName: "playerSettings")
        let record = CKRecord(recordType: playerSettingsRecordType, recordID: recordID)

        // Convert settings to CKRecord values
        for (key, value) in settings {
            if let stringValue = value as? String {
                record[key] = stringValue as CKRecordValue
            } else if let intValue = value as? Int {
                record[key] = intValue as CKRecordValue
            } else if let doubleValue = value as? Double {
                record[key] = doubleValue as CKRecordValue
            } else if let boolValue = value as? Bool {
                record[key] = boolValue as CKRecordValue
            }
        }

        record["lastUpdated"] = Date() as CKRecordValue

        let saveOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        saveOperation.savePolicy = .allKeys

        saveOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                print("❌ Failed to save player settings to iCloud: \(error.localizedDescription)")
            } else {
                print("✅ Player settings saved to iCloud")
            }
            completion(error)
        }

        privateDatabase.add(saveOperation)
    }

    func loadPlayerSettings(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard isICloudAvailable else {
            completion(nil, NSError(domain: "iCloudManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "iCloud not available"]))
            return
        }

        let recordID = CKRecord.ID(recordName: "playerSettings")
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                print("❌ Failed to load player settings from iCloud: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            if let record = record {
                var settings: [String: Any] = [:]

                for key in record.allKeys() {
                    if key == "lastUpdated" { continue }
                    settings[key] = record[key]
                }

                print("✅ Player settings loaded from iCloud")
                completion(settings, nil)
            } else {
                print("ℹ️ No player settings found in iCloud")
                completion(nil, nil)
            }
        }
    }

    // MARK: - Data Synchronization
    func syncData() {
        guard isICloudAvailable else {
            print("⚠️ iCloud not available for sync")
            return
        }

        print("🔄 Starting iCloud data synchronization...")

        // Sync game stats
        loadGameStats { highScore, totalDucks, accuracy, error in
            if let error = error {
                print("❌ Game stats sync failed: \(error.localizedDescription)")
            } else {
                print("✅ Game stats synced")
                // Update local data with synced values
                NotificationCenter.default.post(name: NSNotification.Name("GameStatsSynced"),
                                              object: nil,
                                              userInfo: ["highScore": highScore ?? 0,
                                                        "totalDucks": totalDucks ?? 0,
                                                        "accuracy": accuracy ?? 0.0])
            }
        }

        // Sync player settings
        loadPlayerSettings { settings, error in
            if let error = error {
                print("❌ Player settings sync failed: \(error.localizedDescription)")
            } else {
                print("✅ Player settings synced")
                // Update local settings with synced values
                if let settings = settings {
                    NotificationCenter.default.post(name: NSNotification.Name("PlayerSettingsSynced"),
                                                  object: nil,
                                                  userInfo: settings)
                }
            }
        }
    }

    // MARK: - Utility Methods
    func isiCloudAvailable() -> Bool {
        return isICloudAvailable
    }

    func requestICloudPermission(from viewController: NSViewController) {
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            if let error = error {
                print("❌ iCloud permission request failed: \(error.localizedDescription)")
                return
            }

            switch status {
            case .granted:
                print("✅ iCloud permission granted")
            case .denied:
                print("❌ iCloud permission denied")
            case .couldNotComplete:
                print("❓ iCloud permission request could not complete")
            case .initialState:
                print("ℹ️ iCloud permission in initial state")
            @unknown default:
                print("❓ Unknown iCloud permission status")
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
