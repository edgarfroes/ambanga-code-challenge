import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/user_service.dart';
import 'user_list_state.dart';

/// Fixed version of the Part 1 diagnosis cubit.
class UserListCubit extends Cubit<UserListState> {
  UserListCubit(this._userService) : super(const UserListInitial());

  final UserService _userService;
  StreamSubscription? _searchSubscription;
  Timer? _debounce;

  Future<void> init() async {
    emit(const UserListLoading());
    try {
      final users = await _userService.getUsers();
      if (!isClosed) emit(UserListLoaded(users));
    } catch (error) {
      if (!isClosed) emit(UserListError(error.toString()));
    }
  }

  void onSearchChanged(String term) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_search(term));
    });
  }

  Future<void> _search(String term) async {
    await _searchSubscription?.cancel();
    _searchSubscription = _userService.searchUsers(term).listen(
      (users) {
        if (!isClosed) emit(UserListLoaded(users));
      },
      onError: (Object error) {
        if (!isClosed) emit(UserListError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _searchSubscription?.cancel();
    return super.close();
  }
}
