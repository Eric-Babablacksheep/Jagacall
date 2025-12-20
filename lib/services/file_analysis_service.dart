import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/file_analysis.dart';
import '../constants/app_constants.dart';

class FileAnalysisService {
  static const String _apiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';

  // Sample files for demo - including malicious file types
  static const List<Map<String, dynamic>> _sampleFiles = [
    {
      'fileName': 'Maybank_Security_Update.apk',
      'fileType': 'apk',
      'sourceApp': 'whatsapp',
      'permissions': ['camera', 'location', 'contacts', 'sms', 'storage'],
      'riskLevel': 'high',
      'scamType': 'bank',
      'confidence': 95,
      'reason': 'File name mimics official Malaysian bank and requests dangerous permissions.',
      'recommendedAction': 'DELETE this file immediately. Do not install. Contact Maybank directly.',
      'warningSigns': [
        'Fake bank name',
        'Requests camera/SMS permissions',
        'Sent via WhatsApp',
        'No official source'
      ],
      'malwareSignatures': ['Banking_Trojan_Gen1', 'Fake_Banking_App'],
      'suspiciousBehaviors': ['Requests sensitive permissions', 'Mimics official app'],
      'heuristicAnalysis': 'Executable from unknown source claiming to be banking security update'
    },
    {
      'fileName': 'System_Cleaner_Pro.exe',
      'fileType': 'exe',
      'sourceApp': 'browser',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'other',
      'confidence': 92,
      'reason': 'Executable file from unknown source with system optimization claims.',
      'recommendedAction': 'DELETE immediately. Never run executables from untrusted sources.',
      'warningSigns': [
        'Executable file type',
        'From unknown source',
        'Claims system optimization',
        'No digital signature'
      ],
      'malwareSignatures': ['Fake_System_Cleaner', 'PUP_Optimizer'],
      'suspiciousBehaviors': ['Claims system optimization', 'Requires admin privileges'],
      'heuristicAnalysis': 'Executable from unknown source commonly used in malware delivery'
    },
    {
      'fileName': 'Important_Document.zip',
      'fileType': 'zip',
      'sourceApp': 'email',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'other',
      'confidence': 85,
      'reason': 'Compressed file commonly used in malware delivery and phishing attacks.',
      'recommendedAction': 'Do not extract. Scan with antivirus first. Verify sender.',
      'warningSigns': [
        'Compressed file',
        'Vague file name',
        'Sent via email',
        'May contain malicious executables'
      ],
      'malwareSignatures': ['Zip_Bomb_Detected', 'Hidden_Executable'],
      'suspiciousBehaviors': ['Password protected archive', 'Multiple executable files'],
      'heuristicAnalysis': 'Compressed file commonly used in malware delivery'
    },
    {
      'fileName': 'Invoice_2024.js',
      'fileType': 'js',
      'sourceApp': 'email',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'other',
      'confidence': 90,
      'reason': 'JavaScript file that may execute malicious code when opened.',
      'recommendedAction': 'DELETE immediately. JavaScript files should not be sent as invoices.',
      'warningSigns': [
        'Script file type',
        'Disguised as document',
        'Can execute code',
        'Sent via email'
      ],
      'malwareSignatures': ['JS_Downloader', 'Script_Malware'],
      'suspiciousBehaviors': ['Script file with document name', 'May auto-execute'],
      'heuristicAnalysis': 'Script file disguised as business document'
    },
    {
      'fileName': 'Windows_Update.scr',
      'fileType': 'scr',
      'sourceApp': 'browser',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'other',
      'confidence': 94,
      'reason': 'Screensaver file claiming to be Windows update - classic malware disguise.',
      'recommendedAction': 'DELETE immediately. Windows updates come through official channels only.',
      'warningSigns': [
        'Screensaver file type',
        'Fake Windows update',
        'From browser download',
        'Executable disguised as update'
      ],
      'malwareSignatures': ['Fake_Windows_Update', 'Screensaver_Malware'],
      'suspiciousBehaviors': ['Disguised as system update', 'Screensaver extension'],
      'heuristicAnalysis': 'Executable file disguised as system update'
    },
    {
      'fileName': 'Company_Report_2024.pdf',
      'fileType': 'pdf',
      'sourceApp': 'email',
      'permissions': [],
      'riskLevel': 'low',
      'scamType': 'none',
      'confidence': 15,
      'reason': 'File name looks professional and no obvious scam signs.',
      'recommendedAction': 'Ensure sender is known contact before opening.',
      'warningSigns': [],
      'malwareSignatures': [],
      'suspiciousBehaviors': [],
      'heuristicAnalysis': 'Standard document file with no suspicious indicators'
    }
  ];

  /// Analyze file using ILMU-text-free-safe model
  Future<FileAnalysis> analyzeFile({
    required String fileName,
    String? filePath, // Added optional file path
    required FileType fileType,
    required SourceApp sourceApp,
    List<String> permissions = const [],
  }) async {
    try {
      // In production, this would call the actual ILMU API
      // For demo, we'll use mock analysis based on file patterns
      return await _mockAnalysis(fileName, filePath, fileType, sourceApp, permissions);
    } catch (e) {
      throw Exception('Failed to analyze file: $e');
    }
  }

  /// Mock analysis for demo purposes
  Future<FileAnalysis> _mockAnalysis(
    String fileName,
    String? filePath,
    FileType fileType,
    SourceApp sourceApp,
    List<String> permissions,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final lowerFileName = fileName.toLowerCase();
    
    // Check against sample files first
    for (final sample in _sampleFiles) {
      if (sample['fileName'].toString().toLowerCase() == lowerFileName) {
        return FileAnalysis(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: fileName,
          filePath: filePath, // Added file path
          fileType: fileType,
          sourceApp: sourceApp,
          permissions: permissions,
          riskLevel: FileRiskLevel.values.firstWhere(
            (e) => e.name == sample['riskLevel'],
          ),
          scamType: ScamType.values.firstWhere(
            (e) => e.name == sample['scamType'],
          ),
          confidence: sample['confidence'] as int,
          reason: sample['reason'] as String,
          recommendedAction: sample['recommendedAction'] as String,
          warningSigns: List<String>.from(sample['warningSigns'] as List),
          timestamp: DateTime.now(),
          analysisModel: 'ILMU-text-free-safe (Demo Analysis)',
          isPrototype: true,
          malwareSignatures: List<String>.from(sample['malwareSignatures'] as List? ?? []),
          suspiciousBehaviors: List<String>.from(sample['suspiciousBehaviors'] as List? ?? []),
          heuristicAnalysis: sample['heuristicAnalysis'] as String? ?? '',
          isExecutable: fileType.isExecutable,
          isCompressed: fileType.isCompressed,
          fileSource: sourceApp.displayName,
        );
      }
    }

    // Enhanced heuristic analysis for malware detection
    FileRiskLevel riskLevel = FileRiskLevel.low;
    ScamType scamType = ScamType.none;
    int confidence = 15;
    String reason = 'File appears safe with no obvious scam indicators.';
    String recommendedAction = 'File appears safe, but always verify the source.';
    List<String> warningSigns = [];
    List<String> malwareSignatures = [];
    List<String> suspiciousBehaviors = [];
    String heuristicAnalysis = '';

    // Check for suspicious keywords
    final suspiciousKeywords = [
      'urgent', 'immediate', 'action_required', 'suspended', 'blocked',
      'verify', 'security', 'account', 'bank', 'payment', 'winner',
      'lottery', 'prize', 'claim', 'emergency', 'family', 'police',
      'court', 'summons', 'tax', 'lhdn', 'kwsp', 'epf', 'crack', 'keygen',
      'patch', 'hack', 'activation', 'loader', 'installer'
    ];

    for (final keyword in suspiciousKeywords) {
      if (lowerFileName.contains(keyword)) {
        confidence += 10;
        warningSigns.add('Contains suspicious keyword: "$keyword"');
      }
    }

    // Enhanced file type risk assessment
    if (fileType.isHighRisk) {
      confidence += 40;
      warningSigns.add('High-risk executable file type');
      suspiciousBehaviors.add('File type commonly used in malware attacks');
      heuristicAnalysis = 'Executable from unknown source';
      
      // Add specific malware signatures based on file type
      if (fileType == FileType.exe) {
        malwareSignatures.add('PE_Executable_Detected');
        suspiciousBehaviors.add('Can execute arbitrary code');
        heuristicAnalysis = 'Executable from unknown source';
      } else if (fileType == FileType.scr) {
        malwareSignatures.add('Screensaver_Malware_Pattern');
        suspiciousBehaviors.add('Screensaver files often hide malware');
        heuristicAnalysis = 'Screensaver file can execute malicious code';
      } else if (fileType == FileType.dll) {
        malwareSignatures.add('Dynamic_Library_Inject');
        suspiciousBehaviors.add('Can be used for code injection');
        heuristicAnalysis = 'Dynamic library can be loaded by malicious processes';
      } else if (fileType == FileType.js) {
        malwareSignatures.add('JavaScript_Malware_Pattern');
        suspiciousBehaviors.add('Script can execute in browser or system');
        heuristicAnalysis = 'Script file can execute malicious code';
      } else if (fileType == FileType.vbs) {
        malwareSignatures.add('VBScript_Malware_Pattern');
        suspiciousBehaviors.add('Windows script can execute system commands');
        heuristicAnalysis = 'VBScript can execute system commands';
      } else if (fileType == FileType.iso) {
        malwareSignatures.add('Disk_Image_Mount');
        suspiciousBehaviors.add('Can contain malicious software bundles');
        heuristicAnalysis = 'Disk image can contain malicious software packages';
      }
    }

    if (fileType.isCompressed) {
      confidence += 25;
      warningSigns.add('Compressed file can hide malware');
      suspiciousBehaviors.add('Compressed files commonly used in malware delivery');
      heuristicAnalysis = 'Compressed file commonly used in malware delivery';
      
      if (fileType == FileType.zip) {
        malwareSignatures.add('Zip_Archive_Analyzed');
      } else if (fileType == FileType.rar) {
        malwareSignatures.add('Rar_Archive_Analyzed');
      }
    }

    if (fileType == FileType.apk) {
      confidence += 20;
      warningSigns.add('APK files can install malicious apps');
      suspiciousBehaviors.add('Android application package');
      heuristicAnalysis = 'Android application can request sensitive permissions';
      if (permissions.isNotEmpty) {
        confidence += 15;
        warningSigns.add('Requests permissions: ${permissions.join(", ")}');
        suspiciousBehaviors.add('Requests sensitive permissions');
        
        // Check for dangerous permissions
        final dangerousPermissions = ['camera', 'location', 'contacts', 'sms', 'call_log', 'microphone'];
        for (final permission in permissions) {
          if (dangerousPermissions.contains(permission)) {
            confidence += 5;
            malwareSignatures.add('Dangerous_Permission_${permission.toUpperCase()}');
          }
        }
      }
    }

    // Source app risk assessment
    if (sourceApp == SourceApp.whatsapp || sourceApp == SourceApp.telegram) {
      confidence += 15;
      warningSigns.add('File sent via messaging app');
      suspiciousBehaviors.add('Files from messaging apps often bypass security checks');
    } else if (sourceApp == SourceApp.browser) {
      confidence += 10;
      warningSigns.add('Downloaded from web browser');
      suspiciousBehaviors.add('Web downloads may lack verification');
    }

    // Determine final risk level
    if (confidence >= 70) {
      riskLevel = FileRiskLevel.high;
      reason = 'File shows multiple indicators of being a scam or malicious.';
      recommendedAction = 'Do not open this file. Delete immediately and report the sender.';
    } else if (confidence >= 40) {
      riskLevel = FileRiskLevel.medium;
      reason = 'File contains some suspicious elements that require caution.';
      recommendedAction = 'Exercise caution. Verify the sender through official channels.';
    }

    // Determine scam type based on keywords
    if (lowerFileName.contains('bank') || lowerFileName.contains('maybank') || 
        lowerFileName.contains('cimb') || lowerFileName.contains('public')) {
      scamType = ScamType.bank;
    } else if (lowerFileName.contains('polis') || lowerFileName.contains('court') || 
               lowerFileName.contains('summons') || lowerFileName.contains('jpj')) {
      scamType = ScamType.police;
    } else if (lowerFileName.contains('poslaju') || lowerFileName.contains('courier') || 
               lowerFileName.contains('delivery') || lowerFileName.contains('parcel')) {
      scamType = ScamType.parcel;
    } else if (lowerFileName.contains('family') || lowerFileName.contains('emergency') || 
               lowerFileName.contains('accident')) {
      scamType = ScamType.family;
    } else if (lowerFileName.contains('investment') || lowerFileName.contains('return') || 
               lowerFileName.contains('profit') || lowerFileName.contains('trading')) {
      scamType = ScamType.investment;
    }

    return FileAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      filePath: filePath, // Added file path
      fileType: fileType,
      sourceApp: sourceApp,
      permissions: permissions,
      riskLevel: riskLevel,
      scamType: scamType,
      confidence: confidence.clamp(0, 100),
      reason: reason,
      recommendedAction: recommendedAction,
      warningSigns: warningSigns,
      timestamp: DateTime.now(),
      analysisModel: 'ILMU-text-free-safe (Demo Analysis)',
      isPrototype: true,
      malwareSignatures: malwareSignatures,
      suspiciousBehaviors: suspiciousBehaviors,
      heuristicAnalysis: heuristicAnalysis.isNotEmpty
          ? heuristicAnalysis
          : 'No specific heuristic threats detected',
      isExecutable: fileType.isExecutable,
      isCompressed: fileType.isCompressed,
      fileSource: sourceApp.displayName,
    );
  }

  /// Get sample files for demo
  List<Map<String, dynamic>> getSampleFiles() {
    return _sampleFiles;
  }

  /// Backend request payload for ILMU-text-free-safe model
  Map<String, dynamic> createILMUFileAnalysisPayload({
    required String fileName,
    String? filePath, // Added optional file path
    required FileType fileType,
    required SourceApp sourceApp,
    List<String> permissions = const [],
  }) {
    return {
      'model': 'ILMU-text-free-safe',
      'api_key': _apiKey,
      'messages': [
        {
          'role': 'system',
          'content': '''You are ILMU, AI assistant from Malaysia that is expert in detecting scams in files.

Analyze this file information and provide risk assessment in Malaysian context:

Analysis criteria:
- Suspicious file names
- Risky file types (APK, PDF, DOC)
- Source application (WhatsApp, Telegram, etc.)
- Requested permissions (for APK)

Categorize scam:
- none: No scam
- bank: Bank scam
- police: Police/government scam
- parcel: Post/delivery scam
- family: Family/emergency scam
- investment: Investment scam
- other: Other

Provide answer in JSON format:
{
  "risk_level": "low|medium|high",
  "scam_type": "none|bank|police|parcel|family|investment|other",
  "confidence": 0-100,
  "reason": "...",
  "recommended_action": "..."
}

Use Bahasa Malaysia in your analysis.'''
        },
        {
          'role': 'user',
          'content': '''Analyze this file:
File Name: $fileName
File Type: ${fileType.displayName}
Source: ${sourceApp.displayName}
${permissions.isNotEmpty ? 'Permissions: ${permissions.join(", ")}' : 'No permissions (not APK)'}'''
        }
      ],
      'max_tokens': 300,
      'temperature': 0.2
    };
  }
}