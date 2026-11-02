import 'package:drift/drift.dart';

/// 身份验证条目表 (AuthEntries)
///
/// 该类定义了数据库中存储双重身份验证 (2FA) 令牌的数据结构，支持 TOTP 和 HOTP 协议。
/// 每个字段的作用如下：
///
/// - [id]: 数据库自增主键，条目的唯一标识。
/// - [scheme]: 协议方案，固定通常为 "otpauth"。
/// - [type]: 令牌类型，"totp"（基于时间）或 "hotp"（基于计数器）。
/// - [issuer]: 发行者名称，如 "Google"、"GitHub" 或 "Microsoft"，标识服务提供商。
/// - [account]: 账户名，通常是用户的邮箱地址或用户名。
/// - [secret]: 共享密钥，用于生成 OTP 的 Base32 编码字符串。
/// - [algorithm]: 哈希算法，如 "SHA1"、"SHA256" 或 "SHA512"。
/// - [digits]: 生成验证码的长度，通常为 6 或 8 位。
/// - [period]: TOTP 步长（秒），验证码刷新的时间间隔，默认为 30。
/// - [counter]: HOTP 计数器，记录当前的计数值。
/// - [pin]: 可选字段，用于存储与条目相关的额外 PIN 码或备注。
/// - [icon]: 图标标识，存储用于在 UI 中匹配并显示对应服务图标的名称或路径。
/// - [sortOrder]: 排序权重，控制条目在应用列表中的显示顺序。
/// - [createdAt]: 创建时间戳，记录条目被添加到库中的时间。
@DataClassName('AuthEntry')
class AuthEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get scheme => text()();

  TextColumn get type => text()();

  TextColumn get issuer => text()();

  TextColumn get account => text()();

  TextColumn get secret => text()();

  TextColumn get algorithm => text()();

  IntColumn get digits => integer()();

  IntColumn get period => integer()();

  IntColumn get counter => integer()();

  TextColumn get pin => text()();

  TextColumn get icon => text()();

  IntColumn get sortOrder => integer()();

  IntColumn get createdAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {issuer, account},
  ];
}
