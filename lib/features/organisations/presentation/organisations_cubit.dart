import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/organisation_service.dart';
import 'organisations_state.dart';

class OrganisationsCubit extends Cubit<OrganisationsState> {
  OrganisationsCubit(this._service) : super(const OrganisationsLoading());

  final OrganisationService _service;

  Future<void> load() async {
    emit(const OrganisationsLoading());
    try {
      final orgs = await _service.getOrganisations();
      if (!isClosed) emit(OrganisationsLoaded(orgs));
    } catch (error) {
      if (!isClosed) {
        emit(OrganisationsError(error.toString()));
      }
    }
  }

  Future<void> create({required String name, required String email}) async {
    try {
      await _service.createOrganisation(name, email);
      await load();
    } catch (error) {
      if (!isClosed) {
        emit(OrganisationsError(error.toString()));
      }
    }
  }

  Future<void> delete(int id) async {
    try {
      await _service.deleteOrganisation(id);
      await load();
    } catch (error) {
      if (!isClosed) {
        emit(OrganisationsError(error.toString()));
      }
    }
  }
}
