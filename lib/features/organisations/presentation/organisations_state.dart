import '../domain/organisation.dart';

sealed class OrganisationsState {
  const OrganisationsState();
}

class OrganisationsLoading extends OrganisationsState {
  const OrganisationsLoading();
}

class OrganisationsLoaded extends OrganisationsState {
  final List<Organisation> organisations;

  const OrganisationsLoaded(this.organisations);
}

class OrganisationsError extends OrganisationsState {
  final String message;

  const OrganisationsError(this.message);
}
