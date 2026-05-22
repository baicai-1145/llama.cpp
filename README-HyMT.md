# HyMT

HyMT is an iOS local translation app built on `llama.cpp` for Tencent Hy-MT2 GGUF models. It is focused on running translation fully on device, with model downloads handled inside the app.

## Features

- Local Hy-MT2 translation on iPhone
- Download sources for Hugging Face, HF Mirror, and ModelScope
- Hy-MT2 1.25Bit, 2Bit, Q4_K_M, Q6_K, and Q8_0 GGUF entries
- F16 and Q8_0 KV cache options
- Translation history
- Separate translation output and runtime logs
- Light, dark, and system appearance modes

## Model Weights

This repository does not redistribute Hy-MT2 model weights.

The app downloads GGUF model files from the official model repositories:

- Hugging Face: https://huggingface.co/tencent
- ModelScope 1.25Bit mirror: https://www.modelscope.cn/models/AngelSlim/Hy-MT2-1.8B-1.25Bit-GGUF
- ModelScope 2Bit mirror: https://www.modelscope.cn/models/AngelSlim/Hy-MT2-1.8B-2Bit-GGUF

Users are responsible for complying with the Hy-MT2 model license and any applicable regional or usage restrictions.

## Build

Open the SwiftUI example project:

```sh
open examples/llama.swiftui/llama.swiftui.xcodeproj
```

Before building on a physical iPhone:

1. Select the `llama.swiftui` target.
2. Set your own Apple Development Team.
3. Change the bundle identifier to one you own.
4. Connect an iPhone and build with Xcode.

Command-line build example:

```sh
xcodebuild \
  -project examples/llama.swiftui/llama.swiftui.xcodeproj \
  -scheme llama.swiftui \
  -configuration Debug \
  -destination 'platform=iOS,id=<DEVICE_ID>' \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
  PRODUCT_BUNDLE_IDENTIFIER=<YOUR_BUNDLE_ID> \
  build
```

## Notes

- The iOS app currently uses CPU inference.
- Do not commit `.gguf` model files. They are ignored by `.gitignore`.
- App display name is `HyMT`.
- The upstream `llama.cpp` README continues below in `README.md`.

