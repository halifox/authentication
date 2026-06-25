# PureOTP

一款基于 RFC 6238 标准的离线双因素认证（2FA）管理工具，旨在提供极简的凭证存储与一次性密码生成方案，支持 Windows、macOS、Linux、Android、iOS 及 Web 端。

## 简介

本程序是一款专注于双重身份验证（2FA）的离线客户端。与常见集成了繁杂云同步功能的认证应用不同，PureOTP 的设计逻辑完全聚焦于本地密钥管理与 TOTP 动态码的实时生成。程序架构上彻底移除了网络通信模块，不请求任何敏感系统权限，确保所有认证种子数据仅存在于本地沙盒环境。

相较于依赖云端的解决方案，本程序更偏向“极简与绝对控制”。用户无需担心凭证泄露或第三方隐私收集风险，所有操作逻辑均在本地闭环完成，是针对账户安全保护的纯粹本地化工具。

## 应用截图

### Android

<p float="center">
   <img src="./screenshot/Screenshot_20250920_164636.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_165514.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_164849.webp" width="24%"/>
   <img src="./screenshot/Screenshot_20250920_165825.webp" width="24%"/>
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
   <img src="./screenshot/Screenshot_ios_6.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_4.webp" width="24%"/>
   <img src="./screenshot/Screenshot_ios_5.webp" width="24%"/>
</p>

### macOS

<p float="center">
   <img src="./screenshot/Screenshot_macos_1.webp" width="49%"/>
   <img src="./screenshot/Screenshot_macos_2.webp" width="49%"/>
</p>

### Web

<p float="center">
   <img src="./screenshot/Screenshot_web.webp" width="99%"/>
</p>

## 致谢

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


## 许可证

本项目遵循 [GPL-3.0 License](LICENSE)。