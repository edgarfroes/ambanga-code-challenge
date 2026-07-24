import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_list_cubit.dart';
import 'user_list_state.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserListCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search users',
                border: OutlineInputBorder(),
              ),
              onChanged: context.read<UserListCubit>().onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<UserListCubit, UserListState>(
              builder: (context, state) {
                return switch (state) {
                  UserListInitial() || UserListLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  UserListError(:final message) => Center(child: Text(message)),
                  UserListLoaded(:final users) => users.isEmpty
                      ? const Center(child: Text('No users found.'))
                      : ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name.characters.first),
                              ),
                              title: Text(user.name),
                              subtitle: Text('ID ${user.id}'),
                            );
                          },
                        ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
