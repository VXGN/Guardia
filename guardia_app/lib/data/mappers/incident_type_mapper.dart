class IncidentTypeMapper {
  static const Set<String> _backendEnums = {
    'verbal_harassment',
    'physical_harassment',
    'stalking',
    'theft',
    'intimidation',
    'other',
  };

  static const Map<String, String> _uiToBackend = {
    'harassment': 'physical_harassment',
    'suspicious activity': 'stalking',
    'poor lighting': 'other',
    'verbal abuse': 'verbal_harassment',
    'medical issue': 'other',
    'other': 'other',
  };

  static String toBackend(String input) {
    final normalized = input.trim().toLowerCase();

    if (_backendEnums.contains(normalized)) {
      return normalized;
    }

    final mapped = _uiToBackend[normalized];
    if (mapped != null) {
      return mapped;
    }

    throw FormatException('Unsupported incident type: $input');
  }
}