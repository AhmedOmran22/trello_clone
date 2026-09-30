import '../../domain/entity/search_result_entity.dart';

class SearchResultModel {
  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final String? breadcrumb;
  final String? priority;
  final bool? isOverdue;

  const SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.breadcrumb,
    this.priority,
    this.isOverdue,
  });

  factory SearchResultModel.fromWorkspaceJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      type: SearchResultType.workspace,
      title: json['name'] as String,
    );
  }

  factory SearchResultModel.fromBoardJson(Map<String, dynamic> json) {
    final workspace = json['workspaces'] as Map<String, dynamic>?;
    return SearchResultModel(
      id: json['id'] as String,
      type: SearchResultType.board,
      title: json['name'] as String,
      breadcrumb: workspace?['name'] as String?,
    );
  }

  factory SearchResultModel.fromTaskJson(Map<String, dynamic> json) {
    final column = json['board_columns'] as Map<String, dynamic>?;
    final board = column?['boards'] as Map<String, dynamic>?;

    final dueDateStr = json['due_date'] as String?;
    final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    return SearchResultModel(
      id: json['id'] as String,
      type: SearchResultType.task,
      title: json['title'] as String,
      subtitle: json['description'] as String?,
      breadcrumb: [
        board?['name'],
        column?['name'],
      ].whereType<String>().join(' > '),
      priority: json['priority'] as String?,
      isOverdue: dueDate != null && dueDate.isBefore(DateTime.now()),
    );
  }

  SearchResultEntity toEntity() {
    return SearchResultEntity(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      breadcrumb: breadcrumb,
      priority: priority,
      isOverdue: isOverdue,
    );
  }
}
