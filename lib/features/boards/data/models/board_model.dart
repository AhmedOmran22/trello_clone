import '../../domain/entity/board_entity.dart';
import 'board_column_model.dart';

class BoardModel {
  final String id;
  final String workspaceId;
  final String name;
  final DateTime createdAt;
  final List<BoardColumnModel> columns;

  const BoardModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.createdAt,
    this.columns = const [],
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    final columnsList = json['board_columns'] as List<dynamic>? ?? [];

    return BoardModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      columns: columnsList
          .map((c) => BoardColumnModel.fromJson(c as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'workspace_id': workspaceId,
    };
  }

  BoardEntity toEntity() {
    return BoardEntity(
      id: id,
      workspaceId: workspaceId,
      name: name,
      createdAt: createdAt,
      columns: columns.map((c) => c.toEntity()).toList(),
    );
  }
}