import '../../domain/entities/user_settings_entity.dart';

/// Data model for UserSettings with JSON serialization
/// Maps to Supabase 'user_settings' table
class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    required super.id,
    required super.userId,
    required super.theme,
    required super.currency,
    required super.dateFormat,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      theme: json['theme'] as String,
      currency: json['currency'] as String,
      dateFormat: json['date_format'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'theme': theme,
      'currency': currency,
      'date_format': dateFormat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'theme': theme,
      'currency': currency,
      'date_format': dateFormat,
    };
  }

  /// Convert to JSON for update (without id, user_id, created_at)
  Map<String, dynamic> toUpdateJson() {
    return {'theme': theme, 'currency': currency, 'date_format': dateFormat};
  }

  /// Create from entity
  factory UserSettingsModel.fromEntity(UserSettingsEntity entity) {
    return UserSettingsModel(
      id: entity.id,
      userId: entity.userId,
      theme: entity.theme,
      currency: entity.currency,
      dateFormat: entity.dateFormat,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      id: id,
      userId: userId,
      theme: theme,
      currency: currency,
      dateFormat: dateFormat,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  UserSettingsModel copyWith({
    String? id,
    String? userId,
    String? theme,
    String? currency,
    String? dateFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
