import 'package:equatable/equatable.dart';

enum SearchResultType { workspace, board, task }

class SearchResultEntity extends Equatable {
  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;

  /// e.g. "Mobile Team > Sprint Board > To Do"
  final String? breadcrumb;

  /// Only set for [SearchResultType.task].
  final String? priority;

  /// Only set for [SearchResultType.task].
  final bool? isOverdue;

  const SearchResultEntity({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.breadcrumb,
    this.priority,
    this.isOverdue,
  });

  @override
  List<Object?> get props => [id, type, title, subtitle, breadcrumb, priority, isOverdue];
}
