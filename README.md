# PM3 GUI

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20Linux%20%7C%20Windows-2ea44f" alt="Platforms"/>
  <img src="https://img.shields.io/badge/License-GPL--3.0-blue" alt="License"/>
  <img src="https://img.shields.io/badge/Status-Alpha-red" alt="Status"/>
</div>

PM3 GUI 是一个面向 Proxmark3 的跨平台图形化客户端，聚焦 RFID/NFC 读写、转储管理、分析与命令操作。

> ⚠️ **Alpha 说明**：当前版本仍在快速迭代，部分功能/行为可能在后续版本中调整。

---

## Why PM3 GUI

- 为 PM3 CLI 提供更低门槛的可视化操作入口。
- 保留高级用户的命令透传能力，而非替代 CLI。
- 通过结构化文件管理和离线分析降低重复劳动。

## Core Features

- **跨平台支持**：Android、Linux、Windows。
- **CLI Wrapper 架构**：通过进程管道驱动 `pm3`/`proxmark3`，自动继承上游命令能力。
- **终端模式**：支持完整命令输入、历史回溯与输出展示。
- **Dump/Key 文件管理**：自动扫描、识别、分组与归档。
- **数据处理能力**：支持 dump 查看、编辑、比较、转换与导出。

## Architecture Overview

```text
Flutter UI (pages + components)
  ├─ State layer (Provider)
  ├─ Parser layer (.eml/.bin/.json/.dic)
  └─ Service layer
       ├─ Pm3Process (stdin/stdout bridge)
       ├─ FileCollector / FileCache
       └─ DumpConverter / Command catalog
                │
                └─ proxmark3 CLI process
```

## Installation & Quick Start

### Prerequisites

- Flutter 3.27+
- Dart 3.6+
- Proxmark3 CLI (`pm3` 或 `proxmark3`，推荐 RRG/Iceman 分支)

### Run

```bash
git clone https://github.com/AKCX2002/pm3gui.git
cd pm3gui
flutter pub get
flutter run -d linux
```

### Build

```bash
flutter build linux
flutter build windows
flutter build apk --split-per-abi
```

## Supported File Formats

| Type | Extensions | Read | Export |
|---|---|---:|---:|
| EML dump | `.eml` | ✅ | ✅ |
| Binary dump | `.bin`, `.dump` | ✅ | ✅ |
| JSON dump | `.json` | ✅ | ✅ |
| Key dictionary | `.dic` | ✅ | ✅ |
| Key text | `.keys.txt` | - | ✅ |

## Repository Layout

```text
lib/
├─ models/           # 数据模型
├─ parsers/          # dump/key 解析器
├─ services/         # PM3 进程、文件、命令与转换服务
├─ state/            # Provider 状态管理
└─ ui/               # 页面与组件

docs/                # 规格说明、开发任务、命令映射
.github/workflows/   # CI/CD 工作流
```

## Engineering Workflow

建议在本地提交前执行：

```bash
flutter pub get
flutter analyze
flutter test
```

CI/CD（GitHub Actions）包含：

- `build.yml`：主分支/PR 多平台构建与静态检查。
- `release.yml`：标签触发构建并发布 Release 资产。
- `sync-pm3.yml`：同步并构建上游 Proxmark3 客户端/固件。

## Contributing

欢迎提交 Issue 与 Pull Request。

1. Fork 仓库并创建特性分支。
2. 变更尽量保持小步提交，并附带验证说明。
3. PR 描述中注明：背景、修改内容、影响范围、测试结果。

## Roadmap (Short-term)

- 完善更多 PM3 子命令页面覆盖。
- 增强 dump 差异分析与异常提示。
- 提升 Windows/Android 设备连接稳定性。

## License

本项目使用 **GPL-3.0** 许可证，详见 [LICENSE](./LICENSE)。
