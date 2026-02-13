import 'package:equatable/equatable.dart';

/// Domain entity for user settings
class UserSettingsEntity extends Equatable {
  final String id;
  final String userId;
  final String theme;
  final String currency;
  final String dateFormat;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsEntity({
    required this.id,
    required this.userId,
    required this.theme,
    required this.currency,
    required this.dateFormat,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettingsEntity copyWith({
    String? id,
    String? userId,
    String? theme,
    String? currency,
    String? dateFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    theme,
    currency,
    dateFormat,
    createdAt,
    updatedAt,
  ];
}
