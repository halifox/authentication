import 'package:authentication/otp/account.dart';

/// Sorts a copy, preserving a deterministic order for ties.
List<OtpAccount> sortAccounts(List<OtpAccount> accounts, int mode) {
  final sorted = accounts.toList();
  int manual(OtpAccount a, OtpAccount b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    return order != 0 ? order : a.id.compareTo(b.id);
  }

  int name(OtpAccount a, OtpAccount b) {
    final issuer = a.issuer.toLowerCase().compareTo(b.issuer.toLowerCase());
    return issuer != 0
        ? issuer
        : a.account.toLowerCase().compareTo(b.account.toLowerCase());
  }

  sorted.sort((a, b) {
    final primary = switch (mode) {
      1 => name(a, b),
      2 => name(b, a),
      3 => a.copyCount.compareTo(b.copyCount),
      4 => b.copyCount.compareTo(a.copyCount),
      _ => 0,
    };
    return primary != 0 ? primary : manual(a, b);
  });
  return sorted;
}
