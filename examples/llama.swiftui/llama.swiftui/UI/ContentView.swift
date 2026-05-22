import SwiftUI

struct ContentView: View {
    @StateObject private var llamaState = LlamaState()
    @State private var inputText = ""
    @State private var showsLog = false
    @State private var showsTaskDetails = false
    @State private var showingHistory = false
    @State private var showingInferenceSettings = false
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    statusHeader
                    languagePanel
                    taskPanel
                    inputPanel
                    outputPanel
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Hy-MT2")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Appearance", selection: $appearanceModeRawValue) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Label(mode.title, systemImage: mode.iconName).tag(mode.rawValue)
                            }
                        }
                    } label: {
                        Label(appearanceMode.title, systemImage: appearanceMode.iconName)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingInferenceSettings = true
                    } label: {
                        Label("Inference", systemImage: "slider.horizontal.3")
                    }

                    Button {
                        showingHistory = true
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }

                    NavigationLink(destination: DrawerView(llamaState: llamaState)) {
                        Label("Models", systemImage: "shippingbox")
                    }
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(
                llamaState: llamaState,
                inputText: $inputText,
                isPresented: $showingHistory
            )
        }
        .sheet(isPresented: $showingInferenceSettings) {
            InferenceSettingsView(
                llamaState: llamaState,
                isPresented: $showingInferenceSettings
            )
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("本机翻译")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                    Text(llamaState.loadedModelName)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer(minLength: 12)

                StatusPill(isGenerating: llamaState.isGenerating)
            }

            HStack(spacing: 8) {
                InfoToken(icon: "cpu", title: "CPU", value: "STQ")
                InfoToken(icon: "memorychip", title: "Ctx", value: "\(LlamaContext.configuredContextSize)")
                Button {
                    showingInferenceSettings = true
                } label: {
                    InfoToken(icon: "tray.2", title: "KV", value: llamaState.selectedKVCacheType.title)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var languagePanel: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "globe.asia.australia")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 24, height: 24)

            CompactLanguagePicker(
                title: "源语言",
                selection: $llamaState.selectedSourceLanguage,
                languages: llamaState.sourceLanguages
            )

            Button {
                llamaState.swapLanguages()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.accent)
            .background(AppTheme.controlBackground, in: Circle())
            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))

            CompactLanguagePicker(
                title: "目标语言",
                selection: $llamaState.selectedTargetLanguage,
                languages: llamaState.targetLanguages
            )
        }
        .padding(8)
        .background(AppTheme.panelBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var taskPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionTitle(icon: "sparkles", title: "Instruction Examples")
                Spacer()
                Button {
                    inputText = llamaState.selectedTask.sampleText
                } label: {
                    Label("示例", systemImage: "wand.and.stars")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(AppTheme.accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(llamaState.translationTasks) { task in
                        TaskChip(task: task, isSelected: task == llamaState.selectedTask) {
                            llamaState.applyTask(task)
                            showsTaskDetails = task != .standard
                        }
                    }
                }
                .padding(.vertical, 1)
            }

            if llamaState.selectedTask != .standard {
                DisclosureGroup(isExpanded: $showsTaskDetails) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(llamaState.selectedTask.detailLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.secondaryText)

                        TextEditor(text: $llamaState.taskDetailText)
                            .font(.system(size: 14, design: .default))
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .frame(minHeight: 64)
                            .background(AppTheme.editorBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                    }
                    .padding(.top, 6)
                } label: {
                    HStack(spacing: 6) {
                        Text("参数")
                            .font(.system(size: 13, weight: .semibold))
                        Text(llamaState.selectedTask.detailLabel)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .foregroundStyle(AppTheme.primaryText)
                }
            }
        }
        .panelStyle()
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(icon: "square.and.pencil", title: "输入")
                Spacer()
                Button {
                    inputText = llamaState.selectedTask.sampleText
                } label: {
                    Label("填入示例", systemImage: "doc.on.doc")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(AppTheme.accent)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $inputText)
                    .font(.system(size: 16))
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 138)
                    .background(AppTheme.editorBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                if inputText.isEmpty {
                    Text("输入要翻译的文本")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.placeholderText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 10) {
                Button {
                    sendText()
                } label: {
                    Label(llamaState.isGenerating ? "生成中" : "Send", systemImage: llamaState.isGenerating ? "hourglass" : "paperplane.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(llamaState.isGenerating)

                Button {
                    bench()
                } label: {
                    Label("Bench", systemImage: "speedometer")
                        .labelStyle(.iconOnly)
                        .frame(width: 42)
                }
                .buttonStyle(.bordered)
                .disabled(llamaState.isGenerating)
            }
            .controlSize(.large)
            .tint(AppTheme.accent)
        }
        .panelStyle()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(icon: "text.bubble", title: "译文")
                Spacer()

                Button {
                    UIPasteboard.general.string = llamaState.translationOutput
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .labelStyle(.iconOnly)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.accent)

                Button(role: .destructive) {
                    clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .labelStyle(.iconOnly)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }

            if !llamaState.lastSourceText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("原文")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(llamaState.lastSourceText)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(AppTheme.controlBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }

            ScrollView(.vertical, showsIndicators: true) {
                Text(llamaState.translationOutput.isEmpty ? "等待译文" : llamaState.translationOutput)
                    .font(.system(size: 16))
                    .foregroundStyle(llamaState.translationOutput.isEmpty ? AppTheme.placeholderText : AppTheme.outputText)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                    .textSelection(.enabled)
                    .padding(12)
            }
            .frame(minHeight: 180, maxHeight: 340)
            .background(AppTheme.outputBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }

            DisclosureGroup(isExpanded: $showsLog) {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(llamaState.messageLog.isEmpty ? "暂无日志" : llamaState.messageLog)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(llamaState.messageLog.isEmpty ? AppTheme.placeholderText : AppTheme.primaryText)
                        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
                        .textSelection(.enabled)
                        .padding(10)
                }
                .frame(minHeight: 110, maxHeight: 180)
                .background(AppTheme.editorBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            } label: {
                Label("日志", systemImage: "terminal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .panelStyle()
    }

    private func sendText() {
        let text = inputText
        Task {
            await llamaState.complete(text: text)
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                inputText = ""
            }
        }
    }

    private func bench() {
        Task {
            await llamaState.bench()
        }
    }

    private func clear() {
        Task {
            await llamaState.clear()
        }
    }

    struct DrawerView: View {
        @ObservedObject var llamaState: LlamaState
        @State private var showingHelp = false
        @State private var showsDownloadTestControls = false
        @State private var modelListRefreshID = UUID()

        func deleteModel(filename: String) {
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("Error deleting file: \(error)")
            }

            llamaState.downloadedModels.removeAll { $0.filename == filename }
            modelListRefreshID = UUID()
        }

        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }

        var body: some View {
            List {
                Section {
                    if llamaState.hasBundledHyMT2Model {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hy-MT2 已内置")
                                    .font(.headline)
                                Text("当前版本已随 app 打包本地模型，启动后会自动加载，无需重复下载。")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }

                        Button {
                            showsDownloadTestControls.toggle()
                        } label: {
                            Label(showsDownloadTestControls ? "隐藏下载测试" : "显示下载测试", systemImage: "arrow.down.circle")
                        }

                        if showsDownloadTestControls {
                            downloadSourcePicker
                            cacheCleanupButton
                            modelDownloadRows
                        }
                    } else {
                        if llamaState.hasDownloadedHyMT2Model {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("已下载 \(llamaState.downloadedHyMT2ModelVariants.count) 个模型")
                                        .font(.headline)
                                    Text(llamaState.downloadedHyMT2ModelSummary)
                                        .font(.footnote)
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        downloadSourcePicker
                        cacheCleanupButton
                        modelDownloadRows
                    }
                } header: {
                    Text("Hy-MT2 Translation Model")
                } footer: {
                    Text(llamaState.hasBundledHyMT2Model ? "内置模型不能在 app 内删除。下载测试会额外保存一份到 Documents，可在下方左滑删除。" : "1.25Bit 更适合 4GB/6GB 手机；Q4/Q6/Q8 更占内存，可能加载失败或被系统杀掉。")
                }
            }
            .listStyle(.insetGrouped)
            .id(modelListRefreshID)
            .navigationBarTitle("Models", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Help") {
                        showingHelp = true
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. 这里可下载 Hy-MT2 的 1.25Bit、2Bit、Q4_K_M、Q6_K、Q8_0 GGUF。")
                        Text("2. ModelScope 目前列出 1.25Bit 和 2Bit 镜像；Q4、Q6、Q8 请切换到 Hugging Face。")
                        Text("3. 下载完成后同一行会变为 Load；点垃圾桶可删除 Documents 里的下载副本。")
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Help")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingHelp = false
                            }
                        }
                    }
                }
            }
        }

        private var downloadSourcePicker: some View {
            VStack(alignment: .leading, spacing: 8) {
                Picker("下载源", selection: $llamaState.selectedModelDownloadSource) {
                    ForEach(llamaState.modelDownloadSources) { source in
                        Text(source.title).tag(source)
                    }
                }
                .pickerStyle(.segmented)

                Text(llamaState.modelDownloadSourceNote)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }

        private var cacheCleanupButton: some View {
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    llamaState.clearDownloadCache(report: true)
                } label: {
                    Label("清理下载缓存", systemImage: "trash")
                }

                if !llamaState.downloadCacheMessage.isEmpty {
                    Text(llamaState.downloadCacheMessage)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }

        private var modelDownloadRows: some View {
            Group {
                if llamaState.isLoadingModel {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView()
                        Text("正在加载 \(llamaState.loadingModelName)")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }

                if llamaState.hyMT2DownloadModels.isEmpty {
                    Text("当前下载源没有可用模型")
                        .foregroundStyle(AppTheme.secondaryText)
                } else {
                    ForEach(llamaState.hyMT2DownloadModels) { model in
                        DownloadButton(
                            llamaState: llamaState,
                            modelName: model.name,
                            modelUrl: model.url,
                            filename: model.filename,
                            deleteAction: {
                                deleteModel(filename: model.filename)
                            }
                        )
                    }
                }
            }
        }
    }

    struct InferenceSettingsView: View {
        @ObservedObject var llamaState: LlamaState
        @Binding var isPresented: Bool

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        Picker("KV Cache", selection: Binding(
                            get: { llamaState.selectedKVCacheType },
                            set: { llamaState.setKVCacheType($0) }
                        )) {
                            ForEach(llamaState.kvCacheTypes) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(llamaState.selectedKVCacheType.detail)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.primaryText)
                            Text("这个设置影响推理上下文的 K/V 缓存，不是模型文件格式。切换后需要重新 Load 模型才会生效。")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    } header: {
                        Text("KV Cache")
                    }

                    Section {
                        LabeledContent("Backend", value: "CPU")
                        LabeledContent("Context", value: "\(LlamaContext.configuredContextSize)")
                        LabeledContent("Max output", value: "\(LlamaContext.configuredMaxNewTokens)")
                    } header: {
                        Text("Runtime")
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("推理设置")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }

    struct HistoryView: View {
        @ObservedObject var llamaState: LlamaState
        @Binding var inputText: String
        @Binding var isPresented: Bool
        @State private var showingClearConfirmation = false

        var body: some View {
            NavigationStack {
                Group {
                    if llamaState.translationHistory.isEmpty {
                        HistoryEmptyState()
                    } else {
                        List {
                            Section {
                                ForEach(llamaState.translationHistory) { item in
                                    Button {
                                        restore(item)
                                    } label: {
                                        HistoryRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            UIPasteboard.general.string = item.translationText
                                        } label: {
                                            Label("复制译文", systemImage: "doc.on.doc")
                                        }
                                    }
                                }
                                .onDelete(perform: llamaState.deleteHistoryItems)
                            } footer: {
                                Text("点选记录会恢复原文、译文、语言方向和任务类型。")
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("历史记录")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("关闭") {
                            isPresented = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        if !llamaState.translationHistory.isEmpty {
                            Button(role: .destructive) {
                                showingClearConfirmation = true
                            } label: {
                                Label("清空", systemImage: "trash")
                            }
                        }
                    }
                }
                .confirmationDialog("清空全部历史记录？", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                    Button("清空历史", role: .destructive) {
                        llamaState.clearTranslationHistory()
                    }
                    Button("取消", role: .cancel) {
                    }
                } message: {
                    Text("这只会删除翻译历史，不会影响模型文件。")
                }
            }
        }

        private func restore(_ item: TranslationHistoryItem) {
            inputText = item.sourceText
            llamaState.restoreHistoryItem(item)
            isPresented = false
        }
    }
}

private struct LanguagePicker: View {
    let title: String
    @Binding var selection: TranslationLanguage
    let languages: [TranslationLanguage]

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(languages) { language in
                    Text(language.displayName).tag(language)
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                Text(selection.shortDisplayName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.controlBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CompactLanguagePicker: View {
    let title: String
    @Binding var selection: TranslationLanguage
    let languages: [TranslationLanguage]

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(languages) { language in
                    Text(language.displayName).tag(language)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selection.shortDisplayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .foregroundStyle(AppTheme.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .padding(.horizontal, 8)
            .background(AppTheme.controlBackground, in: Capsule())
            .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct TaskChip: View {
    let task: TranslationTaskKind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: task.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(task.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(height: 34)
            .padding(.horizontal, 10)
            .foregroundStyle(isSelected ? AppTheme.selectedText : AppTheme.primaryText)
            .background(
                isSelected ? AppTheme.selectedBackground : AppTheme.controlBackground,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppTheme.accent : AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SectionTitle: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
        }
    }
}

private struct StatusPill: View {
    let isGenerating: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isGenerating ? Color.orange : Color.green)
                .frame(width: 7, height: 7)
            Text(isGenerating ? "RUNNING" : "READY")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .foregroundStyle(AppTheme.primaryText)
        .background(AppTheme.controlBackground, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
    }
}

private struct InfoToken: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.system(size: 11, weight: .semibold))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundStyle(AppTheme.secondaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 30)
        .padding(.horizontal, 6)
        .padding(.vertical, 7)
        .background(AppTheme.controlBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct HistoryEmptyState: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 64, height: 64)
                .background(AppTheme.controlBackground, in: Circle())
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))

            VStack(spacing: 6) {
                Text("暂无历史记录")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("翻译完成后会自动保存最近 50 条记录。")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

private struct HistoryRow: View {
    let item: TranslationHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.languageSummary)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)

                Text(item.taskTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.controlBackground, in: Capsule())

                Spacer(minLength: 8)

                Text(item.createdAt, formatter: Self.dateFormatter)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)
            }

            Text(item.sourceText)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(item.translationText)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

private enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "跟随系统"
        case .light:
            return "日间"
        case .dark:
            return "夜间"
        }
    }

    var iconName: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        self
            .padding(12)
            .background(AppTheme.panelBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}

private extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

private enum AppTheme {
    static let background = Color(
        light: Color(red: 0.95, green: 0.96, blue: 0.94),
        dark: Color(red: 0.055, green: 0.065, blue: 0.058)
    )
    static let panelBackground = Color(
        light: Color(red: 0.99, green: 0.985, blue: 0.965),
        dark: Color(red: 0.095, green: 0.112, blue: 0.102)
    )
    static let controlBackground = Color(
        light: Color(red: 0.93, green: 0.945, blue: 0.925),
        dark: Color(red: 0.135, green: 0.158, blue: 0.145)
    )
    static let editorBackground = Color(
        light: Color(red: 1.0, green: 0.995, blue: 0.98),
        dark: Color(red: 0.075, green: 0.09, blue: 0.083)
    )
    static let outputBackground = Color(
        light: Color(red: 0.115, green: 0.13, blue: 0.12),
        dark: Color(red: 0.035, green: 0.043, blue: 0.04)
    )
    static let outputText = Color(
        light: Color(red: 0.91, green: 0.95, blue: 0.90),
        dark: Color(red: 0.86, green: 0.96, blue: 0.88)
    )
    static let accent = Color(
        light: Color(red: 0.05, green: 0.42, blue: 0.32),
        dark: Color(red: 0.32, green: 0.82, blue: 0.62)
    )
    static let selectedBackground = Color(
        light: Color(red: 0.08, green: 0.38, blue: 0.31),
        dark: Color(red: 0.11, green: 0.45, blue: 0.34)
    )
    static let selectedText = Color(
        light: Color(red: 0.98, green: 0.99, blue: 0.96),
        dark: Color(red: 0.96, green: 1.0, blue: 0.965)
    )
    static let primaryText = Color(
        light: Color(red: 0.12, green: 0.14, blue: 0.13),
        dark: Color(red: 0.89, green: 0.93, blue: 0.88)
    )
    static let secondaryText = Color(
        light: Color(red: 0.38, green: 0.43, blue: 0.40),
        dark: Color(red: 0.63, green: 0.70, blue: 0.65)
    )
    static let placeholderText = Color(
        light: Color(red: 0.58, green: 0.62, blue: 0.58),
        dark: Color(red: 0.46, green: 0.53, blue: 0.49)
    )
    static let border = Color(
        light: Color(red: 0.78, green: 0.81, blue: 0.76),
        dark: Color(red: 0.20, green: 0.24, blue: 0.22)
    )
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
