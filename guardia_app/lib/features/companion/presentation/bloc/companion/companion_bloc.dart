import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:guardia_app/core/utils/location_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardia_app/features/companion/data/datasources/chat_remote_data_source.dart';
import 'package:guardia_app/features/companion/domain/entities/companion_message_entity.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/domain/usecases/add_trusted_contact.dart';
import 'package:guardia_app/features/companion/domain/usecases/delete_trusted_contact.dart';
import 'package:guardia_app/features/companion/domain/usecases/end_journey.dart';
import 'package:guardia_app/features/companion/domain/usecases/get_active_journey.dart';
import 'package:guardia_app/features/companion/domain/usecases/get_trusted_contacts.dart';
import 'package:guardia_app/features/companion/domain/usecases/start_journey.dart';
import 'package:guardia_app/features/companion/domain/usecases/update_journey_location.dart';
import 'package:guardia_app/features/companion/domain/usecases/update_trusted_contact.dart';

part 'companion_event.dart';
part 'companion_state.dart';

class CompanionBloc extends Bloc<CompanionEvent, CompanionState> {
  // ... existing fields ...
  final GetTrustedContacts getTrustedContacts;
  final AddTrustedContact addTrustedContact;
  final UpdateTrustedContact updateTrustedContact;
  final DeleteTrustedContact deleteTrustedContact;
  final StartJourney startJourney;
  final UpdateJourneyLocation updateJourneyLocation;
  final EndJourney endJourney;
  final GetActiveJourney getActiveJourney;
  final ChatRemoteDataSource chatRemoteDataSource;
  
  StreamSubscription? _chatSubscription;
  Timer? _locationTimer;

  CompanionBloc({
    required this.getTrustedContacts,
    required this.addTrustedContact,
    required this.updateTrustedContact,
    required this.deleteTrustedContact,
    required this.startJourney,
    required this.updateJourneyLocation,
    required this.endJourney,
    required this.getActiveJourney,
    required this.chatRemoteDataSource,
  }) : super(const CompanionState()) {
    on<CompanionStarted>(_onStarted);
    on<TrustedContactsRequested>(_onContactsRequested);
    on<TrustedContactAdded>(_onContactAdded);
    on<TrustedContactUpdated>(_onContactUpdated);
    on<TrustedContactDeleted>(_onContactDeleted);
    on<TrustedContactToggled>(_onContactToggled);
    on<JourneyStartRequested>(_onJourneyStartRequested);
    on<JourneyLocationTick>(_onJourneyLocationTick);
    on<JourneyEndRequested>(_onJourneyEndRequested);
    on<CompanionMessageSent>(_onMessageSent);
    on<CompanionLocationShared>(_onLocationShared);
    on<CompanionAlertTriggered>(_onAlertTriggered);
    on<CompanionResetAlert>(_onResetAlert);
    on<CompanionResetError>(_onResetError);
    on<CompanionMessageReceived>(_onMessageReceived);
    on<CompanionConnectionChanged>(_onConnectionChanged);
    on<ChatHistoryRequested>(_onChatHistoryRequested);
  }

  void _onMessageReceived(CompanionMessageReceived event, Emitter<CompanionState> emit) {
    final payload = event.message['payload'];
    final eventName = event.message['event'];

    if (eventName == 'receive_message' || eventName == 'message_sent') {
      final newMessage = CompanionMessageEntity(
        id: payload['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        text: payload['message'] ?? '',
        isMe: payload['sender_uid'] == FirebaseAuth.instance.currentUser?.uid,
        time: payload['timestamp'] != null ? DateTime.parse(payload['timestamp']) : DateTime.now(),
      );
      
      // Check if message already exists to avoid duplicates (e.g. from message_sent echo)
      if (state.messages.any((m) => m.id == newMessage.id)) return;
      
      emit(state.copyWith(messages: List.from(state.messages)..add(newMessage)));
    } else if (eventName == 'connected') {
      add(const CompanionConnectionChanged(true));
    } else if (eventName == 'error') {
      emit(state.copyWith(errorMessage: payload['message']));
    }
  }

  void _onConnectionChanged(CompanionConnectionChanged event, Emitter<CompanionState> emit) {
    emit(state.copyWith(isChatConnected: event.isConnected));
  }

  Future<void> _onChatHistoryRequested(ChatHistoryRequested event, Emitter<CompanionState> emit) async {
    try {
      final rawMessages = await chatRemoteDataSource.fetchChatHistory(event.otherUid);
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final historyMessages = rawMessages.map((msg) {
        return CompanionMessageEntity(
          id: msg['id']?.toString() ?? '',
          text: msg['message']?.toString() ?? '',
          isMe: msg['sender_uid'] == currentUid,
          time: msg['timestamp'] != null
              ? DateTime.tryParse(msg['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();

      // Prepend history before any existing real-time messages
      final existingIds = state.messages.map((m) => m.id).toSet();
      final newHistory = historyMessages.where((m) => !existingIds.contains(m.id)).toList();

      emit(state.copyWith(messages: [...newHistory, ...state.messages]));
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _onMessageSent(CompanionMessageSent event, Emitter<CompanionState> emit) {
    // Optimistically add the message to state immediately so it appears in the UI
    final newMessage = CompanionMessageEntity(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      text: event.text,
      isMe: true,
      time: DateTime.now(),
    );
    emit(state.copyWith(messages: List.from(state.messages)..add(newMessage)));

    // Also send via WebSocket to the backend
    chatRemoteDataSource.sendMessage(
      event.receiverUid ?? '',
      event.text,
    );
  }

  Future<void> _onLocationShared(CompanionLocationShared event, Emitter<CompanionState> emit) async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      final newMessage = CompanionMessageEntity(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Shared location update: Current location shared with companions',
        isSystem: true,
        isLocation: true,
        latitude: position.latitude,
        longitude: position.longitude,
        time: DateTime.now(),
      );
      emit(state.copyWith(messages: List.from(state.messages)..add(newMessage)));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to get location: $e'));
    }
  }

  Future<void> _onAlertTriggered(CompanionAlertTriggered event, Emitter<CompanionState> emit) async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      final newMessage = CompanionMessageEntity(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        text: '🚨 EMERGENCY ALERT: User triggered an emergency alert!',
        isSystem: true,
        isLocation: true,
        latitude: position.latitude,
        longitude: position.longitude,
        time: DateTime.now(),
      );
      emit(state.copyWith(
        messages: List.from(state.messages)..add(newMessage),
        alertSent: true,
      ));
    } catch (e) {
      // Still send alert message even if location fails, just without coordinates
      final newMessage = CompanionMessageEntity(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        text: '🚨 EMERGENCY ALERT: User triggered an emergency alert!',
        isSystem: true,
        time: DateTime.now(),
      );
      emit(state.copyWith(
        messages: List.from(state.messages)..add(newMessage),
        alertSent: true,
      ));
    }
  }

  void _onResetAlert(CompanionResetAlert event, Emitter<CompanionState> emit) {
    emit(state.copyWith(alertSent: false));
  }

  void _onResetError(CompanionResetError event, Emitter<CompanionState> emit) {
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> _onStarted(CompanionStarted event, Emitter<CompanionState> emit) async {
    add(const TrustedContactsRequested());
    
    // Connect to chat
    await chatRemoteDataSource.connect();
    _chatSubscription?.cancel();
    _chatSubscription = chatRemoteDataSource.messageStream.listen((msg) {
      add(CompanionMessageReceived(msg));
    });

    final result = await getActiveJourney();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (session) {
        if (session != null) {
          emit(state.copyWith(activeJourney: session));
          _startLocationTimer();
        }
      },
    );
  }

  Future<void> _onContactsRequested(TrustedContactsRequested event, Emitter<CompanionState> emit) async {
    emit(state.copyWith(isLoadingContacts: true));
    final result = await getTrustedContacts();
    result.fold(
      (failure) => emit(state.copyWith(isLoadingContacts: false, errorMessage: failure.message)),
      (contacts) => emit(state.copyWith(isLoadingContacts: false, contacts: contacts)),
    );
  }

  Future<void> _onContactAdded(TrustedContactAdded event, Emitter<CompanionState> emit) async {
    emit(state.copyWith(isLoadingContacts: true));
    final result = await addTrustedContact(TrustedContactEntity(
      id: '', 
      userId: '', 
      contactName: event.contactName,
      contactPhone: event.contactPhone,
      relationship: event.relationship,
      contactEmail: event.contactEmail,
      isActive: true,
      createdAt: DateTime.now(),
    ));
    result.fold(
      (failure) => emit(state.copyWith(isLoadingContacts: false, errorMessage: failure.message)),
      (_) => add(const TrustedContactsRequested()),
    );
  }

  Future<void> _onContactUpdated(TrustedContactUpdated event, Emitter<CompanionState> emit) async {
    emit(state.copyWith(isLoadingContacts: true));
    final result = await updateTrustedContact(event.contact);
    result.fold(
      (failure) => emit(state.copyWith(isLoadingContacts: false, errorMessage: failure.message)),
      (_) => add(const TrustedContactsRequested()),
    );
  }

  Future<void> _onContactDeleted(TrustedContactDeleted event, Emitter<CompanionState> emit) async {
    emit(state.copyWith(isLoadingContacts: true));
    final result = await deleteTrustedContact(event.id);
    result.fold(
      (failure) => emit(state.copyWith(isLoadingContacts: false, errorMessage: failure.message)),
      (_) {
        final updatedSelection = Set<String>.from(state.selectedContactIds);
        updatedSelection.remove(event.id);
        emit(state.copyWith(selectedContactIds: updatedSelection));
        add(const TrustedContactsRequested());
      },
    );
  }

  void _onContactToggled(TrustedContactToggled event, Emitter<CompanionState> emit) {
    final updatedSelection = Set<String>.from(state.selectedContactIds);
    if (updatedSelection.contains(event.contactId)) {
      updatedSelection.remove(event.contactId);
    } else if (updatedSelection.length < 3) {
      updatedSelection.add(event.contactId);
    }
    emit(state.copyWith(selectedContactIds: updatedSelection));
  }

  Future<void> _onJourneyStartRequested(JourneyStartRequested event, Emitter<CompanionState> emit) async {
    if (state.selectedContactIds.isEmpty) return;

    final hasPermission = await LocationUtils.checkAndRequestPermission();
    if (!hasPermission) {
      emit(state.copyWith(errorMessage: 'Location permission required'));
      return;
    }

    emit(state.copyWith(isStartingJourney: true));
    
    try {
      final position = await LocationUtils.getCurrentPosition();
      final result = await startJourney(
        lat: position.latitude,
        lng: position.longitude,
        contactIds: state.selectedContactIds.toList(),
      );

      result.fold(
        (failure) => emit(state.copyWith(isStartingJourney: false, errorMessage: failure.message)),
        (session) {
          emit(state.copyWith(
            isStartingJourney: false,
            activeJourney: session,
            selectedContactIds: const {},
          ));
          _startLocationTimer();
        },
      );
    } catch (e) {
      emit(state.copyWith(isStartingJourney: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onJourneyLocationTick(JourneyLocationTick event, Emitter<CompanionState> emit) async {
    if (state.activeJourney == null || !state.activeJourney!.isActive) {
      _stopLocationTimer();
      return;
    }

    emit(state.copyWith(isUpdatingLocation: true));
    try {
      final position = await LocationUtils.getCurrentPosition();
      final result = await updateJourneyLocation(
        sessionId: state.activeJourney!.id,
        lat: position.latitude,
        lng: position.longitude,
      );

      result.fold(
        (failure) => emit(state.copyWith(isUpdatingLocation: false, errorMessage: failure.message)),
        (_) => emit(state.copyWith(isUpdatingLocation: false)),
      );
    } catch (e) {
      emit(state.copyWith(isUpdatingLocation: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onJourneyEndRequested(JourneyEndRequested event, Emitter<CompanionState> emit) async {
    if (state.activeJourney == null) return;

    emit(state.copyWith(isEndingJourney: true));
    final result = await endJourney(sessionId: state.activeJourney!.id);

    result.fold(
      (failure) => emit(state.copyWith(isEndingJourney: false, errorMessage: failure.message)),
      (_) {
        _stopLocationTimer();
        emit(state.copyWith(
          isEndingJourney: false,
          clearActiveJourney: true,
        ));
      },
    );
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(const JourneyLocationTick());
    });
  }

  void _stopLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  Future<void> close() {
    _stopLocationTimer();
    _chatSubscription?.cancel();
    chatRemoteDataSource.disconnect();
    return super.close();
  }
}
