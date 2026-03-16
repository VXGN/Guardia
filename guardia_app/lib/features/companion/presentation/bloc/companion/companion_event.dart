part of 'companion_bloc.dart';

abstract class CompanionEvent extends Equatable {
  const CompanionEvent();

  @override
  List<Object?> get props => [];
}

class CompanionStarted extends CompanionEvent {
  const CompanionStarted();
}

class TrustedContactsRequested extends CompanionEvent {
  const TrustedContactsRequested();
}

class TrustedContactAdded extends CompanionEvent {
  final String contactName;
  final String contactPhone;
  final String? relationship;
  final String? contactEmail;
  
  const TrustedContactAdded({
    required this.contactName,
    required this.contactPhone,
    this.relationship,
    this.contactEmail,
  });

  @override
  List<Object?> get props => [contactName, contactPhone, relationship, contactEmail];
}

class TrustedContactUpdated extends CompanionEvent {
  final TrustedContactEntity contact;
  const TrustedContactUpdated(this.contact);

  @override
  List<Object?> get props => [contact];
}

class TrustedContactDeleted extends CompanionEvent {
  final String id;
  const TrustedContactDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TrustedContactToggled extends CompanionEvent {
  final String contactId;
  const TrustedContactToggled(this.contactId);

  @override
  List<Object?> get props => [contactId];
}

class JourneyStartRequested extends CompanionEvent {
  const JourneyStartRequested();
}

class JourneyLocationTick extends CompanionEvent {
  const JourneyLocationTick();
}

class JourneyEndRequested extends CompanionEvent {
  const JourneyEndRequested();
}

class CompanionMessageSent extends CompanionEvent {
  final String text;
  final String? receiverUid;
  final bool isMe;
  const CompanionMessageSent({required this.text, this.receiverUid, this.isMe = true});

  @override
  List<Object?> get props => [text, receiverUid, isMe];
}

class CompanionMessageReceived extends CompanionEvent {
  final Map<String, dynamic> message;
  const CompanionMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanionConnectionChanged extends CompanionEvent {
  final bool isConnected;
  const CompanionConnectionChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class CompanionLocationShared extends CompanionEvent {
  const CompanionLocationShared();
}

class CompanionAlertTriggered extends CompanionEvent {
  const CompanionAlertTriggered();
}

class CompanionResetAlert extends CompanionEvent {
  const CompanionResetAlert();
}

class CompanionResetError extends CompanionEvent {
  const CompanionResetError();
}

class ChatHistoryRequested extends CompanionEvent {
  final String otherUid;
  const ChatHistoryRequested(this.otherUid);

  @override
  List<Object?> get props => [otherUid];
}
