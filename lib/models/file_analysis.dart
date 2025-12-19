enum FileRiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case FileRiskLevel.low:
        return 'Rendah';
      case FileRiskLevel.medium:
        return 'Sederhana';
      case FileRiskLevel.high:
        return 'Tinggi';
    }
  }

  String get description {
    switch (this) {
      case FileRiskLevel.low:
        return 'Fail kelihatan selamat';
      case FileRiskLevel.medium:
        return 'Fail mengandungi risiko sederhana';
      case FileRiskLevel.high:
        return 'Fail berbahaya - jangan buka!';
    }
  }
}

enum ScamType {
  none,
  bank,
  police,
  parcel,
  family,
  investment,
  other;

  String get displayName {
    switch (this) {
      case ScamType.none:
        return 'Tiada';
      case ScamType.bank:
        return 'Penipuan Bank';
      case ScamType.police:
        return 'Penipuan Polis';
      case ScamType.parcel:
        return 'Penipuan Pos';
      case ScamType.family:
        return 'Penipuan Keluarga';
      case ScamType.investment:
        return 'Penipuan Pelaburan';
      case ScamType.other:
        return 'Lain-lain';
    }
  }
}

enum FileType {
  apk,
  pdf,
  doc,
  xls,
  img,
  other;

  String get displayName {
    switch (this) {
      case FileType.apk:
        return 'APK (Android App)';
      case FileType.pdf:
        return 'PDF Document';
      case FileType.doc:
        return 'Word Document';
      case FileType.xls:
        return 'Excel Spreadsheet';
      case FileType.img:
        return 'Image';
      case FileType.other:
        return 'Other';
    }
  }
}

enum SourceApp {
  whatsapp,
  telegram,
  browser,
  sms,
  email,
  other;

  String get displayName {
    switch (this) {
      case SourceApp.whatsapp:
        return 'WhatsApp';
      case SourceApp.telegram:
        return 'Telegram';
      case SourceApp.browser:
        return 'Web Browser';
      case SourceApp.sms:
        return 'SMS';
      case SourceApp.email:
        return 'Email';
      case SourceApp.other:
        return 'Other';
    }
  }
}

class FileAnalysis {
  final String id;
  final String fileName;
  final FileType fileType;
  final SourceApp sourceApp;
  final List<String> permissions;
  final FileRiskLevel riskLevel;
  final ScamType scamType;
  final int confidence;
  final String reason;
  final String recommendedAction;
  final List<String> warningSigns;
  final DateTime timestamp;
  final String analysisModel;

  const FileAnalysis({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.sourceApp,
    required this.permissions,
    required this.riskLevel,
    required this.scamType,
    required this.confidence,
    required this.reason,
    required this.recommendedAction,
    required this.warningSigns,
    required this.timestamp,
    required this.analysisModel,
  });

  factory FileAnalysis.fromJson(Map<String, dynamic> json) {
    return FileAnalysis(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['fileType'],
        orElse: () => FileType.other,
      ),
      sourceApp: SourceApp.values.firstWhere(
        (e) => e.name == json['sourceApp'],
        orElse: () => SourceApp.other,
      ),
      permissions: List<String>.from(json['permissions'] as List),
      riskLevel: FileRiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => FileRiskLevel.low,
      ),
      scamType: ScamType.values.firstWhere(
        (e) => e.name == json['scamType'],
        orElse: () => ScamType.none,
      ),
      confidence: json['confidence'] as int,
      reason: json['reason'] as String,
      recommendedAction: json['recommendedAction'] as String,
      warningSigns: List<String>.from(json['warningSigns'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysisModel: json['analysisModel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileType': fileType.name,
      'sourceApp': sourceApp.name,
      'permissions': permissions,
      'riskLevel': riskLevel.name,
      'scamType': scamType.name,
      'confidence': confidence,
      'reason': reason,
      'recommendedAction': recommendedAction,
      'warningSigns': warningSigns,
      'timestamp': timestamp.toIso8601String(),
      'analysisModel': analysisModel,
    };
  }
}