import DataSource
import CoreGraphics

public final class CellSizeCache: CustomDebugStringConvertible {
    private final class SizeContainer: CustomDebugStringConvertible {
        var value: CGSize?
        
        var debugDescription: String {
            if let value = value {
                return "\(value)"
            } else {
                return "--"
            }
        }
    }

    private let storage = DPArrayController()

    public let container: DataSourceContainerController
    public init(container: DataSourceContainerController) {
        self.container = container
        invalidate()
    }

    public func invalidate() {
        storage.removeAllObjects()

        for section in 0 ..< container.numberOfSections() {
            storage.insertSection(at: UInt(section))
            let objects = (0 ..< container.numberOfItems(inSection: section)).map { _ in SizeContainer() }
            storage.setObjects(objects, atSection: section)
        }
    }

    public subscript(_ indexPath: IndexPath) -> CGSize? {
        set(newValue) {
            (storage.object(at: indexPath) as? SizeContainer)?.value = newValue
        }
        get {
            return (storage.object(at: indexPath) as? SizeContainer)?.value
        }
    }
    
    public var debugDescription: String {
        var result: [String] = []
        for section in 0 ..< storage.numberOfSections() {
            for item in 0 ..< storage.numberOfItems(inSection: section) {
                let indexPath: IndexPath = IndexPath(item: item, section: section)
                let object = storage.object(at: indexPath) as! SizeContainer
                result.append("\(indexPath) size: \(object.debugDescription)")
            }
        }
        return result.joined(separator: "\n")
    }
}

// MARK: - Explicit changes

public extension CellSizeCache {
    func startUpdating() {
        storage.startUpdating()
    }

    func endUpdating() {
        storage.endUpdating()
    }

    func isUpdating() -> Bool {
        return storage.isUpdating()
    }

    // MARK: -

    func insert(at indexPath: IndexPath) {
        storage.insert(SizeContainer(), atIndextPath: indexPath)
    }

    func delete(at indexPath: IndexPath) {
        storage.deleteObject(atIndextPath: indexPath)
    }

    func reload(at indexPath: IndexPath) {
        (storage.object(at: indexPath) as? SizeContainer)?.value = nil
    }

    func move(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        storage.moveObject(atIndextPath: indexPath, to: newIndexPath)
    }

    // MARK: -

    func insertSection(at index: UInt) {
        storage.insertSection(at: index)
    }

    func removeSection(at index: UInt) {
        storage.removeSection(at: index)
    }

    func reloadSection(at index: UInt) {
        for object in storage.sections[Int(index)].objects ?? [] {
            (object as? SizeContainer)?.value = nil
        }
    }
}

// MARK: - Controller changes

public extension CellSizeCache {
    func controllerWillChangeContent(_ controller: DataSourceContainerController) {
        guard controller === container else { return }
        startUpdating()
    }

    func controller(_ controller: DataSourceContainerController, didChangeObjectAt indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard controller === container else { return }

        switch type {
        case .insert: insert(at: newIndexPath!)
        case .delete: delete(at: indexPath!)
        case .move: move(at: indexPath!, to: newIndexPath!)
        case .update: reload(at: indexPath!)
        default: break
        }
    }

    func controller(_ controller: DataSourceContainerController, didChangeSectionAt sectionIndex: UInt, for type: NSFetchedResultsChangeType) {
        guard controller === container else { return }

        switch type {
        case .insert: insertSection(at: sectionIndex)
        case .delete: removeSection(at: sectionIndex)
        case .update: reloadSection(at: sectionIndex)
        default: break
        }
    }

    func controllerDidChangeContent(_ controller: DataSourceContainerController) {
        guard controller === container else { return }
        endUpdating()
    }
}
