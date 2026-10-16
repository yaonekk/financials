import 'package:flutter/material.dart';
import '../../domain/models/transaction_item.dart';

/// Data layer DTO representing a serialized custom category in local storage.
class CategoryStorageModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;

  const CategoryStorageModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorValue,
  });

  factory CategoryStorageModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'name': final String name,
        'iconCodePoint': final int iconCodePoint,
        'colorValue': final int colorValue,
      } =>
        CategoryStorageModel(
          id: id,
          name: name,
          iconCodePoint: iconCodePoint,
          iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
          colorValue: colorValue,
        ),
      _ => throw const FormatException('Invalid CategoryStorageModel JSON format.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
    };
  }

  factory CategoryStorageModel.fromDomain(TransactionCategory category) {
    return CategoryStorageModel(
      id: category.id,
      name: category.name,
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
      colorValue: category.color.toARGB32(),
    );
  }

  TransactionCategory toDomain() {
    return TransactionCategory(
      id: id,
      name: name,
      icon: _resolveIcon(iconCodePoint),
      color: Color(colorValue),
      isCustom: true,
    );
  }

  static const List<IconData> _supportedCustomIcons = [
    Icons.label_rounded,
    Icons.local_cafe_rounded,
    Icons.sports_esports_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.directions_bike_rounded,
    Icons.laptop_mac_rounded,
    Icons.music_note_rounded,
    Icons.local_gas_station_rounded,
    Icons.category_rounded,
  ];

  static IconData _resolveIcon(int codePoint) {
    for (final icon in _supportedCustomIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.category_rounded;
  }
}

