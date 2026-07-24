import 'user.dart';

abstract class UserService {
  Future<List<User>> getUsers();
  Stream<List<User>> searchUsers(String term);
}
