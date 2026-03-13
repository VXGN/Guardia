import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/contacts/add_trusted_contact.dart';
import 'package:guardia_app/domain/usecases/contacts/delete_trusted_contact.dart';
import 'package:guardia_app/domain/usecases/contacts/get_trusted_contacts.dart';
import 'package:guardia_app/domain/usecases/contacts/update_trusted_contact.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_event.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_state.dart';

class TrustedContactBloc extends Bloc<TrustedContactEvent, TrustedContactState> {
  final GetTrustedContacts getContactsUseCase;
  final AddTrustedContact addContactUseCase;
  final UpdateTrustedContact updateContactUseCase;
  final DeleteTrustedContact deleteContactUseCase;

  TrustedContactBloc({
    required this.getContactsUseCase,
    required this.addContactUseCase,
    required this.updateContactUseCase,
    required this.deleteContactUseCase,
  }) : super(TrustedContactInitial()) {
    on<LoadTrustedContactsRequested>(_onLoadTrustedContactsRequested);
    on<AddTrustedContactRequested>(_onAddTrustedContactRequested);
    on<UpdateTrustedContactRequested>(_onUpdateTrustedContactRequested);
    on<DeleteTrustedContactRequested>(_onDeleteTrustedContactRequested);
  }

  Future<void> _onLoadTrustedContactsRequested(
    LoadTrustedContactsRequested event,
    Emitter<TrustedContactState> emit,
  ) async {
    emit(TrustedContactLoading());
    final result = await getContactsUseCase();
    result.fold(
      (failure) => emit(TrustedContactError(failure.message)),
      (contacts) => emit(TrustedContactsLoaded(contacts)),
    );
  }

  Future<void> _onAddTrustedContactRequested(
    AddTrustedContactRequested event,
    Emitter<TrustedContactState> emit,
  ) async {
    emit(TrustedContactLoading());
    final result = await addContactUseCase(
      contactName: event.contactName,
      contactPhone: event.contactPhone,
      contactEmail: event.contactEmail,
    );
    result.fold(
      (failure) => emit(TrustedContactError(failure.message)),
      (_) => add<LoadTrustedContactsRequested>(),
    );
  }

  Future<void> _onUpdateTrustedContactRequested(
    UpdateTrustedContactRequested event,
    Emitter<TrustedContactState> emit,
  ) async {
    emit(TrustedContactLoading());
    final result = await updateContactUseCase(
      id: event.id,
      contactName: event.contactName,
      contactPhone: event.contactPhone,
      contactEmail: event.contactEmail,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(TrustedContactError(failure.message)),
      (_) => add<LoadTrustedContactsRequested>(),
    );
  }

  Future<void> _onDeleteTrustedContactRequested(
    DeleteTrustedContactRequested event,
    Emitter<TrustedContactState> emit,
  ) async {
    emit(TrustedContactLoading());
    final result = await deleteContactUseCase(event.id);
    result.fold(
      (failure) => emit(TrustedContactError(failure.message)),
      (_) => add<LoadTrustedContactsRequested>(),
    );
  }
}
