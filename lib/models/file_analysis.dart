enum FileRiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case FileRiskLevel.low:
        return 'Low';
      case FileRiskLevel.medium:
        return 'Medium';
      case FileRiskLevel.high:
        return 'High';
    }
  }

  String get description {
    switch (this) {
      case FileRiskLevel.low:
        return 'File appears safe';
      case FileRiskLevel.medium:
        return 'File contains moderate risks';
      case FileRiskLevel.high:
        return 'File is dangerous - do not open!';
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
        return 'None';
      case ScamType.bank:
        return 'Bank Scam';
      case ScamType.police:
        return 'Police Scam';
      case ScamType.parcel:
        return 'Parcel Scam';
      case ScamType.family:
        return 'Family Scam';
      case ScamType.investment:
        return 'Investment Scam';
      case ScamType.other:
        return 'Other';
    }
  }
}

enum FileType {
  exe,
  scr,
  dll,
  js,
  vbs,
  zip,
  rar,
  apk,
  iso,
  img,
  pdf,
  doc,
  xls,
  other;

  String get displayName {
    switch (this) {
      case FileType.exe:
        return 'EXE (Executable)';
      case FileType.scr:
        return 'SCR (Screensaver)';
      case FileType.dll:
        return 'DLL (Dynamic Link Library)';
      case FileType.js:
        return 'JS (JavaScript)';
      case FileType.vbs:
        return 'VBS (VBScript)';
      case FileType.zip:
        return 'ZIP (Compressed)';
      case FileType.rar:
        return 'RAR (Compressed)';
      case FileType.apk:
        return 'APK (Android App)';
      case FileType.iso:
        return 'ISO (Disk Image)';
      case FileType.img:
        return 'IMG (Image File)';
      case FileType.pdf:
        return 'PDF Document';
      case FileType.doc:
        return 'Word Document';
      case FileType.xls:
        return 'Excel Spreadsheet';
      case FileType.other:
        return 'Other';
    }
  }

  bool get isHighRisk {
    return [
      FileType.exe, FileType.scr, FileType.dll,
      FileType.js, FileType.vbs, FileType.iso
    ].contains(this);
  }

  bool get isExecutable {
    return [
      FileType.exe, FileType.scr, FileType.dll,
      FileType.apk, FileType.js, FileType.vbs
    ].contains(this);
  }

  bool get isCompressed {
    return [FileType.zip, FileType.rar, FileType.iso].contains(this);
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
        return 'Other/Unknown';
    }
  }
}

class FileAnalysis {
  final String id;
  final String fileName;
  final String? filePath; // Added file path for deletion functionality
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
  final bool isPrototype;
  
  // Malware detection specific fields
  final List<String> malwareSignatures;
  final List<String> suspiciousBehaviors;
  final String heuristicAnalysis;
  final bool isExecutable;
  final bool isCompressed;
  final String fileSource;

  const FileAnalysis({
    required this.id,
    required this.fileName,
    this.filePath, // Optional file path
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
    this.isPrototype = true,
    this.malwareSignatures = const [],
    this.suspiciousBehaviors = const [],
    this.heuristicAnalysis = '',
    this.isExecutable = false,
    this.isCompressed = false,
    this.fileSource = '',
  });

  factory FileAnalysis.fromJson(Map<String, dynamic> json) {
    return FileAnalysis(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String?, // Added file path
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['fileType'],
        orElse: () => FileType.other,
      ),
      sourceApp: SourceApp.values.firstWhere(
        (e) => e.name == json['sourceApp'],
        orElse: () => SourceApp.other,
      ),
      permissions: List<String>.from(json['permissions'] as List? ?? []),
      riskLevel: FileRiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => FileRiskLevel.low,
      ),
      scamType: ScamType.values.firstWhere(
        (e) => e.name == json['scamType'],
        orElse: () => ScamType.none,
      ),
      confidence: json['confidence'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      recommendedAction: json['recommendedAction'] as String? ?? '',
      warningSigns: List<String>.from(json['warningSigns'] as List? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      analysisModel: json['analysisModel'] as String? ?? 'Unknown',
      isPrototype: json['isPrototype'] as bool? ?? true,
      malwareSignatures: List<String>.from(json['malwareSignatures'] as List? ?? []),
      suspiciousBehaviors: List<String>.from(json['suspiciousBehaviors'] as List? ?? []),
      heuristicAnalysis: json['heuristicAnalysis'] as String? ?? '',
      isExecutable: json['isExecutable'] as bool? ?? false,
      isCompressed: json['isCompressed'] as bool? ?? false,
      fileSource: json['fileSource'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath, // Added file path
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
      'isPrototype': isPrototype,
      'malwareSignatures': malwareSignatures,
      'suspiciousBehaviors': suspiciousBehaviors,
      'heuristicAnalysis': heuristicAnalysis,
      'isExecutable': isExecutable,
      'isCompressed': isCompressed,
      'fileSource': fileSource,
    };
  }
}