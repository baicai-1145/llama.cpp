import Foundation

struct Model: Identifiable {
    var id: String { filename }
    var name: String
    var url: String
    var filename: String
    var status: String?
}

enum ModelDownloadSource: String, CaseIterable, Identifiable {
    case modelscope
    case huggingFace
    case hfMirror

    var id: String { rawValue }

    var title: String {
        switch self {
        case .modelscope:
            return "ModelScope"
        case .huggingFace:
            return "Hugging Face"
        case .hfMirror:
            return "HF Mirror"
        }
    }

    func downloadURL(for variant: HyMT2ModelVariant) -> String? {
        switch self {
        case .modelscope:
            return variant.modelScopeDownloadURL
        case .huggingFace:
            return variant.huggingFaceDownloadURL
        case .hfMirror:
            return variant.hfMirrorDownloadURL
        }
    }
}

enum HyMT2ModelVariant: String, CaseIterable, Identifiable {
    case onePoint25Bit
    case twoBit
    case q4KM
    case q6K
    case q8_0

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .onePoint25Bit:
            return "Hy-MT2-1.8B 1.25Bit (0.44 GiB)"
        case .twoBit:
            return "Hy-MT2-1.8B 2Bit (0.56 GiB)"
        case .q4KM:
            return "Hy-MT2-1.8B Q4_K_M (1.13 GB)"
        case .q6K:
            return "Hy-MT2-1.8B Q6_K (1.47 GB)"
        case .q8_0:
            return "Hy-MT2-1.8B Q8_0 (1.91 GB)"
        }
    }

    var filename: String {
        switch self {
        case .onePoint25Bit:
            return "Hy-MT2-1.8B-1.25Bit.gguf"
        case .twoBit:
            return "Hy-MT2-1.8B-2Bit.gguf"
        case .q4KM:
            return "Hy-MT2-1.8B-Q4_K_M.gguf"
        case .q6K:
            return "Hy-MT2-1.8B-Q6_K.gguf"
        case .q8_0:
            return "Hy-MT2-1.8B-Q8_0.gguf"
        }
    }

    var huggingFaceDownloadURL: String {
        switch self {
        case .onePoint25Bit:
            return "https://huggingface.co/tencent/Hy-MT2-1.8B-1.25Bit-GGUF/resolve/main/Hy-MT2-1.8B-1.25Bit.gguf?download=true"
        case .twoBit:
            return "https://huggingface.co/tencent/Hy-MT2-1.8B-2Bit-GGUF/resolve/main/Hy-MT2-1.8B-2Bit.gguf?download=true"
        case .q4KM:
            return "https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf?download=true"
        case .q6K:
            return "https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q6_K.gguf?download=true"
        case .q8_0:
            return "https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q8_0.gguf?download=true"
        }
    }

    var hfMirrorDownloadURL: String {
        huggingFaceDownloadURL.replacingOccurrences(
            of: "https://huggingface.co/",
            with: "https://hf-mirror.com/"
        )
    }

    var modelScopeDownloadURL: String? {
        switch self {
        case .onePoint25Bit:
            return "https://www.modelscope.cn/models/AngelSlim/Hy-MT2-1.8B-1.25Bit-GGUF/resolve/master/Hy-MT2-1.8B-1.25Bit.gguf"
        case .twoBit:
            return "https://www.modelscope.cn/models/AngelSlim/Hy-MT2-1.8B-2Bit-GGUF/resolve/master/Hy-MT2-1.8B-2Bit.gguf"
        case .q4KM, .q6K, .q8_0:
            return nil
        }
    }
}

enum KVCacheType: String, CaseIterable, Identifiable {
    case f16
    case q8_0

    var id: String { rawValue }

    var title: String {
        switch self {
        case .f16:
            return "F16"
        case .q8_0:
            return "Q8_0"
        }
    }

    var detail: String {
        switch self {
        case .f16:
            return "默认，质量和兼容性最稳"
        case .q8_0:
            return "降低 KV cache 内存占用，需实测速度和质量"
        }
    }

}

struct TranslationLanguage: Identifiable, Hashable {
    let code: String
    let englishName: String
    let chineseName: String

    var id: String { code }
    var promptName: String { englishName }
    var shortDisplayName: String { chineseName }
    var displayName: String { "\(chineseName) / \(englishName)" }

    static let auto = TranslationLanguage(code: "auto", englishName: "auto-detected language", chineseName: "自动")
    static let chinese = TranslationLanguage(code: "zh", englishName: "Chinese", chineseName: "中文")
    static let english = TranslationLanguage(code: "en", englishName: "English", chineseName: "英语")
}

struct TranslationHistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let sourceText: String
    let translationText: String
    let sourceLanguageCode: String
    let targetLanguageCode: String
    let sourceLanguageName: String
    let targetLanguageName: String
    let taskRawValue: String
    let taskTitle: String
    let taskDetailText: String?

    var languageSummary: String {
        "\(sourceLanguageName) -> \(targetLanguageName)"
    }
}

enum TranslationTaskKind: String, CaseIterable, Identifiable {
    case standard
    case terminology
    case style
    case personalization
    case delimiters
    case structuredData
    case background

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard:
            return "默认翻译"
        case .terminology:
            return "术语参考"
        case .style:
            return "指定风格"
        case .personalization:
            return "个性偏好"
        case .delimiters:
            return "保留分隔符"
        case .structuredData:
            return "结构化数据"
        case .background:
            return "结合背景"
        }
    }

    var englishTitle: String {
        switch self {
        case .standard:
            return "Default"
        case .terminology:
            return "Terminology"
        case .style:
            return "Style"
        case .personalization:
            return "Personalization"
        case .delimiters:
            return "Delimiters"
        case .structuredData:
            return "Structured"
        case .background:
            return "Background"
        }
    }

    var iconName: String {
        switch self {
        case .standard:
            return "textformat"
        case .terminology:
            return "book.closed"
        case .style:
            return "paintbrush"
        case .personalization:
            return "person.crop.circle"
        case .delimiters:
            return "curlybraces"
        case .structuredData:
            return "list.bullet.rectangle"
        case .background:
            return "doc.text.magnifyingglass"
        }
    }

    var detailLabel: String {
        switch self {
        case .standard:
            return "无需额外设置"
        case .terminology:
            return "术语表"
        case .style:
            return "目标风格"
        case .personalization:
            return "翻译偏好"
        case .delimiters:
            return "分隔符约束"
        case .structuredData:
            return "数据格式"
        case .background:
            return "背景信息"
        }
    }

    var defaultDetail: String {
        switch self {
        case .standard:
            return ""
        case .terminology:
            return """
            Apple Vision Pro translates to Apple Vision Pro
            Home Screen translates to 主屏幕
            Spatial Video translates to 空间视频
            """
        case .style:
            return "natural, concise, and suitable for a mobile app interface"
        case .personalization:
            return """
            Use natural wording for native speakers.
            Keep product names unchanged.
            Keep numbers, dates, and units accurate.
            """
        case .delimiters:
            return "Keep all separators such as |, /, {}, [], <tag>, and line breaks in the same count and position."
        case .structuredData:
            return "JSON"
        case .background:
            return "The text is from an iOS app that runs Hy-MT2 locally on a phone."
        }
    }

    var sampleText: String {
        switch self {
        case .standard:
            return "The quick brown fox jumps over the lazy dog."
        case .terminology:
            return "Open Spatial Video from the Home Screen on Apple Vision Pro."
        case .style:
            return "Tap Send to translate the selected text on your device."
        case .personalization:
            return "Hy-MT2 keeps translation fast and private on iPhone."
        case .delimiters:
            return "Name | Status | Notes\nHy-MT2 | Ready | CPU/STQ"
        case .structuredData:
            return """
            {
              "title": "Translate locally",
              "button": "Send",
              "status": "Ready"
            }
            """
        case .background:
            return "The model can translate short product copy without sending text to a server."
        }
    }
}

@MainActor
class LlamaState: ObservableObject {
    @Published var messageLog = ""
    @Published var translationOutput = ""
    @Published var lastSourceText = ""
    @Published var cacheCleared = false
    @Published var downloadedModels: [Model] = []
    @Published var undownloadedModels: [Model] = []
    @Published var selectedSourceLanguage = TranslationLanguage.english
    @Published var selectedTargetLanguage = TranslationLanguage.chinese
    @Published var selectedTask = TranslationTaskKind.standard
    @Published var taskDetailText = TranslationTaskKind.standard.defaultDetail
    @Published var isGenerating = false
    @Published var isLoadingModel = false
    @Published var loadingModelName = ""
    @Published var loadedModelName = "未加载模型"
    @Published var selectedModelDownloadSource = ModelDownloadSource.modelscope
    @Published var selectedKVCacheType = KVCacheType.f16
    @Published var hasBundledHyMT2Model = false
    @Published var downloadCacheMessage = ""
    @Published private(set) var translationHistory: [TranslationHistoryItem] = []
    let NS_PER_S = 1_000_000_000.0
    let sourceLanguages: [TranslationLanguage] = [.auto] + LlamaState.supportedLanguages
    let targetLanguages = LlamaState.supportedLanguages
    let translationTasks = TranslationTaskKind.allCases
    let modelDownloadSources = ModelDownloadSource.allCases
    let hyMT2ModelVariants = HyMT2ModelVariant.allCases
    let kvCacheTypes = KVCacheType.allCases

    static let hyMT2ModelName = "Hy-MT2-1.8B (1.25Bit, 0.44 GiB)"
    static let hyMT2ModelFilename = "Hy-MT2-1.8B-1.25Bit.gguf"
    private static let kvCacheTypeStorageKey = "hyMT2KVCacheType"
    private static let translationHistoryStorageKey = "hyMT2TranslationHistory"
    private static let translationHistoryLimit = 50

    var hyMT2DownloadModels: [Model] {
        hyMT2ModelVariants.compactMap { downloadModel(for: $0) }
    }

    var downloadedHyMT2ModelVariants: [HyMT2ModelVariant] {
        hyMT2ModelVariants.filter { variant in
            FileManager.default.fileExists(atPath: documentsModelUrl(for: variant).path)
        }
    }

    var downloadedHyMT2ModelSummary: String {
        downloadedHyMT2ModelVariants.map(\.displayName).joined(separator: "\n")
    }

    var modelDownloadSourceNote: String {
        switch selectedModelDownloadSource {
        case .modelscope:
            return "ModelScope 提供 1.25Bit 和 2Bit 镜像；Q4、Q6、Q8 请切换到 Hugging Face。"
        case .huggingFace:
            return "Hugging Face 提供 1.25Bit、2Bit、Q4_K_M、Q6_K、Q8_0。"
        case .hfMirror:
            return "HF Mirror 使用 hf-mirror.com，提供与 Hugging Face 相同的 1.25Bit、2Bit、Q4、Q6、Q8 下载。"
        }
    }

    var hasDownloadedHyMT2Model: Bool {
        !downloadedHyMT2ModelVariants.isEmpty
    }

    private var llamaContext: LlamaContext?
    private var defaultModelUrl: URL? {
        Bundle.main.url(forResource: "Hy-MT2-1.8B-1.25Bit", withExtension: "gguf", subdirectory: "models")
    }
    private var documentsHyMT2ModelUrl: URL {
        getDocumentsDirectory().appendingPathComponent(Self.hyMT2ModelFilename)
    }

    init() {
        clearDownloadCache(report: false)
        loadKVCacheTypeSetting()
        loadTranslationHistory()
        loadModelsFromDisk()
        loadDefaultModels()
    }

    private func loadModelsFromDisk() {
        do {
            let documentsURL = getDocumentsDirectory()
            let modelURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for modelURL in modelURLs {
                guard let variant = hyMT2ModelVariant(filename: modelURL.lastPathComponent) else {
                    continue
                }
                downloadedModels.append(Model(name: variant.displayName, url: "", filename: modelURL.lastPathComponent, status: "downloaded"))
            }
        } catch {
            print("Error loading models from disk: \(error)")
        }
    }

    private func loadDefaultModels() {
        hasBundledHyMT2Model = defaultModelUrl != nil

        let startupModelUrl: URL?
        if let defaultModelUrl {
            startupModelUrl = defaultModelUrl
        } else if FileManager.default.fileExists(atPath: documentsHyMT2ModelUrl.path) {
            startupModelUrl = documentsHyMT2ModelUrl
        } else {
            startupModelUrl = nil
        }

        if let startupModelUrl {
            loadModelAsync(modelUrl: startupModelUrl)
        } else {
            loadedModelName = "未加载模型"
            messageLog += "Load a model from the list below\n"
        }

        undownloadedModels = []
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @discardableResult
    func clearDownloadCache(report: Bool = true) -> Int64 {
        let tmpURL = FileManager.default.temporaryDirectory
        var removedBytes: Int64 = 0

        do {
            let temporaryFiles = try FileManager.default.contentsOfDirectory(
                at: tmpURL,
                includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
                options: [.skipsHiddenFiles]
            )

            for fileURL in temporaryFiles where fileURL.lastPathComponent.hasPrefix("CFNetworkDownload_") {
                let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                guard values.isRegularFile == true else {
                    continue
                }
                removedBytes += Int64(values.fileSize ?? 0)
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            if report {
                downloadCacheMessage = "清理下载缓存失败：\(error.localizedDescription)"
                messageLog += "\(downloadCacheMessage)\n"
            }
            return removedBytes
        }

        if report {
            let size = Self.formatBytes(removedBytes)
            downloadCacheMessage = removedBytes > 0 ? "已清理下载缓存 \(size)" : "没有可清理的下载缓存"
            messageLog += "\(downloadCacheMessage)\n"
        }

        return removedBytes
    }

    static func formatBytes(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(bytes)
        var unitIndex = 0

        while size >= 1024, unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(Int(size)) \(units[unitIndex])"
        }
        return String(format: "%.1f %@", size, units[unitIndex])
    }

    func downloadModel(for variant: HyMT2ModelVariant) -> Model? {
        let isDownloaded = FileManager.default.fileExists(atPath: documentsModelUrl(for: variant).path)
        guard let url = selectedModelDownloadSource.downloadURL(for: variant) else {
            if isDownloaded {
                return Model(
                    name: variant.displayName,
                    url: "",
                    filename: variant.filename,
                    status: "downloaded"
                )
            }
            return nil
        }

        return Model(
            name: isDownloaded ? variant.displayName : "\(variant.displayName) - \(selectedModelDownloadSource.title)",
            url: url,
            filename: variant.filename,
            status: isDownloaded ? "downloaded" : "download"
        )
    }

    func displayName(for filename: String) -> String {
        hyMT2ModelVariant(filename: filename)?.displayName ?? filename
    }

    private func documentsModelUrl(for variant: HyMT2ModelVariant) -> URL {
        getDocumentsDirectory().appendingPathComponent(variant.filename)
    }

    private func hyMT2ModelVariant(filename: String) -> HyMT2ModelVariant? {
        hyMT2ModelVariants.first { $0.filename == filename }
    }

    func setKVCacheType(_ type: KVCacheType) {
        selectedKVCacheType = type
        UserDefaults.standard.set(type.rawValue, forKey: Self.kvCacheTypeStorageKey)
        messageLog += "KV cache type set to \(type.title). Reload model to apply.\n"
    }

    private func loadKVCacheTypeSetting() {
        guard let rawValue = UserDefaults.standard.string(forKey: Self.kvCacheTypeStorageKey),
              let type = KVCacheType(rawValue: rawValue) else {
            selectedKVCacheType = .f16
            return
        }
        selectedKVCacheType = type
    }

    private static let supportedLanguages: [TranslationLanguage] = [
        .chinese,
        .english,
        TranslationLanguage(code: "fr", englishName: "French", chineseName: "法语"),
        TranslationLanguage(code: "pt", englishName: "Portuguese", chineseName: "葡萄牙语"),
        TranslationLanguage(code: "es", englishName: "Spanish", chineseName: "西班牙语"),
        TranslationLanguage(code: "ja", englishName: "Japanese", chineseName: "日语"),
        TranslationLanguage(code: "tr", englishName: "Turkish", chineseName: "土耳其语"),
        TranslationLanguage(code: "ru", englishName: "Russian", chineseName: "俄语"),
        TranslationLanguage(code: "ar", englishName: "Arabic", chineseName: "阿拉伯语"),
        TranslationLanguage(code: "ko", englishName: "Korean", chineseName: "韩语"),
        TranslationLanguage(code: "th", englishName: "Thai", chineseName: "泰语"),
        TranslationLanguage(code: "it", englishName: "Italian", chineseName: "意大利语"),
        TranslationLanguage(code: "de", englishName: "German", chineseName: "德语"),
        TranslationLanguage(code: "vi", englishName: "Vietnamese", chineseName: "越南语"),
        TranslationLanguage(code: "ms", englishName: "Malay", chineseName: "马来语"),
        TranslationLanguage(code: "id", englishName: "Indonesian", chineseName: "印尼语"),
        TranslationLanguage(code: "tl", englishName: "Filipino", chineseName: "菲律宾语"),
        TranslationLanguage(code: "hi", englishName: "Hindi", chineseName: "印地语"),
        TranslationLanguage(code: "zh-Hant", englishName: "Traditional Chinese", chineseName: "繁体中文"),
        TranslationLanguage(code: "pl", englishName: "Polish", chineseName: "波兰语"),
        TranslationLanguage(code: "cs", englishName: "Czech", chineseName: "捷克语"),
        TranslationLanguage(code: "nl", englishName: "Dutch", chineseName: "荷兰语"),
        TranslationLanguage(code: "km", englishName: "Khmer", chineseName: "高棉语"),
        TranslationLanguage(code: "my", englishName: "Burmese", chineseName: "缅甸语"),
        TranslationLanguage(code: "fa", englishName: "Persian", chineseName: "波斯语"),
        TranslationLanguage(code: "gu", englishName: "Gujarati", chineseName: "古吉拉特语"),
        TranslationLanguage(code: "ur", englishName: "Urdu", chineseName: "乌尔都语"),
        TranslationLanguage(code: "te", englishName: "Telugu", chineseName: "泰卢固语"),
        TranslationLanguage(code: "mr", englishName: "Marathi", chineseName: "马拉地语"),
        TranslationLanguage(code: "he", englishName: "Hebrew", chineseName: "希伯来语"),
        TranslationLanguage(code: "bn", englishName: "Bengali", chineseName: "孟加拉语"),
        TranslationLanguage(code: "ta", englishName: "Tamil", chineseName: "泰米尔语"),
        TranslationLanguage(code: "uk", englishName: "Ukrainian", chineseName: "乌克兰语"),
        TranslationLanguage(code: "bo", englishName: "Tibetan", chineseName: "藏语"),
        TranslationLanguage(code: "kk", englishName: "Kazakh", chineseName: "哈萨克语"),
        TranslationLanguage(code: "mn", englishName: "Mongolian", chineseName: "蒙古语"),
        TranslationLanguage(code: "ug", englishName: "Uyghur", chineseName: "维吾尔语"),
        TranslationLanguage(code: "yue", englishName: "Cantonese", chineseName: "粤语")
    ]

    func loadModel(modelUrl: URL?) throws {
        if let modelUrl {
            messageLog += "Loading model...\n"
            let context = try LlamaContext.create_context(path: modelUrl.path(), kvCacheType: selectedKVCacheType)
            finishLoadingModel(context: context, modelUrl: modelUrl)
        } else {
            loadedModelName = "未加载模型"
            messageLog += "Load a model from the list below\n"
        }
    }

    func loadModelAsync(modelUrl: URL?) {
        guard !isLoadingModel else {
            return
        }

        guard let modelUrl else {
            do {
                try loadModel(modelUrl: nil)
            } catch {
                messageLog += "Error: \(error.localizedDescription)\n"
            }
            return
        }

        let kvCacheType = selectedKVCacheType
        isLoadingModel = true
        loadingModelName = modelUrl.lastPathComponent
        messageLog += "Loading model...\n"

        Task {
            do {
                let context = try await Task.detached(priority: .userInitiated) {
                    try LlamaContext.create_context(path: modelUrl.path(), kvCacheType: kvCacheType)
                }.value

                await MainActor.run {
                    finishLoadingModel(context: context, modelUrl: modelUrl)
                    isLoadingModel = false
                    loadingModelName = ""
                }
            } catch {
                await MainActor.run {
                    messageLog += "Load model failed: \(error.localizedDescription)\n"
                    isLoadingModel = false
                    loadingModelName = ""
                }
            }
        }
    }

    private func finishLoadingModel(context: LlamaContext, modelUrl: URL) {
        llamaContext = context
        loadedModelName = modelUrl.lastPathComponent
        messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
        messageLog += "KV cache: \(selectedKVCacheType.title)\n"
        updateDownloadedModels(modelName: modelUrl.lastPathComponent, status: "downloaded")
    }


    private func updateDownloadedModels(modelName: String, status: String) {
        undownloadedModels.removeAll { $0.name == modelName }
    }


    func complete(text: String) async {
        guard let llamaContext else {
            messageLog += "No model loaded. Open Models and load a GGUF file first.\n"
            return
        }
        guard !isGenerating else {
            return
        }

        let sourceText = normalizedSourceText(text)
        let prompt = hyMT2Prompt(for: sourceText)
        let t_start = DispatchTime.now().uptimeNanoseconds
        isGenerating = true
        lastSourceText = sourceText
        translationOutput = ""
        await llamaContext.completion_init(text: prompt)
        let t_heat_end = DispatchTime.now().uptimeNanoseconds
        let t_heat = Double(t_heat_end - t_start) / NS_PER_S

        messageLog += """
        \n[\(selectedTask.englishTitle)] \(selectedSourceLanguage.shortDisplayName) -> \(selectedTargetLanguage.shortDisplayName)
        Source characters: \(sourceText.count)
        Heat up took \(t_heat)s
        """

        while await !llamaContext.is_done {
            let result = await llamaContext.completion_loop()
            translationOutput += "\(result)"
        }

        let t_end = DispatchTime.now().uptimeNanoseconds
        let t_generation = Double(t_end - t_heat_end) / NS_PER_S
        let decodedTokens = await llamaContext.n_decode
        let tokens_per_second = Double(decodedTokens) / max(t_generation, 0.001)

        await llamaContext.clear()

        messageLog += """
        Done
        Decoded \(decodedTokens) tokens at \(tokens_per_second) t/s\n
        """
        saveHistoryItem(sourceText: sourceText, translationText: translationOutput)
        isGenerating = false
    }

    func applyTask(_ task: TranslationTaskKind) {
        selectedTask = task
        taskDetailText = task.defaultDetail
    }

    func swapLanguages() {
        if selectedSourceLanguage == .auto {
            selectedSourceLanguage = selectedTargetLanguage
            selectedTargetLanguage = .english
        } else {
            let oldSource = selectedSourceLanguage
            selectedSourceLanguage = selectedTargetLanguage
            selectedTargetLanguage = oldSource
        }
    }

    func promptPreview(for text: String) -> String {
        hyMT2Prompt(for: normalizedSourceText(text))
    }

    private func hyMT2Prompt(for text: String) -> String {
        let instruction = instructionText(for: text)
        return "<\u{FF5C}hy_begin\u{2581}of\u{2581}sentence\u{FF5C}><\u{FF5C}hy_User\u{FF5C}>\(instruction)<\u{FF5C}hy_Assistant\u{FF5C}>"
    }

    private func instructionText(for text: String) -> String {
        let target = selectedTargetLanguage.promptName
        let sourcePhrase = selectedSourceLanguage == .auto ? "" : " from \(selectedSourceLanguage.promptName)"
        let trimmedDetail = taskDetailText.trimmingCharacters(in: .whitespacesAndNewlines)

        switch selectedTask {
        case .standard:
            return """
            Translate the following text\(sourcePhrase) into \(target). Note that you should only output the translated result without any additional explanation:

            \(text)
            """
        case .terminology:
            let terms = trimmedDetail.isEmpty ? TranslationTaskKind.terminology.defaultDetail : trimmedDetail
            return """
            Reference the following translations:
            \(terms)
            Translate the following text\(sourcePhrase) into \(target). Note that you must ONLY output the translated result without any additional explanation:

            \(text)
            """
        case .style:
            let style = trimmedDetail.isEmpty ? TranslationTaskKind.style.defaultDetail : trimmedDetail
            return """
            Please translate the following text\(sourcePhrase) into \(target). Note that the translation style must strictly conform to [\(style)]:

            \(text)
            """
        case .personalization:
            let preferences = numberedLines(from: trimmedDetail.isEmpty ? TranslationTaskKind.personalization.defaultDetail : trimmedDetail)
            let preferenceText = preferences.joined(separator: "\n")
            return """
            [Source Text]
            \(text)

            [Translation Tasks]
            \(preferenceText)
            \(preferences.count + 1). Translate the [Source Text]\(sourcePhrase) into \(target).
            """
        case .delimiters:
            return """
            Please accurately translate the following text\(sourcePhrase) into \(target).
            You must retain the exact same number of delimiters in the translation. Strictly do not omit, escape, or translate these symbols, and pay close attention to their placement.

            \(text)
            """
        case .structuredData:
            let formatType = trimmedDetail.isEmpty ? TranslationTaskKind.structuredData.defaultDetail : trimmedDetail
            return """
            ### Task
            Translate the user-facing text within the following \(formatType) data\(sourcePhrase) into \(target).
            ### Strict Rules
            1. Structure Preservation: You MUST preserve the original \(formatType) data structure, nesting, hierarchy, and indentation exactly as they are.
            2. Selective Translation: Translate ONLY the visible, user-facing text content/values.
            3. Strict Non-Translation: NEVER translate or alter code tags, keys, properties, object names, or variable placeholders. Leave them exactly in their original English/code form.
            ### Source Data
            \(text)
            """
        case .background:
            let background = trimmedDetail.isEmpty ? TranslationTaskKind.background.defaultDetail : trimmedDetail
            return """
            [Background Information]
            \(background)

            Please translate the following text\(sourcePhrase) into \(target), taking the provided background information into consideration.

            [Source Text]
            \(text)
            """
        }
    }

    private func normalizedSourceText(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.isEmpty ? selectedTask.sampleText : trimmedText
    }

    private func numberedLines(from text: String) -> [String] {
        text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
    }

    func restoreHistoryItem(_ item: TranslationHistoryItem) {
        if let sourceLanguage = language(for: item.sourceLanguageCode, includeAuto: true) {
            selectedSourceLanguage = sourceLanguage
        }
        if let targetLanguage = language(for: item.targetLanguageCode, includeAuto: false) {
            selectedTargetLanguage = targetLanguage
        }
        if let task = TranslationTaskKind(rawValue: item.taskRawValue) {
            selectedTask = task
            taskDetailText = item.taskDetailText ?? task.defaultDetail
        }

        lastSourceText = item.sourceText
        translationOutput = item.translationText
    }

    func deleteHistoryItems(at offsets: IndexSet) {
        translationHistory.remove(atOffsets: offsets)
        persistTranslationHistory()
    }

    func clearTranslationHistory() {
        translationHistory = []
        UserDefaults.standard.removeObject(forKey: Self.translationHistoryStorageKey)
    }

    private func saveHistoryItem(sourceText: String, translationText: String) {
        let trimmedTranslation = translationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !trimmedTranslation.isEmpty else {
            return
        }

        let item = TranslationHistoryItem(
            id: UUID(),
            createdAt: Date(),
            sourceText: sourceText,
            translationText: trimmedTranslation,
            sourceLanguageCode: selectedSourceLanguage.code,
            targetLanguageCode: selectedTargetLanguage.code,
            sourceLanguageName: selectedSourceLanguage.shortDisplayName,
            targetLanguageName: selectedTargetLanguage.shortDisplayName,
            taskRawValue: selectedTask.rawValue,
            taskTitle: selectedTask.title,
            taskDetailText: taskDetailText
        )

        translationHistory.removeAll {
            $0.sourceText == item.sourceText &&
            $0.translationText == item.translationText &&
            $0.sourceLanguageCode == item.sourceLanguageCode &&
            $0.targetLanguageCode == item.targetLanguageCode &&
            $0.taskRawValue == item.taskRawValue
        }
        translationHistory.insert(item, at: 0)
        if translationHistory.count > Self.translationHistoryLimit {
            translationHistory.removeLast(translationHistory.count - Self.translationHistoryLimit)
        }
        persistTranslationHistory()
    }

    private func loadTranslationHistory() {
        guard let data = UserDefaults.standard.data(forKey: Self.translationHistoryStorageKey) else {
            return
        }

        do {
            translationHistory = try JSONDecoder().decode([TranslationHistoryItem].self, from: data)
        } catch {
            translationHistory = []
            UserDefaults.standard.removeObject(forKey: Self.translationHistoryStorageKey)
        }
    }

    private func persistTranslationHistory() {
        do {
            let data = try JSONEncoder().encode(translationHistory)
            UserDefaults.standard.set(data, forKey: Self.translationHistoryStorageKey)
        } catch {
            messageLog += "Failed to save translation history.\n"
        }
    }

    private func language(for code: String, includeAuto: Bool) -> TranslationLanguage? {
        let languages = includeAuto ? sourceLanguages : targetLanguages
        return languages.first { $0.code == code }
    }

    func bench() async {
        guard let llamaContext else {
            return
        }
        guard !isGenerating else {
            return
        }

        isGenerating = true
        defer { isGenerating = false }
        messageLog += "\n"
        messageLog += "Running benchmark...\n"
        messageLog += "Model info: "
        messageLog += await llamaContext.model_info() + "\n"

        let t_start = DispatchTime.now().uptimeNanoseconds
        let _ = await llamaContext.bench(pp: 8, tg: 4, pl: 1) // heat up
        let t_end = DispatchTime.now().uptimeNanoseconds

        let t_heat = Double(t_end - t_start) / NS_PER_S
        messageLog += "Heat up time: \(t_heat) seconds, please wait...\n"

        // if more than 5 seconds, then we're probably running on a slow device
        if t_heat > 5.0 {
            messageLog += "Heat up time is too long, aborting benchmark\n"
            return
        }

        let result = await llamaContext.bench(pp: 512, tg: 128, pl: 1, nr: 3)

        messageLog += "\(result)"
        messageLog += "\n"
    }

    func clear() async {
        guard let llamaContext else {
            messageLog = ""
            translationOutput = ""
            lastSourceText = ""
            return
        }

        await llamaContext.clear()
        messageLog = ""
        translationOutput = ""
        lastSourceText = ""
    }
}
