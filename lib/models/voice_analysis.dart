enum VoiceRiskLevel {
  safe,
  suspicious,
  highRisk,
  scam;

  String get displayName {
    switch (this) {
      case VoiceRiskLevel.safe:
        return 'Safe';
      case VoiceRiskLevel.suspicious:
        return 'Suspicious';
      case VoiceRiskLevel.highRisk:
        return 'High Risk';
      case VoiceRiskLevel.scam:
        return 'Scam';
    }
  }

  String get description {
    switch (this) {
      case VoiceRiskLevel.safe:
        return 'No scam indicators detected in voice pattern';
      case VoiceRiskLevel.suspicious:
        return 'Some suspicious elements detected, proceed with caution';
      case VoiceRiskLevel.highRisk:
        return 'Multiple scam indicators detected, be very careful';
      case VoiceRiskLevel.scam:
        return 'Clear scam pattern detected - end the call immediately';
    }
  }
}

enum VoiceScamType {
  none,
  impersonation,
  urgency,
  emotionalManipulation,
  financialRequest,
  threat,
  other;

  String get displayName {
    switch (this) {
      case VoiceScamType.none:
        return 'None';
      case VoiceScamType.impersonation:
        return 'Authority Impersonation';
      case VoiceScamType.urgency:
        return 'Urgency Tactics';
      case VoiceScamType.emotionalManipulation:
        return 'Emotional Manipulation';
      case VoiceScamType.financialRequest:
        return 'Financial Request';
      case VoiceScamType.threat:
        return 'Threats';
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
  final String recommendedAction;
  final String disclaimer;
  final DateTime timestamp;
  final String analysisModel;
  final bool isDemoMode;

  const VoiceAnalysis({
    required this.id,
    required this.transcript,
    required this.riskLevel,
    required this.scamType,
    required this.confidenceScore,
    required this.linguisticRedFlags,
    required this.behavioralRedFlags,
    required this.recommendedAction,
    required this.disclaimer,
    required this.timestamp,
    required this.analysisModel,
    required this.isDemoMode,
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
      linguisticRedFlags: List<String>.from(json['linguisticRedFlags'] as List),
      behavioralRedFlags: List<String>.from(json['behavioralRedFlags'] as List),
      recommendedAction: json['recommendedAction'] as String,
      disclaimer: json['disclaimer'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysisModel: json['analysisModel'] as String,
      isDemoMode: json['isDemoMode'] as bool,
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
      'recommendedAction': recommendedAction,
      'disclaimer': disclaimer,
      'timestamp': timestamp.toIso8601String(),
      'analysisModel': analysisModel,
      'isDemoMode': isDemoMode,
    };
  }
}