import '../domain/user.dart';

sealed class UserListState {
  const UserListState();
}

class UserListInitial extends UserListState {
  const UserListInitial();
}

class UserListLoading extends UserListState {
  const UserListLoading();
}

class UserListLoaded extends UserListState {
  final List<User> users;

  const UserListLoaded(this.users);
}

class UserListError extends UserListState {
  final String message;

  const UserListError(this.message);
}
