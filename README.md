# PM3 GUI

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/平台-Android%20%7C%20Linux%20%7C%20Windows-brightgreen" alt="平台"/>
  <img src="https://img.shields.io/badge/协议-GPL--3.0-blue" alt="License"/>
</p>

<p align="center">
  <b>Proxmark3 跨平台图形界面 — 点击即用，兼容未来更新</b>
</p>

---

## ✨ 功能概览

| 模块 | 说明 |
|:----:|------|
| 🔌 **连接** | 自动检测串口、Android USB OTG、手动输入端口 |
| 💻 **终端** | 完整的 PM3 交互式终端，支持 ANSI 彩色输出和命令历史 |
| 📁 **Dump 查看器** | 离线打开和查看 `.eml` / `.bin` / `.json` 格式的 Mifare 转储文件 |
| 🔐 **Mifare** | 一键检测 / Autopwn / 转储 / 恢复 / Nested / Hardnested / Darkside |
| 📡 **低频 (LF)** | EM410x 读取与克隆、T55xx 检测 / 转储 / 块读写、天线调谐 |
| ⚙️ **设置** | PM3 路径配置、主题切换、硬件版本和调谐快捷操作 |

## 🏗 架构设计

```
┌──────────────────────────────────────────────────┐
│                  Flutter GUI                     │
│  ┌───────────┐  ┌────────┐  ┌────────────────┐  │
│  │ Provider   │  │  主题   │  │  Dump 解析器   │  │
│  │ 全局状态   │  │ 深/浅色 │  │ .eml .bin .json│  │
│  └─────┬─────┘  └────────┘  └────────────────┘  │
│        │                                         │
│  ┌─────▼──────────────────────────────────┐      │
│  │       Pm3Process (dart:io)             │      │
│  │  stdin/stdout 管道 ⟷ pm3 命令行程序    │      │
│  └────────────────────────────────────────┘      │
└──────────────────────────────────────────────────┘
         │  启动子进程
         ▼
┌────────────────────┐
│  proxmark3 命令行  │  ← Iceman 分支 (RRG)
│  （原始程序不变）  │
└────────────────────┘
```

> **CLI Wrapper 模式** — 界面通过管道启动原版 `pm3` / `proxmark3` 程序。
> 上游命令更新自动继承，零维护成本。

## 📂 项目结构

```
pm3gui/
├── lib/
│   ├── main.dart                  # 入口
│   ├── models/
│   │   ├── mifare_card.dart       # MifareCard / CardType / SectorKey 数据模型
│   │   └── access_bits.dart       # 访问控制位 编码/解码
│   ├── parsers/
│   │   ├── dump_parser.dart       # 统一解析入口（自动识别格式）
│   │   ├── eml_parser.dart        # .eml 文本格式
│   │   ├── bin_parser.dart        # .bin / .dump 二进制格式
│   │   └── json_dump_parser.dart  # PM3 Jansson JSON 格式
│   ├── services/
│   │   ├── pm3_process.dart       # 进程管理（连接/发送/流读取）
│   │   ├── pm3_commands.dart      # 命令模板（HF/LF/HW）
│   │   └── output_parser.dart     # 正则解析器（UID、密钥等）
│   ├── state/
│   │   └── app_state.dart         # 全局状态（Provider ChangeNotifier）
│   └── ui/
│       ├── theme.dart             # Material 3 深色/浅色主题
│       ├── home_page.dart         # 导航栏（6 个标签页）
│       └── pages/
│           ├── connection_page.dart   # 连接页
│           ├── terminal_page.dart     # 终端页
│           ├── dump_viewer_page.dart  # Dump 查看页
│           ├── mifare_page.dart       # Mifare 操作页
│           ├── lf_page.dart           # 低频操作页
│           └── settings_page.dart     # 设置页
├── android/                       # 已配置 USB OTG 权限
├── linux/
├── windows/
├── test/
└── pubspec.yaml
```

## 🚀 快速上手

### 前置条件

- [Flutter 3.24+](https://flutter.dev/docs/get-started/install)
- Proxmark3 命令行客户端 (`pm3`) — [Iceman 分支](https://github.com/RfidResearchGroup/proxmark3)

### 编译与运行

```bash
# 克隆仓库
git clone https://github.com/user/pm3gui.git
cd pm3gui

# 安装依赖
flutter pub get

# Linux 桌面运行
flutter run -d linux

# 编译发布版
flutter build linux          # → build/linux/x64/release/bundle/
flutter build apk            # → build/app/outputs/flutter-apk/
flutter build windows        # → build/windows/x64/runner/Release/
```

### Android（USB OTG）

应用已预配置 USB 主机权限和 PM3 设备过滤器。
通过 USB OTG 线缆连接 Proxmark3，应用会自动检测设备。

> ⚠️ Android 运行需要为 ARM 架构交叉编译 PM3 原生程序，这属于单独的编译步骤。

## 📋 支持的卡片操作

### 高频 HF（13.56 MHz）

- **Mifare Classic**：检测 · 信息 · Autopwn · 转储 · 恢复 · Nested / Hardnested / Darkside · 块读写 · 模拟器 · 魔术卡（Gen1A / Gen2）
- **嗅探**：ISO 14443A 通信捕获

### 低频 LF（125 kHz）

- **通用**：搜索 · 读取 · 嗅探 · 天线调谐
- **EM410x**：读取 · 克隆
- **T55xx**：检测 · 信息 · 转储 · 块读写

### 支持的 Dump 格式

| 格式 | 扩展名 | 说明 |
|------|--------|------|
| EML | `.eml` | 文本模拟器格式（每行一个块） |
| 二进制 | `.bin` `.dump` | 原始 1:1 二进制转储 |
| JSON | `.json` | PM3 Jansson 格式（含元数据） |

## 🔧 配置项

| 设置 | 默认值 | 说明 |
|------|--------|------|
| PM3 路径 | `./pm3` | proxmark3 客户端程序路径 |
| 主题 | 深色 | 可在设置页切换深色/浅色 |

## 📝 开源协议

本项目采用 [GPL-3.0](LICENSE) 协议开源，与 Proxmark3 项目保持一致。

## 🙏 致谢

- [RfidResearchGroup/proxmark3](https://github.com/RfidResearchGroup/proxmark3) — Iceman 分支
- [wh201906/Proxmark3GUI](https://github.com/wh201906/Proxmark3GUI) — 设计参考（Qt C++，LGPL-2.1）
- 使用 [Flutter](https://flutter.dev) 和 [Material 3](https://m3.material.io) 构建
