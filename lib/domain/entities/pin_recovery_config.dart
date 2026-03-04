/// Configuration for PIN recovery via security question and backup codes.
class PinRecoveryConfig {
  const PinRecoveryConfig({
    required this.securityQuestion,
    required this.securityAnswerHash,
    required this.backupCodes,
    required this.backupCodesUsed,
    this.createdAt,
  });

  /// The security question (plaintext, shown to user)
  final String securityQuestion;

  /// BCrypt hash of the answer (case-insensitive lowercase)
  final String securityAnswerHash;

  /// List of backup codes (hashed, one-time use)
  final List<String> backupCodes;

  /// Track which backup codes have been used/redeemed
  final List<bool> backupCodesUsed;

  /// When this recovery config was created (for potential rotation)
  final DateTime? createdAt;

  /// Check if all backup codes have been used
  bool get allCodesUsed => backupCodesUsed.every((used) => used);

  /// Get count of remaining unused codes
  int get remainingCodes =>
      backupCodesUsed.where((used) => !used).length;

  /// Get the first unused code index, or null if all used
  int? getFirstUnusedCodeIndex() {
    try {
      return backupCodesUsed.indexWhere((used) => !used);
    } catch (_) {
      return null;
    }
  }

  PinRecoveryConfig copyWith({
    String? securityQuestion,
    String? securityAnswerHash,
    List<String>? backupCodes,
    List<bool>? backupCodesUsed,
    DateTime? createdAt,
  }) {
    return PinRecoveryConfig(
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
      backupCodes: backupCodes ?? this.backupCodes,
      backupCodesUsed: backupCodesUsed ?? this.backupCodesUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => '''PinRecoveryConfig(
    question: $securityQuestion,
    remaining codes: $remainingCodes/${backupCodes.length},
    createdAt: $createdAt
  )''';
}

/// Default security questions suitable for parents of children
const defaultSecurityQuestions = <String>[
  'Vad är ditt barns favoritfärg?',
  'I vilken stad är du född?',
  'Vad heter ditt favoritdjur?',
  'Vilket är ditt favoritår för semestern?',
  'Vad är namnet på ditt första husdjur?',
  'I vilken månad är du född?',
  'Vad är ditt favoritfilmgenre?',
  'Vilket sport är ditt favoritlag?',
  'Vad är namnet på ditt favoritmat?',
  'I vilken åttonde födelsedag hände något minnes värdigt?',
];
