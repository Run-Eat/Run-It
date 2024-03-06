//
//  RunningRecordViewModel.swift
//  Run-It
//
//  Created by t2023-m0024 on 3/5/24.
//

import Foundation

import CoreData

class RunningRecordViewModel {
    // 뷰에 표시될 속성들
    var id: UUID
    var dateText: String
    var labelText: String
    var distanceText: String
    var timeText: String
    var paceText: String
    var routeImageData: Data?
    
    init(runningRecord: RunningRecord) {
        self.id = runningRecord.id ?? UUID()
        self.dateText = RunningRecordViewModel.dateFormatter.string(from: runningRecord.date ?? Date())
        self.labelText = runningRecord.label ?? dateText
        self.distanceText = String(format: "%.2f", runningRecord.distance / 1000)
        self.timeText = RunningRecordViewModel.timeFormatter.string(from: TimeInterval(runningRecord.time)) ?? "N/A"
        let paceMinutes = Int(runningRecord.pace) / 60
        let paceSeconds = Int(runningRecord.pace) % 60
        self.paceText = String(format: "%02d:%02d", paceMinutes, paceSeconds)
        self.routeImageData = runningRecord.routeImage
    }
    
    private var runningRecords: [RunningRecord] = []
    
    func fetchRunningRecords(completion: @escaping () -> Void) {
        runningRecords = CoreDataManager.shared.fetchRunningRecords()
        // 최신 레코드를 사용해 뷰모델의 속성 설정
        if let latestRecord = runningRecords.last {
            configure(with: latestRecord)
        }
        completion()
    }
    
    private func configure(with record: RunningRecord) {
        dateText = labelText
        distanceText = String(format: "%.2f km", record.distance)
        timeText = RunningRecordViewModel.timeFormatter.string(from: TimeInterval(record.time)) ?? "N/A"
        let paceMinutes = Int(record.pace) / 60
        let paceSeconds = Int(record.pace) % 60
        paceText = String(format: "%02d:%02d min/km", paceMinutes, paceSeconds)
        routeImageData = record.routeImage
    }
    
    func updateLabelText(newLabelText: String) {
        // Update the viewModel's labelText
        self.labelText = newLabelText
        
        // Find the RunningRecord entity with the current ID and update its label
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RunningRecord> = RunningRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let recordToUpdate = results.first {
                recordToUpdate.label = newLabelText
                try context.save()
                print("Label successfully updated to '\(newLabelText)' for record ID: \(self.id)")
            }
        } catch let error as NSError {
            print("Updating label failed: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Delete RunningRecord
    func deleteRunningRecord(at index: Int, completion: @escaping (Bool) -> Void) {
        // Assuming you have an array of RunningRecords in your viewModel
        let recordToDelete = runningRecords[index]
        
        // Delete from Core Data
        if let recordId = recordToDelete.id {
            CoreDataManager.shared.deleteRunningRecord(withId: recordId) { success in
                // Handle the deletion result
            }
        } else {
            // Handle the case where recordToDelete.id is nil
            print("Record ID is nil, cannot delete.")
        }
    }


}
// MARK: - Helper Methods
extension RunningRecordViewModel {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd. (E), HH:mm"
        return formatter
    }()
    
    private static var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
