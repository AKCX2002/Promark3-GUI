# Changelog

## 0.0.3 - Fixes

- Fix: Correctly detect found MIFARE keys in `lib/parsers/output_parser.dart` (was incorrectly checking a numeric flag).
- Fix: Improve `sendCommandAndWait` in `lib/services/pm3_process.dart` to wait for table terminators (ensures `hf mf autopwn` full output including final key table is captured).

