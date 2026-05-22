import SwiftUI

struct DownloadButton: View {
    @ObservedObject private var llamaState: LlamaState
    private var modelName: String
    private var modelUrl: String
    private var filename: String
    private var deleteAction: (() -> Void)?

    @State private var status: String

    @State private var downloadTask: URLSessionDownloadTask?
    @State private var progress = 0.0
    @State private var downloadSpeedText = "0.0 MB/s"
    @State private var speedTimer: Timer?
    @State private var lastSpeedSampleBytes: Int64 = 0
    @State private var lastSpeedSampleAt: Date?

    private static func getFileURL(filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    }

    private func checkFileExistenceAndUpdateStatus() {
    }

    init(llamaState: LlamaState, modelName: String, modelUrl: String, filename: String, deleteAction: (() -> Void)? = nil) {
        self.llamaState = llamaState
        self.modelName = modelName
        self.modelUrl = modelUrl
        self.filename = filename
        self.deleteAction = deleteAction

        let fileURL = DownloadButton.getFileURL(filename: filename)
        status = FileManager.default.fileExists(atPath: fileURL.path) ? "downloaded" : (modelUrl.isEmpty ? "missing" : "download")
    }

    private func download() {
        llamaState.clearDownloadCache(report: false)
        status = "downloading"
        progress = 0
        downloadSpeedText = "0.0 MB/s"
        lastSpeedSampleBytes = 0
        lastSpeedSampleAt = Date()
        stopSpeedTimer()
        print("Downloading model \(modelName) from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        let fileURL = DownloadButton.getFileURL(filename: filename)

        downloadTask = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                Task { @MainActor in
                    stopSpeedTimer()
                    status = "download"
                    llamaState.clearDownloadCache(report: true)
                }
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                Task { @MainActor in
                    stopSpeedTimer()
                    status = "download"
                    llamaState.clearDownloadCache(report: true)
                }
                return
            }

            do {
                if let temporaryURL = temporaryURL {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    try FileManager.default.copyItem(at: temporaryURL, to: fileURL)
                    print("Writing to \(filename) completed")

                    Task { @MainActor in
                        llamaState.cacheCleared = false
                        let model = Model(name: llamaState.displayName(for: filename), url: modelUrl, filename: filename, status: "downloaded")
                        llamaState.downloadedModels.removeAll { $0.filename == filename }
                        llamaState.downloadedModels.append(model)
                        stopSpeedTimer()
                        status = "downloaded"
                        llamaState.clearDownloadCache(report: false)
                    }
                }
            } catch let err {
                print("Error: \(err.localizedDescription)")
                Task { @MainActor in
                    stopSpeedTimer()
                    status = "download"
                    llamaState.clearDownloadCache(report: true)
                }
            }
        }

        downloadTask?.resume()
        startSpeedTimer()
    }

    private func startSpeedTimer() {
        speedTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let downloadTask else {
                return
            }

            let now = Date()
            let receivedBytes = downloadTask.countOfBytesReceived
            let lastAt = lastSpeedSampleAt ?? now
            let elapsed = max(now.timeIntervalSince(lastAt), 0.001)
            let bytesDelta = max(0, receivedBytes - lastSpeedSampleBytes)
            let speed = Double(bytesDelta) / 1_048_576.0 / elapsed

            lastSpeedSampleBytes = receivedBytes
            lastSpeedSampleAt = now
            downloadSpeedText = String(format: "%.1f MB/s", speed)

            let expectedBytes = downloadTask.countOfBytesExpectedToReceive
            if expectedBytes > 0 {
                let currentProgress = min(1, Double(receivedBytes) / Double(expectedBytes))
                progress = max(progress, currentProgress)
            }
        }
    }

    private func stopSpeedTimer() {
        speedTimer?.invalidate()
        speedTimer = nil
    }

    var body: some View {
        VStack {
            if status == "download" {
                Button(action: download) {
                    Text("Download " + modelName)
                }
            } else if status == "downloading" {
                Button(action: {
                    downloadTask?.cancel()
                    stopSpeedTimer()
                    status = "download"
                    llamaState.clearDownloadCache(report: true)
                }) {
                    Text("\(modelName) \(Int(progress * 100))% · \(downloadSpeedText)")
                }
            } else if status == "downloaded" {
                HStack(spacing: 8) {
                    Button(action: {
                        let fileURL = DownloadButton.getFileURL(filename: filename)
                        if !FileManager.default.fileExists(atPath: fileURL.path) {
                            status = modelUrl.isEmpty ? "missing" : "download"
                            return
                        }
                        llamaState.loadModelAsync(modelUrl: fileURL)
                    }) {
                        if llamaState.isLoadingModel && llamaState.loadingModelName == filename {
                            HStack {
                                ProgressView()
                                Text("Loading \(modelName)")
                            }
                        } else {
                            Text("Load \(modelName)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .disabled(llamaState.isLoadingModel)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let deleteAction {
                        Button(role: .destructive) {
                            deleteAction()
                            status = modelUrl.isEmpty ? "missing" : "download"
                        } label: {
                            Label("删除模型", systemImage: "trash")
                                .labelStyle(.iconOnly)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else if status == "missing" {
                Text("\(modelName) 文件不存在")
                    .foregroundStyle(.secondary)
            } else {
                Text("Unknown status")
            }
        }
        .onDisappear() {
            downloadTask?.cancel()
            stopSpeedTimer()
            if status == "downloading" {
                llamaState.clearDownloadCache(report: false)
            }
        }
        .onChange(of: llamaState.cacheCleared) { newValue in
            if newValue {
                downloadTask?.cancel()
                stopSpeedTimer()
                let fileURL = DownloadButton.getFileURL(filename: filename)
                status = FileManager.default.fileExists(atPath: fileURL.path) ? "downloaded" : "download"
            }
        }
    }
}
