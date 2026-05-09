#if os(macOS)
import Foundation

final class FolderMonitor {
    private let url: URL
    private let callback: () -> Void
    private var descriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?

    init(url: URL, callback: @escaping () -> Void) {
        self.url = url
        self.callback = callback
    }

    func start() {
        guard source == nil else { return }

        let openedDescriptor = open(url.path, O_EVTONLY)
        guard openedDescriptor >= 0 else { return }
        descriptor = openedDescriptor

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: openedDescriptor,
            eventMask: [.write, .delete, .rename, .attrib],
            queue: DispatchQueue.global(qos: .utility)
        )

        source.setEventHandler(handler: callback)
        source.setCancelHandler { [openedDescriptor] in
            close(openedDescriptor)
        }

        self.source = source
        source.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
        descriptor = -1
    }
}
#endif
