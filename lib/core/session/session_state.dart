import 'package:equatable/equatable.dart';

import '../../features/auth/domain/entity/user_entity.dart';

enum SessionStatus { initial, loading, authenticated, unauthenticated }

class SessionState extends Equatable {
  final SessionStatus status;
  final UserEntity? user;

  const SessionState({
    this.status = SessionStatus.initial,
    this.user,
  });

  SessionState copyWith({
    SessionStatus? status,
    UserEntity? user,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}