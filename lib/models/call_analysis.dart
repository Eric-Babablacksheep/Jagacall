enum CallRiskLevel {
  safe,
  suspicious,
  highRisk,
  scam;

  String get displayName {
    switch (this) {
      case CallRiskLevel.safe:
        return 'Selamat';
      case CallRiskLevel.suspicious:
        return 'Mencurigakan';
      case CallRiskLevel.highRisk:
        return 'Risiko Tinggi';
      case CallRiskLevel.scam:
        return 'Penipuan';
    }
  }

  String get description {
    switch (this) {
      case CallRiskLevel.safe:
        return 'Tiada tanda-tanda penipuan dikesan';
      case CallRiskLevel.suspicious:
        return 'Terdapat elemen yang mencurigakan, berhati-hati';
      case CallRiskLevel.highRisk:
        return 'Kemungkinan besar penipuan, disyorkan untuk tamatkan panggilan';
      case CallRiskLevel.scam:
        return 'Pasti penipuan - tamatkan panggilan segera!';
    }
  }
}

enum ScamCategory {
  bankImpersonation,
  governmentImpersonation,
  lotteryScam,
  techSupport,
  loveScam,
  investmentScam,
  kidnapping,
  other;

  String get displayName {
    switch (this) {
      case ScamCategory.bankImpersonation:
        return 'Penyamaran Bank';
      case ScamCategory.governmentImpersonation:
        return 'Penyamaran Kerajaan';
      case ScamCategory.lotteryScam:
        return 'Penipuan Hadiah';
      case ScamCategory.techSupport:
        return 'Sokongan Teknikal Palsu';
      case ScamCategory.loveScam:
        return 'Penipuan Cinta';
      case ScamCategory.investmentScam:
        return 'Penipuan Pelaburan';
      case ScamCategory.kidnapping:
        return 'Ancaman Penculikan';
      case ScamCategory.other:
        return 'Lain-lain';
    }
  }
}

class CallAnalysis {
  final String id;
  final String transcript;
  final CallRiskLevel riskLevel;
  final ScamCategory category;
  final double confidenceScore;
  final List<String> warningSigns;
  final List<String> recommendedActions;
  final DateTime timestamp;
  final String analysisModel;

  const CallAnalysis({
    required this.id,
    required this.transcript,
    required this.riskLevel,
    required this.category,
    required this.confidenceScore,
    required this.warningSigns,
    required this.recommendedActions,
    required this.timestamp,
    required this.analysisModel,
  });

  factory CallAnalysis.fromJson(Map<String, dynamic> json) {
    return CallAnalysis(
      id: json['id'] as String,
      transcript: json['transcript'] as String,
      riskLevel: CallRiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => CallRiskLevel.safe,
      ),
      category: ScamCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ScamCategory.other,
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      warningSigns: List<String>.from(json['warningSigns'] as List),
      recommendedActions: List<String>.from(json['recommendedActions'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysisModel: json['analysisModel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcript': transcript,
      'riskLevel': riskLevel.name,
      'category': category.name,
      'confidenceScore': confidenceScore,
      'warningSigns': warningSigns,
      'recommendedActions': recommendedActions,
      'timestamp': timestamp.toIso8601String(),
      'analysisModel': analysisModel,
    };
  }
}