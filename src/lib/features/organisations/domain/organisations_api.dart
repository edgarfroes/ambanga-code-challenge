import 'organisation.dart';

abstract class OrganisationsApi {
  Future<List<Organisation>> getOrganisations();
  Future<Organisation> createOrganisation({
    required String name,
    required String email,
  });
  Future<void> deleteOrganisation(int id);
}
