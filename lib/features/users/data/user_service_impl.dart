import '../domain/user.dart';
import '../domain/user_service.dart';

class UserServiceImpl implements UserService {
  static const _all = [
    User(id: 1, name: 'Ada Lovelace'),
    User(id: 2, name: 'Alan Turing'),
    User(id: 3, name: 'Grace Hopper'),
    User(id: 4, name: 'Katherine Johnson'),
  ];

  @override
  Future<List<User>> getUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_all);
  }

  @override
  Stream<List<User>> searchUsers(String term) async* {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final query = term.trim().toLowerCase();
    if (query.isEmpty) {
      yield List.unmodifiable(_all);
      return;
    }
    yield _all
        .where((user) => user.name.toLowerCase().contains(query))
        .toList(growable: false);
  }
}
