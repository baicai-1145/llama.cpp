# HyMT

HyMT 是一个基于 `llama.cpp` 的 iOS 本地翻译 app。

这个分支只用于在 iPhone 上推理腾讯 Hy-MT / Hy-MT2 GGUF 翻译模型，不是通用的 `llama.cpp` 分发分支。

## 这个分支的用途

- 在 iPhone 本地运行 Hy-MT2 翻译模型
- 在 app 内下载支持的 Hy-MT2 GGUF 模型文件
- 测试 STQ / 低 bit Hy-MT2 在 iOS 上的推理
- 对比 1.25Bit、2Bit、Q4_K_M、Q6_K、Q8_0 模型在设备上的表现

## 这个分支不做什么

- 不随仓库分发 Hy-MT2 模型权重
- 不替代上游 `llama.cpp`
- 不作为任意 GGUF 模型的通用浏览器
- 当前主要面向 iPhone CPU 推理

## A15 实测速度

在 A15 芯片的 iPhone 上，Hy-MT2-1.8B 1.25Bit GGUF 模型本地翻译推理约为 **17 tokens/s**。

同一 app、同一设备测试中，Hy-MT2-1.8B Q8 模型约为 **0.22 tokens/s**。

也就是说，在这次 A15 测试里，1.25Bit 版本比 Q8 版本快约 **77 倍**：

```text
17 / 0.22 = 77.27
```

实际速度会受设备、温度、上下文长度、输入文本和系统状态影响。这个数据主要说明为什么本分支重点关注低 bit Hy-MT2 在 iPhone 上的推理。

## App 位置

iOS app 位于：

```text
examples/llama.swiftui
```

打开这个 Xcode 工程：

```text
examples/llama.swiftui/llama.swiftui.xcodeproj
```

## 模型权重

本仓库不包含模型权重。

app 可以从以下来源下载支持的 Hy-MT2 GGUF 文件：

- Hugging Face / HF Mirror
- ModelScope 的 1.25Bit 和 2Bit 镜像

用户需要自行遵守 Hy-MT2 模型许可。相关链接：

- https://github.com/Tencent-Hunyuan/Hy-MT2
- https://huggingface.co/tencent/Hy-MT2-1.8B-1.25Bit-GGUF
- https://huggingface.co/tencent/Hy-MT2-1.8B-2Bit-GGUF
- https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF

## 环境要求

- macOS
- Xcode
- 一台通过 USB 连接的 iPhone
- Apple Developer 账号或个人开发者签名
- iOS 16.4 或更新的 target 支持

当前 app 主要以真机 Debug 构建方式测试。

## 用 Xcode 编译

1. 克隆这个分支：

   ```sh
   git clone -b HYMT https://github.com/baicai-1145/llama.cpp.git
   cd llama.cpp
   ```

2. 打开 iOS 工程：

   ```sh
   open examples/llama.swiftui/llama.swiftui.xcodeproj
   ```

3. 在 Xcode 中选择 `llama.swiftui` target。

4. 在 **Signing & Capabilities** 中：

   - 选择你自己的 Apple development team
   - 把 bundle identifier 从 `com.example.hymt` 改成你自己的，例如 `com.yourname.hymt`

5. 选择已连接的 iPhone 作为运行目标。

6. 点击 **Run**。

app 在手机桌面上的显示名是 `HyMT`。

## 用命令行编译

先查找已连接 iPhone 的设备 ID：

```sh
xcrun devicectl list devices
```

然后编译：

```sh
xcodebuild \
  -project examples/llama.swiftui/llama.swiftui.xcodeproj \
  -scheme llama.swiftui \
  -configuration Debug \
  -destination 'platform=iOS,id=<DEVICE_ID>' \
  -derivedDataPath ./DerivedData \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
  PRODUCT_BUNDLE_IDENTIFIER=<YOUR_BUNDLE_ID> \
  build
```

示例：

```sh
xcodebuild \
  -project examples/llama.swiftui/llama.swiftui.xcodeproj \
  -scheme llama.swiftui \
  -configuration Debug \
  -destination 'platform=iOS,id=00000000-0000000000000000' \
  -derivedDataPath ./DerivedData \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=XXXXXXXXXX \
  PRODUCT_BUNDLE_IDENTIFIER=com.example.hymt.dev \
  build
```

## 安装到 iPhone

编译完成后安装 app：

```sh
xcrun devicectl device install app \
  --device <DEVICE_ID> \
  ./DerivedData/Build/Products/Debug-iphoneos/llama.swiftui.app
```

如果你使用了不同的 `-derivedDataPath`，需要相应修改 app 路径。

## 在 iPhone 上运行

1. 在 iPhone 上打开 `HyMT`。
2. 进入 **Models** 页面。
3. 选择下载源：
   - `ModelScope`
   - `Hugging Face`
   - `HF Mirror`
4. 下载一个支持的 Hy-MT2 GGUF 模型。
5. 对下载完成的模型点击 `Load`。
6. 回到主界面。
7. 选择源语言和目标语言。
8. 输入文本，点击 `Send`。

内存较小的 iPhone 建议优先测试：

```text
Hy-MT2-1.8B 1.25Bit
```

Q4、Q6、Q8 模型需要更多内存，在低内存设备上可能加载失败或被系统杀掉。

## 运行时说明

- 当前 app 后端：CPU
- Context size 在 `LlamaContext` 中配置
- KV cache 选项：F16 和 Q8_0
- 翻译输出和运行日志分开显示
- 翻译历史保存在设备本地
- 下载的模型保存在 app 的 Documents 目录

## 不要提交模型文件

不要提交 `.gguf` 文件。

`.gguf` 已经被 `.gitignore` 忽略。本仓库只应包含 app 代码、下载逻辑和说明文档。

## 上游和许可

本分支基于：

- https://github.com/ggml-org/llama.cpp

`llama.cpp` 使用 MIT License，见 `LICENSE`。

Hy-MT2 模型权重使用腾讯自己的模型许可，和本仓库代码许可不同。

更多归属和许可说明见：

```text
NOTICE-HyMT.md
```
