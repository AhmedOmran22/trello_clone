import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/board_entity.dart';
import '../../domain/entity/task_entity.dart';

/// Temporary mockup data for building the Board Detail Screen UI.
/// Remove this file once BoardBloc + real data are wired up.
class BoardMockData {
  BoardMockData._();

  static int _idCounter = 0;

  static String _newId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  static TaskEntity _task({
    required String columnId,
    required String title,
    required String priority,
    required int position,
    String? assigneeName,
    DateTime? dueDate,
    String? description,
  }) {
    return TaskEntity(
      id: _newId(),
      columnId: columnId,
      title: title,
      description: description,
      priority: priority,
      position: position,
      assigneeName: assigneeName,
      assigneeId: assigneeName != null ? _newId() : null,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
  }

  static BoardEntity board({required String boardId, required String boardName}) {
    final now = DateTime.now();

    final todoId = _newId();
    final inProgressId = _newId();
    final reviewId = _newId();
    final doneId = _newId();

    return BoardEntity(
      id: boardId,
      workspaceId: _newId(),
      name: boardName,
      createdAt: now,
      columns: [
        BoardColumnEntity(
          id: todoId,
          boardId: boardId,
          name: 'To Do',
          position: 0,
          createdAt: now,
          tasks: [
            _task(
              columnId: todoId,
              title: 'Design login page',
              priority: 'low',
              position: 0,
              assigneeName: 'Sara Ali',
              dueDate: now.add(const Duration(days: 2)),
            ),
            _task(
              columnId: todoId,
              title: 'Setup CI/CD pipeline',
              priority: 'medium',
              position: 1,
            ),
            _task(
              columnId: todoId,
              title: 'Write API documentation',
              priority: 'low',
              position: 2,
              assigneeName: 'Mohamed Hassan',
              dueDate: now.add(const Duration(days: 5)),
            ),
            _task(
              columnId: todoId,
              title: 'Research analytics tools',
              priority: 'low',
              position: 3,
            ),
          ],
        ),
        BoardColumnEntity(
          id: inProgressId,
          boardId: boardId,
          name: 'In Progress',
          position: 1,
          createdAt: now,
          tasks: [
            _task(
              columnId: inProgressId,
              title: 'Implement auth flow',
              priority: 'high',
              position: 0,
              assigneeName: 'Ahmed Omran',
              dueDate: now.add(const Duration(days: 1)),
            ),
            _task(
              columnId: inProgressId,
              title: 'Build dashboard UI',
              priority: 'urgent',
              position: 1,
              assigneeName: 'Sara Ali',
              dueDate: now.subtract(const Duration(days: 1)),
            ),
            _task(
              columnId: inProgressId,
              title: 'Database schema design',
              priority: 'medium',
              position: 2,
              assigneeName: 'Ahmed Omran',
              dueDate: now.add(const Duration(days: 3)),
            ),
          ],
        ),
        BoardColumnEntity(
          id: reviewId,
          boardId: boardId,
          name: 'Review',
          position: 2,
          createdAt: now,
          tasks: [
            _task(
              columnId: reviewId,
              title: 'Fix navigation bug',
              priority: 'high',
              position: 0,
              assigneeName: 'Mohamed Hassan',
              dueDate: now,
            ),
            _task(
              columnId: reviewId,
              title: 'Update dependencies',
              priority: 'low',
              position: 1,
            ),
          ],
        ),
        BoardColumnEntity(
          id: doneId,
          boardId: boardId,
          name: 'Done',
          position: 3,
          createdAt: now,
          tasks: [
            _task(
              columnId: doneId,
              title: 'Project setup',
              priority: 'medium',
              position: 0,
              assigneeName: 'Ahmed Omran',
            ),
            _task(
              columnId: doneId,
              title: 'Create Git repository',
              priority: 'low',
              position: 1,
              assigneeName: 'Ahmed Omran',
            ),
          ],
        ),
      ],
    );
  }
}
