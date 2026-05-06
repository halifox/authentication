# PureOTP

一款基于 RFC 6238 的双因素认证工具，支持 iOS、Android、Windows、macOS、Linux 和 Web。

简洁优雅的跨平台 2FA 工具，致力于提供最简单、最友好的使用体验，帮助用户更安全地保护账户信息。完全离线运行，无多余权限请求，守护您的隐私与安全。

---

## ✨ 核心特性

- 🔒 **简洁高效** - 专注于 2FA 生成与管理，无冗余功能
- 🎨 **优雅界面** - 清爽的设计风格，操作简单直观
- 🛑 **完全离线** - 无需联网，数据永不上传
- 🚫 **隐私至上** - 零多余权限，尊重用户隐私
- 📱 **全平台支持** - Windows、Mac、Linux、Android、iOS、Web 全覆盖

---

## 📸 应用截图

### Android

<p float="center">
   <img src="./screenshot/Screenshot_20250920_164636.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_165514.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_164849.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_165825.webp" width="24%"/>
</p>
<p float="center">
   <img src="./screenshot/Screenshot_20250920_164717.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_164727.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_164804.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_172013.webp" width="24%"/>
</p>

### 折叠屏设备

<p float="center">
   <img src="./screenshot/Screenshot_20250920_165047.webp" width="49%"/>
   <img src="./screenshot/Screenshot_20250920_165058.webp" width="49%"/>
</p>

### iOS

<p float="center">
   <img src="./screenshot/Screenshot_ios_1.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_7.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_3.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_2.webp" width="24%"/>
</p>
<p float="center">
   <img src="./screenshot/Screenshot_ios_6.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_4.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_5.webp" width="24%"/>
</p>

### macOS

<p float="center">
   <img src="./screenshot/Screenshot_macos_1.webp" width="49%"/>
   <img src="./screenshot/Screenshot_macos_2.webp" width="49%"/>
</p>

### Web 版

<p float="center">
   <img src="./screenshot/Screenshot_web.webp" width="99%"/>
</p>

---

## 📥 下载安装

> ⚠️ **安全提示**：应用尚未上架官方应用商店，请仅从 GitHub Releases 页面下载安装包，确保软件来源可信。  
> ⚠️ **系统兼容性**：安装前请确认设备满足对应平台的最低系统要求。

### Android
- 从 [Releases 页面](https://github.com/halifox/PureOTP/releases) 下载 APK 文件
- 安装前需允许"未知来源"应用安装权限
- 最低系统要求：Android 5.0+

### iOS
- 从 [Releases 页面](https://github.com/halifox/PureOTP/releases) 获取安装文件
- 安装时需按系统提示信任开发者证书
- 最低系统要求：iOS 12.0+

### macOS
- 从 [Releases 页面](https://github.com/halifox/PureOTP/releases) 下载 DMG 或 ZIP 文件
- 安装时可能需要在系统安全设置中允许"任何来源"的应用
- 最低系统要求：macOS 10.13+

### Windows
- 从 [Releases 页面](https://github.com/halifox/PureOTP/releases) 下载安装包
- 需要管理员权限完成安装
- 最低系统要求：Windows 10+

### Linux
- 从 [Releases 页面](https://github.com/halifox/PureOTP/releases) 获取可执行文件或压缩包
- 部分发行版可能需要额外依赖，请参考对应发行版安装指南

### Web 版
- 直接访问：[https://pureotp.pages.dev](https://pureotp.pages.dev)
- 无需安装，适合快速体验
- 建议使用现代浏览器以确保兼容性

---

## 🛠️ 使用指南

### 添加账户

1. **启动应用**，点击"添加账户"按钮
2. **扫描二维码**或**手动输入密钥**
   - 扫码：使用相机扫描服务商提供的 2FA 二维码
   - 手动：输入服务商提供的密钥字符串
3. **保存账户**，应用将自动生成 6 位动态验证码

### 使用验证码

1. 在目标网站或应用输入用户名和密码
2. 当系统提示输入 2FA 验证码时，打开 PureOTP
3. 找到对应账户，查看生成的 6 位验证码
4. 在 30 秒有效期内输入验证码完成登录 ⌛

### 管理账户

- **查看账户**：主界面列出所有已添加的账户及其验证码
- **删除账户**：滑动账户条目，点击"删除"按钮（操作不可撤销）🗑️
- **编辑账户**：滑动账户条目，点击"编辑"按钮修改账户信息 ✏️

---

## ❓ 常见问题

**Q1: 设备丢失后如何恢复 2FA？** 🤔  
A1: 需要使用备份密钥或联系服务商进行账户恢复。启用 2FA 时请务必保存备份密钥。🔑

**Q2: 如何确保 2FA 验证码的安全？** 🔒  
A2: 本工具完全离线运行，验证码仅存储在本地设备。建议使用强密码锁定设备，并定期备份密钥。💼

**Q3: 能否在多设备上使用？** 📱💻  
A3: 目前不支持同步功能，账户信息仅存储在本地。如需在多设备使用，请分别设置。🔄

**Q4: 为什么验证码总是过期？** ⏳  
A4: 验证码每 30 秒更新一次，请在有效期内输入。如超时，请等待新验证码生成。⌛

---

## 🤝 参与贡献

欢迎任何形式的社区贡献！  
请阅读 [贡献指南 (CONTRIBUTING.md)](CONTRIBUTING.md) 了解如何提交问题、请求功能或贡献代码。

---

## 📜 开源协议

本项目采用 [GPL-3.0 协议](LICENSE) 开源。

---

## 🙏 致谢

感谢以下开源项目的支持：

- [daegalus/dart-otp](https://github.com/daegalus/dart-otp)
- [elliotwutingfeng/motp](https://github.com/elliotwutingfeng/motp)
- [stratumauth](https://github.com/stratumauth/app)
- [simple-icons](https://github.com/simple-icons/simple-icons)
- [drift](https://pub.dev/packages/drift)
- [google_mlkit_barcode_scanning](https://pub.dev/packages/google_mlkit_barcode_scanning)
- [dynamic_color](https://pub.dev/packages/dynamic_color)
- [flutter_swipe_action_cell](https://pub.dev/packages/flutter_swipe_action_cell)
- [mobile_scanner](https://github.com/juliansteenbakker/mobile_scanner)
