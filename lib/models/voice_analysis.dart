enum VoiceRiskLevel {
  safe,
  suspicious,
  highRisk,
  scam;

  String get displayName {
    switch (this) {
      case VoiceRiskLevel.safe:
        return 'Low Risk';
      case VoiceRiskLevel.suspicious:
        return 'Suspicious';
      case VoiceRiskLevel.highRisk:
        return 'High Risk';
      case VoiceRiskLevel.scam:
        return 'Likely Voice Clone';
    }
  }

  String get description {
    switch (this) {
      case VoiceRiskLevel.safe:
        return 'Voice appears authentic with no deepfake indicators detected';
      case VoiceRiskLevel.suspicious:
        return 'Some unusual voice patterns detected - proceed with caution';
      case VoiceRiskLevel.highRisk:
        return 'Multiple deepfake indicators detected - verify identity immediately';
      case VoiceRiskLevel.scam:
        return 'High probability of voice cloning - end the call and verify through official channels';
    }
  }
}

enum VoiceScamType {
  none,
  familyEmergency,
  authorityImpersonation,
  bankVerification,
  other;

  String get displayName {
    switch (this) {
      case VoiceScamType.none:
        return 'None';
      case VoiceScamType.familyEmergency:
        return 'Fake Family Emergency';
      case VoiceScamType.authorityImpersonation:
        return 'Fake Authority Call';
      case VoiceScamType.bankVerification:
        return 'Fake Bank Verification';
      case VoiceScamType.other:
        return 'Other';
    }
  }
}

class VoiceAnalysis {
  final String id;
  final String transcript;
  final VoiceRiskLevel riskLevel;
  final VoiceScamType scamType;
  final double confidenceScore;
  final List<String> linguisticRedFlags;
  final List<String> behavioralRedFlags;
  final List<String> voiceIndicators;
  final String recommendedAction;
  final String disclaimer;
  final DateTime timestamp;
  final String analysisModel;
  final bool isDemoMode;
  final String? audioFilePath;
  final Duration? recordingDuration;

  const VoiceAnalysis({
    required this.id,
    required this.transcript,
    required this.riskLevel,
    required this.scamType,
    required this.confidenceScore,
    required this.linguisticRedFlags,
    required this.behavioralRedFlags,
    required this.voiceIndicators,
    required this.recommendedAction,
    required this.disclaimer,
    required this.timestamp,
    required this.analysisModel,
    required this.isDemoMode,
    this.audioFilePath,
    this.recordingDuration,
  });

  factory VoiceAnalysis.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysis(
      id: json['id'] as String,
      transcript: json['transcript'] as String,
      riskLevel: VoiceRiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => VoiceRiskLevel.safe,
      ),
      scamType: VoiceScamType.values.firstWhere(
        (e) => e.name == json['scamType'],
        orElse: () => VoiceScamType.none,
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      linguisticRedFlags: List<String>.from(json['linguisticRedFlags'] as List? ?? []),
      behavioralRedFlags: List<String>.from(json['behavioralRedFlags'] as List? ?? []),
      voiceIndicators: List<String>.from(json['voiceIndicators'] as List? ?? []),
      recommendedAction: json['recommendedAction'] as String,
      disclaimer: json['disclaimer'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysisModel: json['analysisModel'] as String,
      isDemoMode: json['isDemoMode'] as bool,
      audioFilePath: json['audioFilePath'] as String?,
      recordingDuration: json['recordingDuration'] != null
          ? Duration(seconds: json['recordingDuration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcript': transcript,
      'riskLevel': riskLevel.name,
      'scamType': scamType.name,
      'confidenceScore': confidenceScore,
      'linguisticRedFlags': linguisticRedFlags,
      'behavioralRedFlags': behavioralRedFlags,
      'voiceIndicators': voiceIndicators,
      'recommendedAction': recommendedAction,
      'disclaimer': disclaimer,
      'timestamp': timestamp.toIso8601String(),
      'analysisModel': analysisModel,
      'isDemoMode': isDemoMode,
      'audioFilePath': audioFilePath,
      'recordingDuration': recordingDuration?.inSeconds,
    };
  }
}