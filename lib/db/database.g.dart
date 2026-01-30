// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AuthEntriesTable extends AuthEntries
    with TableInfo<$AuthEntriesTable, AuthEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _schemeMeta = const VerificationMeta('scheme');
  @override
  late final GeneratedColumn<String> scheme = GeneratedColumn<String>(
    'scheme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretMeta = const VerificationMeta('secret');
  @override
  late final GeneratedColumn<String> secret = GeneratedColumn<String>(
    'secret',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _digitsMeta = const VerificationMeta('digits');
  @override
  late final GeneratedColumn<int> digits = GeneratedColumn<int>(
    'digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<int> period = GeneratedColumn<int>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterMeta = const VerificationMeta(
    'counter',
  );
  @override
  late final GeneratedColumn<int> counter = GeneratedColumn<int>(
    'counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinMeta = const VerificationMeta('pin');
  @override
  late final GeneratedColumn<String> pin = GeneratedColumn<String>(
    'pin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheme,
    type,
    issuer,
    account,
    secret,
    algorithm,
    digits,
    period,
    counter,
    pin,
    icon,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scheme')) {
      context.handle(
        _schemeMeta,
        scheme.isAcceptableOrUnknown(data['scheme']!, _schemeMeta),
      );
    } else if (isInserting) {
      context.missing(_schemeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    } else if (isInserting) {
      context.missing(_issuerMeta);
    }
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('secret')) {
      context.handle(
        _secretMeta,
        secret.isAcceptableOrUnknown(data['secret']!, _secretMeta),
      );
    } else if (isInserting) {
      context.missing(_secretMeta);
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    } else if (isInserting) {
      context.missing(_algorithmMeta);
    }
    if (data.containsKey('digits')) {
      context.handle(
        _digitsMeta,
        digits.isAcceptableOrUnknown(data['digits']!, _digitsMeta),
      );
    } else if (isInserting) {
      context.missing(_digitsMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('counter')) {
      context.handle(
        _counterMeta,
        counter.isAcceptableOrUnknown(data['counter']!, _counterMeta),
      );
    } else if (isInserting) {
      context.missing(_counterMeta);
    }
    if (data.containsKey('pin')) {
      context.handle(
        _pinMeta,
        pin.isAcceptableOrUnknown(data['pin']!, _pinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {issuer, account},
  ];
  @override
  AuthEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheme'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      )!,
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      secret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret'],
      )!,
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      )!,
      digits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}digits'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period'],
      )!,
      counter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counter'],
      )!,
      pin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuthEntriesTable createAlias(String alias) {
    return $AuthEntriesTable(attachedDatabase, alias);
  }
}

class AuthEntry extends DataClass implements Insertable<AuthEntry> {
  final int id;
  final String scheme;
  final String type;
  final String issuer;
  final String account;
  final String secret;
  final String algorithm;
  final int digits;
  final int period;
  final int counter;
  final String pin;
  final String icon;
  final int sortOrder;
  final int createdAt;
  const AuthEntry({
    required this.id,
    required this.scheme,
    required this.type,
    required this.issuer,
    required this.account,
    required this.secret,
    required this.algorithm,
    required this.digits,
    required this.period,
    required this.counter,
    required this.pin,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scheme'] = Variable<String>(scheme);
    map['type'] = Variable<String>(type);
    map['issuer'] = Variable<String>(issuer);
    map['account'] = Variable<String>(account);
    map['secret'] = Variable<String>(secret);
    map['algorithm'] = Variable<String>(algorithm);
    map['digits'] = Variable<int>(digits);
    map['period'] = Variable<int>(period);
    map['counter'] = Variable<int>(counter);
    map['pin'] = Variable<String>(pin);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AuthEntriesCompanion toCompanion(bool nullToAbsent) {
    return AuthEntriesCompanion(
      id: Value(id),
      scheme: Value(scheme),
      type: Value(type),
      issuer: Value(issuer),
      account: Value(account),
      secret: Value(secret),
      algorithm: Value(algorithm),
      digits: Value(digits),
      period: Value(period),
      counter: Value(counter),
      pin: Value(pin),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory AuthEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthEntry(
      id: serializer.fromJson<int>(json['id']),
      scheme: serializer.fromJson<String>(json['scheme']),
      type: serializer.fromJson<String>(json['type']),
      issuer: serializer.fromJson<String>(json['issuer']),
      account: serializer.fromJson<String>(json['account']),
      secret: serializer.fromJson<String>(json['secret']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
      digits: serializer.fromJson<int>(json['digits']),
      period: serializer.fromJson<int>(json['period']),
      counter: serializer.fromJson<int>(json['counter']),
      pin: serializer.fromJson<String>(json['pin']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheme': serializer.toJson<String>(scheme),
      'type': serializer.toJson<String>(type),
      'issuer': serializer.toJson<String>(issuer),
      'account': serializer.toJson<String>(account),
      'secret': serializer.toJson<String>(secret),
      'algorithm': serializer.toJson<String>(algorithm),
      'digits': serializer.toJson<int>(digits),
      'period': serializer.toJson<int>(period),
      'counter': serializer.toJson<int>(counter),
      'pin': serializer.toJson<String>(pin),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AuthEntry copyWith({
    int? id,
    String? scheme,
    String? type,
    String? issuer,
    String? account,
    String? secret,
    String? algorithm,
    int? digits,
    int? period,
    int? counter,
    String? pin,
    String? icon,
    int? sortOrder,
    int? createdAt,
  }) => AuthEntry(
    id: id ?? this.id,
    scheme: scheme ?? this.scheme,
    type: type ?? this.type,
    issuer: issuer ?? this.issuer,
    account: account ?? this.account,
    secret: secret ?? this.secret,
    algorithm: algorithm ?? this.algorithm,
    digits: digits ?? this.digits,
    period: period ?? this.period,
    counter: counter ?? this.counter,
    pin: pin ?? this.pin,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  AuthEntry copyWithCompanion(AuthEntriesCompanion data) {
    return AuthEntry(
      id: data.id.present ? data.id.value : this.id,
      scheme: data.scheme.present ? data.scheme.value : this.scheme,
      type: data.type.present ? data.type.value : this.type,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      account: data.account.present ? data.account.value : this.account,
      secret: data.secret.present ? data.secret.value : this.secret,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      digits: data.digits.present ? data.digits.value : this.digits,
      period: data.period.present ? data.period.value : this.period,
      counter: data.counter.present ? data.counter.value : this.counter,
      pin: data.pin.present ? data.pin.value : this.pin,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthEntry(')
          ..write('id: $id, ')
          ..write('scheme: $scheme, ')
          ..write('type: $type, ')
          ..write('issuer: $issuer, ')
          ..write('account: $account, ')
          ..write('secret: $secret, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('period: $period, ')
          ..write('counter: $counter, ')
          ..write('pin: $pin, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheme,
    type,
    issuer,
    account,
    secret,
    algorithm,
    digits,
    period,
    counter,
    pin,
    icon,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthEntry &&
          other.id == this.id &&
          other.scheme == this.scheme &&
          other.type == this.type &&
          other.issuer == this.issuer &&
          other.account == this.account &&
          other.secret == this.secret &&
          other.algorithm == this.algorithm &&
          other.digits == this.digits &&
          other.period == this.period &&
          other.counter == this.counter &&
          other.pin == this.pin &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class AuthEntriesCompanion extends UpdateCompanion<AuthEntry> {
  final Value<int> id;
  final Value<String> scheme;
  final Value<String> type;
  final Value<String> issuer;
  final Value<String> account;
  final Value<String> secret;
  final Value<String> algorithm;
  final Value<int> digits;
  final Value<int> period;
  final Value<int> counter;
  final Value<String> pin;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  const AuthEntriesCompanion({
    this.id = const Value.absent(),
    this.scheme = const Value.absent(),
    this.type = const Value.absent(),
    this.issuer = const Value.absent(),
    this.account = const Value.absent(),
    this.secret = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.digits = const Value.absent(),
    this.period = const Value.absent(),
    this.counter = const Value.absent(),
    this.pin = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AuthEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String scheme,
    required String type,
    required String issuer,
    required String account,
    required String secret,
    required String algorithm,
    required int digits,
    required int period,
    required int counter,
    required String pin,
    required String icon,
    required int sortOrder,
    required int createdAt,
  }) : scheme = Value(scheme),
       type = Value(type),
       issuer = Value(issuer),
       account = Value(account),
       secret = Value(secret),
       algorithm = Value(algorithm),
       digits = Value(digits),
       period = Value(period),
       counter = Value(counter),
       pin = Value(pin),
       icon = Value(icon),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<AuthEntry> custom({
    Expression<int>? id,
    Expression<String>? scheme,
    Expression<String>? type,
    Expression<String>? issuer,
    Expression<String>? account,
    Expression<String>? secret,
    Expression<String>? algorithm,
    Expression<int>? digits,
    Expression<int>? period,
    Expression<int>? counter,
    Expression<String>? pin,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheme != null) 'scheme': scheme,
      if (type != null) 'type': type,
      if (issuer != null) 'issuer': issuer,
      if (account != null) 'account': account,
      if (secret != null) 'secret': secret,
      if (algorithm != null) 'algorithm': algorithm,
      if (digits != null) 'digits': digits,
      if (period != null) 'period': period,
      if (counter != null) 'counter': counter,
      if (pin != null) 'pin': pin,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AuthEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? scheme,
    Value<String>? type,
    Value<String>? issuer,
    Value<String>? account,
    Value<String>? secret,
    Value<String>? algorithm,
    Value<int>? digits,
    Value<int>? period,
    Value<int>? counter,
    Value<String>? pin,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<int>? createdAt,
  }) {
    return AuthEntriesCompanion(
      id: id ?? this.id,
      scheme: scheme ?? this.scheme,
      type: type ?? this.type,
      issuer: issuer ?? this.issuer,
      account: account ?? this.account,
      secret: secret ?? this.secret,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      counter: counter ?? this.counter,
      pin: pin ?? this.pin,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheme.present) {
      map['scheme'] = Variable<String>(scheme.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (secret.present) {
      map['secret'] = Variable<String>(secret.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (digits.present) {
      map['digits'] = Variable<int>(digits.value);
    }
    if (period.present) {
      map['period'] = Variable<int>(period.value);
    }
    if (counter.present) {
      map['counter'] = Variable<int>(counter.value);
    }
    if (pin.present) {
      map['pin'] = Variable<String>(pin.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthEntriesCompanion(')
          ..write('id: $id, ')
          ..write('scheme: $scheme, ')
          ..write('type: $type, ')
          ..write('issuer: $issuer, ')
          ..write('account: $account, ')
          ..write('secret: $secret, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('period: $period, ')
          ..write('counter: $counter, ')
          ..write('pin: $pin, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuthEntriesTable authEntries = $AuthEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [authEntries];
}

typedef $$AuthEntriesTableCreateCompanionBuilder =
    AuthEntriesCompanion Function({
      Value<int> id,
      required String scheme,
      required String type,
      required String issuer,
      required String account,
      required String secret,
      required String algorithm,
      required int digits,
      required int period,
      required int counter,
      required String pin,
      required String icon,
      required int sortOrder,
      required int createdAt,
    });
typedef $$AuthEntriesTableUpdateCompanionBuilder =
    AuthEntriesCompanion Function({
      Value<int> id,
      Value<String> scheme,
      Value<String> type,
      Value<String> issuer,
      Value<String> account,
      Value<String> secret,
      Value<String> algorithm,
      Value<int> digits,
      Value<int> period,
      Value<int> counter,
      Value<String> pin,
      Value<String> icon,
      Value<int> sortOrder,
      Value<int> createdAt,
    });

class $$AuthEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AuthEntriesTable> {
  $$AuthEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthEntriesTable> {
  $$AuthEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthEntriesTable> {
  $$AuthEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scheme =>
      $composableBuilder(column: $table.scheme, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get secret =>
      $composableBuilder(column: $table.secret, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<int> get digits =>
      $composableBuilder(column: $table.digits, builder: (column) => column);

  GeneratedColumn<int> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get counter =>
      $composableBuilder(column: $table.counter, builder: (column) => column);

  GeneratedColumn<String> get pin =>
      $composableBuilder(column: $table.pin, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuthEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthEntriesTable,
          AuthEntry,
          $$AuthEntriesTableFilterComposer,
          $$AuthEntriesTableOrderingComposer,
          $$AuthEntriesTableAnnotationComposer,
          $$AuthEntriesTableCreateCompanionBuilder,
          $$AuthEntriesTableUpdateCompanionBuilder,
          (
            AuthEntry,
            BaseReferences<_$AppDatabase, $AuthEntriesTable, AuthEntry>,
          ),
          AuthEntry,
          PrefetchHooks Function()
        > {
  $$AuthEntriesTableTableManager(_$AppDatabase db, $AuthEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scheme = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> issuer = const Value.absent(),
                Value<String> account = const Value.absent(),
                Value<String> secret = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<int> digits = const Value.absent(),
                Value<int> period = const Value.absent(),
                Value<int> counter = const Value.absent(),
                Value<String> pin = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => AuthEntriesCompanion(
                id: id,
                scheme: scheme,
                type: type,
                issuer: issuer,
                account: account,
                secret: secret,
                algorithm: algorithm,
                digits: digits,
                period: period,
                counter: counter,
                pin: pin,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scheme,
                required String type,
                required String issuer,
                required String account,
                required String secret,
                required String algorithm,
                required int digits,
                required int period,
                required int counter,
                required String pin,
                required String icon,
                required int sortOrder,
                required int createdAt,
              }) => AuthEntriesCompanion.insert(
                id: id,
                scheme: scheme,
                type: type,
                issuer: issuer,
                account: account,
                secret: secret,
                algorithm: algorithm,
                digits: digits,
                period: period,
                counter: counter,
                pin: pin,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthEntriesTable,
      AuthEntry,
      $$AuthEntriesTableFilterComposer,
      $$AuthEntriesTableOrderingComposer,
      $$AuthEntriesTableAnnotationComposer,
      $$AuthEntriesTableCreateCompanionBuilder,
      $$AuthEntriesTableUpdateCompanionBuilder,
      (AuthEntry, BaseReferences<_$AppDatabase, $AuthEntriesTable, AuthEntry>),
      AuthEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuthEntriesTableTableManager get authEntries =>
      $$AuthEntriesTableTableManager(_db, _db.authEntries);
}
