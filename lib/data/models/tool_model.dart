import '../../domain/entities/tool_entity.dart';

/// Data model for Tool with JSON serialization
/// Maps to Supabase 'tools' table
class ToolModel extends ToolEntity {
  const ToolModel({
    required super.id,
    required super.userId,
    required super.toolName,
    required super.category,
    required super.monthlyPrice,
    required super.seats,
    required super.billingType,
    required super.growthRate,
    required super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      toolName: json['tool_name'] as String,
      category: json['category'] as String,
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      seats: json['seats'] as int,
      billingType: json['billing_type'] as String,
      growthRate: (json['growth_rate'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tool_name': toolName,
      'category': category,
      'monthly_price': monthlyPrice,
      'seats': seats,
      'billing_type': billingType,
      'growth_rate': growthRate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id and created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'tool_name': toolName,
      'category': category,
      'monthly_price': monthlyPrice,
      'seats': seats,
      'billing_type': billingType,
      'growth_rate': growthRate,
    };
  }

  /// Create from entity
  factory ToolModel.fromEntity(ToolEntity entity) {
    return ToolModel(
      id: entity.id,
      userId: entity.userId,
      toolName: entity.toolName,
      category: entity.category,
      monthlyPrice: entity.monthlyPrice,
      seats: entity.seats,
      billingType: entity.billingType,
      growthRate: entity.growthRate,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to entity
  ToolEntity toEntity() {
    return ToolEntity(
      id: id,
      userId: userId,
      toolName: toolName,
      category: category,
      monthlyPrice: monthlyPrice,
      seats: seats,
      billingType: billingType,
      growthRate: growthRate,
      createdAt: createdAt,
    );
  }

  @override
  ToolModel copyWith({
    String? id,
    String? userId,
    String? toolName,
    String? category,
    double? monthlyPrice,
    int? seats,
    String? billingType,
    double? growthRate,
    DateTime? createdAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      toolName: toolName ?? this.toolName,
      category: category ?? this.category,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      seats: seats ?? this.seats,
      billingType: billingType ?? this.billingType,
      growthRate: growthRate ?? this.growthRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
