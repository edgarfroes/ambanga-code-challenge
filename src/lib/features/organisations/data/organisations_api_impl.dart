import '../domain/organisation.dart';
import '../domain/organisations_api.dart';

class OrganisationsApiImpl implements OrganisationsApi {
  final List<Organisation> _items = [
    const Organisation(id: 1, name: 'Acme Corp', email: 'hello@acme.test'),
    const Organisation(id: 2, name: 'Globex', email: 'team@globex.test'),
  ];
  int _nextId = 3;

  @override
  Future<List<Organisation>> getOrganisations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }

  @override
  Future<Organisation> createOrganisation({
    required String name,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final org = Organisation(id: _nextId++, name: name, email: email);
    _items.add(org);
    return org;
  }

  @override
  Future<void> deleteOrganisation(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((o) => o.id == id);
  }
}
