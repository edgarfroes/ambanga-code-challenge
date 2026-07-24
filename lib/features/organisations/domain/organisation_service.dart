import 'organisation.dart';
import 'organisations_api.dart';

/// Domain application service — depends only on the API port (no Cubit).
class OrganisationService {
  OrganisationService(this._api);

  final OrganisationsApi _api;

  Future<List<Organisation>> getOrganisations() {
    return _api.getOrganisations();
  }

  Future<Organisation> createOrganisation(String name, String email) {
    return _api.createOrganisation(name: name, email: email);
  }

  Future<void> deleteOrganisation(int id) {
    return _api.deleteOrganisation(id);
  }
}
