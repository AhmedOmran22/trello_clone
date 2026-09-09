import 'package:equatable/equatable.dart';

import 'board_column_entity.dart';

class BoardEntity extends Equatable {
  final String id;
  final String workspaceId;
  final String name;
  final DateTime createdAt;
  final List<BoardColumnEntity> columns;

  const BoardEntity({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.createdAt,
    this.columns = const [],
  });

  BoardEntity copyWith({
    String? id,
    String? workspaceId,
    String? name,
    DateTime? createdAt,
    List<BoardColumnEntity>? columns,
  }) {
    return BoardEntity(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [id, workspaceId, name, createdAt, columns];
}