<p align="center">
  <img src="assets/app_icon.png" 应用图标" width="128" />
</p>

# Authentication

一款基于 RFC 6238 标准的离线双因素认证（2FA）管理工具，旨在提供极简的凭证存储与一次性密码生成方案，支持 Windows、macOS、Linux、Android、iOS 及 Web 端。

## 简介

本项目目前处于实验阶段，尚未经独立安全审计。请勿将其作为重要账户唯一的恢复方式；请妥善保存服务商提供的恢复码，并在迁移设备前验证备份。

认证种子保存在本地数据库中，使用设备生成的密钥和 AES-GCM 加密；密钥由平台安全存储管理。新版使用独立数据库，不会自动迁移旧版数据；旧数据库文件、SQLite 日志、系统备份或存储介质中可能仍留有历史明文。设备受到恶意软件控制、应用运行时的内存、未锁定的设备或受损的构建环境不在此保护范围内。

导入和导出通过备份文件完成。导出时可选择密码保护；未设置密码的文件会明文包含所有密钥，请安全保管。密码无法找回，请先验证备份。Android 系统自动备份已禁用，卸载应用或更换设备前必须先导出并验证备份。加密数据库与设备密钥不能单独恢复彼此。

扫码需要相机权限；Linux 需要 libsecret 和可用的 Secret Service；Web 需要 HTTPS 或 localhost，浏览器存储和站点脚本的安全边界不同于原生应用；浏览器下载仅表示已请求保存，必须确认文件实际下载完成。各平台的完整发布和恢复流程仍需真实设备验证。安全问题的私下报告方式见 [SECURITY.md](SECURITY.md)。

## 应用截图

<p float="center">
   <img src="./screenshots/Screenshot_ios_1.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_7.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_3.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_2.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_6.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_4.webp" width="24%"/>
   <img src="./screenshots/Screenshot_ios_5.webp" width="24%"/>
</p>


## 代码结构

`lib/otp` 包含独立的 OTP 数据、解析、验证和计算；`lib/storage` 负责数据库、密钥和加密写入；`lib/backup` 负责备份格式及文件恢复；`lib/actions` 负责账户和扫码操作；`lib/otp/otp_provider.dart` 与 `lib/backup/backup_provider.dart` 管理操作状态；`lib/screens` 和 `lib/widgets` 分别保存页面与组件，界面通过 hooks_riverpod 观察数据和执行操作。数据库代码由 Drift 生成，可使用 `dart run build_runner build` 更新。

## 构建与发布

构建需要 Flutter 3.47 或更高版本；GitHub Actions 使用 Flutter 3.47.6。

GitHub Actions 在 `master` 上使用 Release Please 根据 Conventional Commits 维护版本 PR 和更新日志。合并版本 PR 后，工作流创建 GitHub Release，构建 Android arm64 APK、可上传至 Google Play 的签名 App Bundle（AAB）和未签名的 iOS IPA，并上传附件。推送标签也会触发构建；Actions 页面可以手动运行构建，填写已有 Release 标签以上传附件，留空则只构建。iOS IPA 需要自行签名后安装。Dependabot 每周检查 Dart 依赖更新。

启用发布前，在仓库的 Actions 设置中允许工作流创建和批准 Pull Request，并配置以下仓库 Secrets：

- `ANDROID_KEYSTORE_BASE64`：Android 签名密钥库文件的 Base64 内容。
- `ANDROID_KEYSTORE_PASSWORD`：密钥库密码。
- `ANDROID_KEY_ALIAS`：签名密钥别名。
- `ANDROID_KEY_PASSWORD`：签名密钥密码。

应使用与已有安装包相同的签名密钥，否则新 APK 无法覆盖安装。Android 和 iOS 构建都成功后才会上传 Release 附件；工作流失败时可在 Actions 页面查看日志并重试。

本地构建 Android Release 时，可在 `android/key.properties` 配置 `storeFile`、`storePassword`、`keyAlias` 和 `keyPassword`；`storeFile` 相对于 `android` 目录。密钥文件和配置不得提交到仓库。

Web 数据库运行文件 `web/drift_worker.js` 和 `web/sqlite3.wasm` 来自锁定的 drift 2.35.3 包（后者位于该包的 devtools 构建目录）。更新 drift 或 sqlite3 时需要同时更新这两个文件，并在浏览器中验证数据库创建、重启和备份恢复。

## 致谢

感谢以下开源项目的支持：

- [daegalus/dart-otp](https://github.com/daegalus/dart-otp)
- [elliotwutingfeng/motp](https://github.com/elliotwutingfeng/motp)
- [simple-icons](https://github.com/simple-icons/simple-icons)
- [drift](https://pub.dev/packages/drift)
- [google_mlkit_barcode_scanning](https://pub.dev/packages/google_mlkit_barcode_scanning)
- [dynamic_color](https://pub.dev/packages/dynamic_color)
- [flutter_swipe_action_cell](https://pub.dev/packages/flutter_swipe_action_cell)
- [mobile_scanner](https://github.com/juliansteenbakker/mobile_scanner)


## 许可证

本项目遵循 [GPL-3.0 License](LICENSE)。
