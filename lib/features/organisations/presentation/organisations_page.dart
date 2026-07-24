import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'organisations_cubit.dart';
import 'organisations_state.dart';

class OrganisationsPage extends StatefulWidget {
  const OrganisationsPage({super.key});

  @override
  State<OrganisationsPage> createState() => _OrganisationsPageState();
}

class _OrganisationsPageState extends State<OrganisationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrganisationsCubit>().load();
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New organisation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created == true && mounted) {
      await context.read<OrganisationsCubit>().create(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
          );
    }

    nameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organisations')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<OrganisationsCubit, OrganisationsState>(
        builder: (context, state) {
          return switch (state) {
            OrganisationsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            OrganisationsError(:final message) => Center(child: Text(message)),
            OrganisationsLoaded(:final organisations) => organisations.isEmpty
                ? const Center(child: Text('No organisations yet.'))
                : ListView.separated(
                    itemCount: organisations.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final org = organisations[index];
                      return ListTile(
                        title: Text(org.name),
                        subtitle: Text(org.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              context.read<OrganisationsCubit>().delete(org.id),
                        ),
                      );
                    },
                  ),
          };
        },
      ),
    );
  }
}
