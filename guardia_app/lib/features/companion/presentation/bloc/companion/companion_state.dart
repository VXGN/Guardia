part of 'companion_bloc.dart';

class CompanionState extends Equatable {
  final List<TrustedContactEntity> contacts;
  final Set<String> selectedContactIds;
  final JourneySessionEntity? activeJourney;
  final List<CompanionMessageEntity> messages;
  final bool isLoadingContacts;
  final bool isStartingJourney;
  final bool isUpdatingLocation;
  final bool isEndingJourney;
  final String? errorMessage;

  const CompanionState({
    this.contacts = const [],
    this.selectedContactIds = const {},
    this.activeJourney,
    this.messages = const [],
    this.isLoadingContacts = false,
    this.isStartingJourney = false,
    this.isUpdatingLocation = false,
    this.isEndingJourney = false,
    this.errorMessage,
  });

  bool get isJourneyActive => activeJourney != null && activeJourney!.isActive;
  bool get isLoading => isLoadingContacts || isStartingJourney || isEndingJourney;

  CompanionState copyWith({
    List<TrustedContactEntity>? contacts,
    Set<String>? selectedContactIds,
    JourneySessionEntity? activeJourney,
    List<CompanionMessageEntity>? messages,
    bool? isLoadingContacts,
    bool? isStartingJourney,
    bool? isUpdatingLocation,
    bool? isEndingJourney,
    String? errorMessage,
    bool clearActiveJourney = false,
    bool clearErrorMessage = false,
  }) {
    return CompanionState(
      contacts: contacts ?? this.contacts,
      selectedContactIds: selectedContactIds ?? this.selectedContactIds,
      activeJourney: clearActiveJourney ? null : (activeJourney ?? this.activeJourney),
      messages: messages ?? this.messages,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      isStartingJourney: isStartingJourney ?? this.isStartingJourney,
      isUpdatingLocation: isUpdatingLocation ?? this.isUpdatingLocation,
      isEndingJourney: isEndingJourney ?? this.isEndingJourney,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        contacts,
        selectedContactIds,
        activeJourney,
        messages,
        isLoadingContacts,
        isStartingJourney,
        isUpdatingLocation,
        isEndingJourney,
        errorMessage,
      ];
}
