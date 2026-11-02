/// A user-defined account category. IDs are local to a database.
class AccountCategory {
  const AccountCategory({
    required this.name,
    this.id = 0,
    this.sortOrder = 0,
    this.isDefault = false,
  });
  final int id, sortOrder;
  final String name;
  final bool isDefault;
}

String validateCategoryName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed.length > 100 || trimmed.contains('\u0000')) {
    throw const FormatException('Invalid category name.');
  }
  return trimmed;
}

List<AccountCategory> validateCategories(List<AccountCategory> categories) {
  if (categories.length > 1000) {
    throw const FormatException('Too many categories.');
  }
  final names = <String>{};
  var defaults = 0;
  for (final category in categories) {
    if (validateCategoryName(category.name) != category.name ||
        category.sortOrder < 0 ||
        !names.add(category.name)) {
      throw const FormatException('Invalid category.');
    }
    if (category.isDefault) defaults++;
  }
  if (defaults > 1) throw const FormatException('Multiple default categories.');
  return categories;
}
