# PM3 GUI

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/平台-Android%20%7C%20Linux%20%7C%20Windows-brightgreen" alt="平台"/>
  <img src="https://img.shields.io/badge/协议-GPL--3.0-blue" alt="License"/>
  <img src="https://img.shields.io/badge/状态-ALPHA-red" alt="Status"/>
  <img src="https://img.shields.io/badge/版本-v0.0.2--alpha-orange" alt="Version"/>
</div>

<div align="center">
  <h2>Proxmark3 跨平台图形界面</h2>
  <p>🔐 读写分析 RFID/NFC 卡片，点击即用的一站式解决方案</p>
</div>

> ⚠️ <b>ALPHA 声明</b>：本项目目前处于 ALPHA 测试阶段，功能仍在开发中，可能存在未发现的 bug 和功能限制。
> 
> ⚠️ <b>测试状态</b>：部分功能可能尚未在所有平台和硬件组合上进行充分测试。使用时请谨慎操作，建议在测试环境中验证后再用于生产场景。

---

## 🎯 项目简介

PM3 GUI 是一个基于 Flutter 开发的 Proxmark3 跨平台图形界面，旨在为 RFID/NFC 卡片的读写分析提供直观、高效的操作体验。

### 核心特性

- **跨平台支持**：同时支持 Android、Linux 和 Windows 平台，一次开发多平台运行
- **CLI Wrapper 模式**：通过管道启动原版 `pm3` 程序，自动继承上游命令更新，零维护成本
- **智能文件管理**：自动收集、归类 PM3 生成的 dump/key 文件，按 UID 分组展示
- **离线功能**：Dump 查看、编辑和分析无需连接硬件，随时随地处理卡片数据
- **全功能终端**：完整的 PM3 交互式终端，支持命令历史回溯和常用快捷命令
- **深度卡片分析**：制造商块解码、默认密钥检测、MAD 解析、值块检测等多种分析功能
- **安全操作**：提供操作确认机制，防止误操作导致数据丢失

---

## ✨ 功能概览

| 模块 | 说明 |
|:----:|------|
| 🔌 **连接 / 仪表盘** | 自动检测串口设备、实时连接状态监控、环境信息展示、PM3 文件自动收集与智能归类 |
| 💻 **终端** | 完整的 PM3 交互式终端，支持 ANSI 彩色输出、命令历史回溯、常用快捷命令按钮 |
| 📁 **Dump 查看 / 编辑** | 扇区视图展示、密钥编辑管理、深度卡片分析、CUID 回写与清空、智能文件合并策略 |
| 🔀 **Dump 对比** | 双栏并排对比、字节级差异高亮、详细差异统计、差异过滤显示 |
| 🔐 **Mifare 高频** | 卡片检测、Autopwn 自动破解、完整转储恢复、多种密钥攻击、魔术卡操作 |
| 📡 **低频 (LF)** | 低频搜索读取、EM410x 克隆、T55xx 完整操作、天线调谐 |
| ⚙️ **设置** | PM3 路径配置、主题切换、系统信息展示、硬件维护操作 |

---

## 🏗 架构设计

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter GUI (侧边栏导航)               │
│  ┌─────────────┐  ┌──────────┐  ┌──────────────────────┐ │
│  │ Provider     │  │ 莫兰迪   │  │   Dump 解析器        │ │
│  │ 全局状态     │  │ M3 主题  │  │ .eml .bin .json .dic │ │
│  └──────┬──────┘  └──────────┘  └──────────────────────┘ │
│         │                                                │
│  ┌──────▼──────────────────────────────────────────────┐ │
│  │               Pm3Process (dart:io)                  │ │
│  │   stdin/stdout 管道 ⟷ pm3 命令行  ⟷ OutputParser   │ │
│  └─────────────────────────────────────────────────────┘ │
│         │                                                │
│  ┌──────▼──────────────────────────────────────────────┐ │
│  │         FileCollector — 文件自动收集 & 归类          │ │
│  │   扫描 PM3 工作目录 → 按 UID 分组 → 移动到归类目录  │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
         │  启动子进程
         ▼
┌────────────────────┐
│  proxmark3 命令行  │  ← Iceman 分支 (RRG)
│  （原始程序不变）  │
└────────────────────┘
```

### 架构优势

- **CLI Wrapper 模式**：界面通过管道启动原版 `pm3` / `proxmark3` 程序，上游命令更新自动继承，零维护成本
- **模块化设计**：清晰的分层架构，便于扩展和维护
- **跨平台兼容**：基于 Flutter 框架，实现一次开发多平台运行
- **实时数据处理**：通过 stdout 管道实时解析 PM3 输出，响应迅速

---

## 📖 功能详解

### 1. 🔌 连接 / 仪表盘

**核心功能**：
- **智能连接**：自动扫描串口设备，支持 Linux (`/dev/ttyACM*`/`ttyUSB*`) 和 Windows (`COM1-20`)
- **状态监控**：实时显示连接状态、设备信息和环境参数
- **文件管理**：自动收集 PM3 生成的 dump/key 文件，按 UID 分组展示
- **归类整理**：将散落的文件移动到结构化目录中，便于管理

**文件归类结构**：
```
pm3_files/
├── hf-mf/           # 高频 Mifare 卡片
│   ├── A991A280/    # UID 分组
│   │   ├── hf-mf-A991A280-dump.bin
│   │   ├── hf-mf-A991A280-key.bin
│   │   └── hf-mf-A991A280-dump.json
└── lf-em/           # 低频 EM 卡片
    └── 12345678/    # ID 分组
        └── lf-em-12345678-dump.bin
```

### 2. 💻 终端

**核心功能**：
- **全功能交互**：直接透传 stdin/stdout，支持完整的 PM3 命令集
- **命令历史**：方向键 ↑ 回溯上一条命令，提高操作效率
- **快捷操作**：内置高频搜索、低频搜索、硬件版本等常用命令按钮
- **彩色输出**：自动处理 ANSI 色彩，提供清晰的视觉反馈

### 3. 📁 Dump 查看 / 编辑

**核心功能**：
- **多格式支持**：支持 `.eml`、`.bin`、`.json` 等多种 dump 格式
- **扇区视图**：直观展示卡片扇区和块数据，支持密钥分段高亮
- **深度分析**：制造商块解码、默认密钥检测、MAD 解析、值块检测
- **智能文件合并**：Key 文件仅合并密钥，Dump 文件可选择保留现有密钥
- **CUID 回写**：支持整卡或单个扇区回写，可跳过 Block 0

**导出格式**：EML、二进制转储、JSON、二进制密钥、密钥字典、密钥文本

### 4. 🔀 Dump 对比

**核心功能**：
- **双栏布局**：并排显示两份转储数据，便于对比
- **字节级高亮**：不同的字节标红显示，清晰识别差异
- **差异统计**：显示不同块数、不同字节数和总块数
- **过滤功能**：可只展示有差异的块，聚焦重点

### 5. 🔐 Mifare 高频操作

**核心功能**：
- **快捷操作**：检测卡片、卡片信息、Autopwn 自动破解、转储、恢复、嗅探
- **密钥攻击**：支持 Nested、Static Nested、Hardnested、Darkside 等多种攻击方式
- **读写块**：单块读取和数据写入，支持选择扇区/块/密钥类型
- **魔术卡**：支持 Gen1A、Gen2(CUID)、Gen3 等多种魔术卡操作

### 6. 📡 低频操作

**核心功能**：
- **通用操作**：低频搜索、读取、嗅探、天线调谐
- **EM410x**：读取 EM410x ID 并克隆到 T55xx
- **T55xx**：检测、信息获取、转储、块 0-7 逐块读写

### 7. ⚙️ 设置

**核心功能**：
- **主题切换**：深色/浅色莫兰迪主题，适应不同使用环境
- **PM3 路径配置**：独立的路径设置入口，支持自定义 PM3 程序位置
- **系统信息**：显示平台、架构、支持格式等信息
- **维护操作**：清除终端、查询硬件版本、天线调谐等快捷功能

---

## 🎨 莫兰迪色系

界面采用低饱和度莫兰迪色彩体系，长时间使用不易视觉疲劳：

| 色彩 | 色值 | 用途 |
|:----:|:----:|------|
| 莫兰迪蓝 | `#7E9AAB` | 主色调、选中状态、链接 |
| 莫兰迪绿 | `#8FA9A0` | 成功、连接状态、HF 标识 |
| 莫兰迪玫瑰 | `#BFA2A2` | 断开、删除、警告操作 |
| 莫兰迪暖灰 | `#A89F91` | 次要信息 |
| 莫兰迪薰衣草 | `#9B96B4` | 密钥文件、装饰色 |
| 柔和红 | `#C47D7D` | 错误信息 |
| 柔和绿 | `#8EAD8E` | 成功状态 |
| 柔和黄 | `#C9B07F` | 警告提示 |

---

## 🚀 快速上手

### 前置条件

- [Flutter 3.27+](https://flutter.dev/docs/get-started/install)
- Proxmark3 命令行客户端 (`pm3`) — [Iceman 分支](https://github.com/RfidResearchGroup/proxmark3)

### 编译与运行

```bash
# 克隆仓库
git clone https://github.com/AKCX2002/pm3gui.git
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

---

## 📋 支持的卡片协议

### 命令覆盖率

PM3 GUI 封装了 **43 个一级命令模板**，覆盖以下协议族：

| 协议 | GUI 命令数 | 原始 CLI 命令数 | 覆盖内容 |
|------|:---------:|:--------------:|----------|
| HF 14443-A | 2 | 9 | 搜索、信息 |
| HF Mifare Classic | 25 | 57 | 全链路：检测→攻击→读写→模拟器→Gen1A/Gen2(CUID)/Gen3 |
| LF 通用 | 4 | 6 | 搜索、读取、嗅探、调谐 |
| LF EM4x | 2 | 15 | EM410x 读取/克隆 |
| LF T55xx | 5 | 12 | 检测/信息/转储/块读写 |
| HW 硬件 | 3 | 14 | 版本/状态/调谐 |

> 完整命令映射参见 [`docs/pm3_commands.yaml`](docs/pm3_commands.yaml)。
> 未覆盖的命令仍可通过「终端」页面直接输入执行。

### 支持的 Dump/Key 格式

| 格式 | 扩展名 | 读取 | 导出 | 说明 |
|------|--------|:----:|:----:|------|
| EML | `.eml` | ✅ | ✅ | 文本模拟器格式 |
| 二进制转储 | `.bin` `.dump` | ✅ | ✅ | 原始 1:1 二进制 |
| JSON | `.json` | ✅ | ✅ | PM3 Jansson 格式 |
| 二进制密钥 | `.bin`（按大小检测） | ✅ | ✅ | PM3 标准密钥格式 |
| 密钥字典 | `.dic` | ✅ | ✅ | 一行一个密钥 |
| 密钥文本 | `.keys.txt` | — | ✅ | 按扇区列出 |

---

## 🔧 配置项

| 设置 | 默认值 | 说明 |
|------|--------|------|
| PM3 路径 | `./pm3` | proxmark3 客户端程序路径 |
| 主题 | 深色（莫兰迪） | 可在设置页或侧边栏切换 |
| 文件收集目录 | PM3 目录 + `$HOME` + CWD | 自动扫描的搜索范围 |
| 归类整理目录 | `<CWD>/pm3_files/` | 「归类整理」的默认目标（可自定义） |

---

## 📂 项目结构

```
pm3gui/
├── lib/
│   ├── main.dart                  # 入口，Provider 注入，主题切换
│   ├── models/                    # 数据模型
│   ├── parsers/                   # 文件解析器
│   ├── services/                  # 核心服务
│   ├── state/                     # 全局状态管理
│   └── ui/                        # 界面组件
├── docs/                          # 文档和配置
├── android/                       # 已配置 USB OTG 权限
├── linux/                         # Linux 平台配置
├── windows/                       # Windows 平台配置
└── pubspec.yaml                   # 项目配置和依赖
```

---

## 📝 开源协议

本项目采用 [GPL-3.0](LICENSE) 协议开源，与 Proxmark3 项目保持一致。

---

## 🙏 致谢

- [RfidResearchGroup/proxmark3](https://github.com/RfidResearchGroup/proxmark3) — Iceman 分支
- [wh201906/Proxmark3GUI](https://github.com/wh201906/Proxmark3GUI) — 设计参考（Qt C++，LGPL-2.1）
- 使用 [Flutter](https://flutter.dev) 和 [Material 3](https://m3.material.io) 构建

---

<div align="center">
  <p>Made with ❤️ for RFID/NFC enthusiasts</p>
</div>
