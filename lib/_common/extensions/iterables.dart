part of '../common.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Inserts [separator](index) between each pair of elements.
  Iterable<T> separate(T Function(int) separator) {
    if (length == 0) return this;
    final toList = this.toList();
    final iterable = <T>[];

    for (int i = 0; i < length; i++) {
      iterable.add(toList[i]);
      if (i + 1 < length) {
        iterable.add(separator(i));
      }
    }

    return iterable;
  }

  /// Element-wise equality after sorting (order-independent).
  bool isEqual(Iterable<T> compare) {
    final thisSorted = [...this]..sort();
    final compareSorted = [...compare]..sort();
    return thisSorted.toString() == compareSorted.toString();
  }

  /// True if this and [compare] share at least one element.
  bool isContainsAtLeastOne(Iterable<T> compare) {
    for (T element in this) {
      if (compare.contains(element)) return true;
    }
    return false;
  }

  /// True if all elements are widgets of the same type (for homogeneous lists).
  bool isContainsOnlyOneType(Type type) {
    final types = map((e) => e is Widget ? Widget : e.runtimeType).toSet();
    return types.isEmpty || (types.contains(type) && types.length == 1);
  }

  /// New list with [newValue] at [index]; returns a copy unchanged if index/value invalid.
  List<T> copyWith({int? index, T? newValue}) {
    if (index == null || newValue == null || index < 0 || index >= length) {
      return List<T>.from(this);
    }
    return List<T>.from(this)..[index] = newValue;
  }
}