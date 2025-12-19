import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/file_analysis.dart';
import '../constants/app_constants.dart';

class FileAnalysisService {
  static const String _apiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';

  // Sample dangerous file scenarios for demo
  static const List<Map<String, dynamic>> _sampleFiles = [
    {
      'fileName': 'Maybank_Security_Update.apk',
      'fileType': 'apk',
      'sourceApp': 'whatsapp',
      'permissions': ['camera', 'location', 'contacts', 'sms', 'storage'],
      'riskLevel': 'high',
      'scamType': 'bank',
      'confidence': 95,
      'reason': 'Nama fail meniru bank rasmi Malaysia dan meminta terlalu banyak kebenaran berbahaya.',
      'recommendedAction': 'PADAM fail ini segera. Jangan install. Hubungi Maybank secara langsung.',
      'warningSigns': [
        'Nama bank palsu',
        'Meminta kebenaran kamera/SMS',
        'Dihantar melalui WhatsApp',
        'Tiada sumber rasmi'
      ]
    },
    {
      'fileName': 'Polis_Saman_Trafik.pdf',
      'fileType': 'pdf',
      'sourceApp': 'telegram',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'police',
      'confidence': 88,
      'reason': 'Dokumen palsu yang mengaku saman trafik untuk menakut-nakutkan mangsa.',
      'recommendedAction': 'Jangan buka fail. Semak saman trafik melalui portal MyEG atau JPJ rasmi.',
      'warningSigns': [
        'Mengaku dari polis',
        'Dihantar melalui Telegram',
        'Mengancam tindakan undang-undang',
        'Tiada nombor rujukan sah'
      ]
    },
    {
      'fileName': 'PosLaju_Package_Delivery.docx',
      'fileType': 'doc',
      'sourceApp': 'email',
      'permissions': [],
      'riskLevel': 'medium',
      'scamType': 'parcel',
      'confidence': 72,
      'reason': 'Dokumen yang kelihatan seperti notifikasi penghantaran tetapi mungkin mengandungi malware.',
      'recommendedAction': 'Semak nombor tracking di laman web PosLaju rasmi. Jangan buka jika tidak dijangka.',
      'warningSigns': [
        'Nama syarikat penghantaran',
        'Dihantar melalui email',
        'Meminta untuk download fail',
        'Tiada nombor tracking yang sah'
      ]
    },
    {
      'fileName': 'Investment_Return_10x.xlsx',
      'fileType': 'xls',
      'sourceApp': 'browser',
      'permissions': [],
      'riskLevel': 'high',
      'scamType': 'investment',
      'confidence': 91,
      'reason': 'Tawaran pelaburan dengan pulangan tidak realistik (10x) adalah ciri-ciri penipuan pelaburan.',
      'recommendedAction': 'Jangan percaya tawaran pelaburan dengan pulangan tinggi. Laporkan kepada Suruhanjaya Sekuriti.',
      'warningSigns': [
        'Pulangan pelaburan tidak realistik',
        'Nama fail menggiurkan',
        'Dari sumber tidak diketahui',
        'Janji kaya cepat'
      ]
    },
    {
      'fileName': 'Family_Emergency_Contact.jpg',
      'fileType': 'img',
      'sourceApp': 'sms',
      'permissions': [],
      'riskLevel': 'medium',
      'scamType': 'family',
      'confidence': 65,
      'reason': 'Gambar yang mungkin digunakan untuk penipuan kecemasan keluarga.',
      'recommendedAction': 'Hubungi ahli keluarga terbabit secara langsung untuk mengesahkan.',
      'warningSigns': [
        'Menggunakan nama keluarga',
        'Dihantar melalui SMS',
        'Mungkin untuk penipuan kecemasan',
        'Tiada konteks yang jelas'
      ]
    },
    {
      'fileName': 'Company_Report_2024.pdf',
      'fileType': 'pdf',
      'sourceApp': 'email',
      'permissions': [],
      'riskLevel': 'low',
      'scamType': 'none',
      'confidence': 15,
      'reason': 'Nama fail kelihatan profesional dan tiada tanda-tanda mencurigakan.',
      'recommendedAction': 'Pastikan penghantar adalah kenalan yang dikenali sebelum membuka.',
      'warningSigns': []
    }
  ];

  /// Analyze file using ILMU-text-free-safe model
  Future<FileAnalysis> analyzeFile({
    required String fileName,
    required FileType fileType,
    required SourceApp sourceApp,
    List<String> permissions = const [],
  }) async {
    try {
      // In production, this would call the actual ILMU API
      // For demo, we'll use mock analysis based on file patterns
      return await _mockAnalysis(fileName, fileType, sourceApp, permissions);
    } catch (e) {
      throw Exception('Gagal menganalisis fail: $e');
    }
  }

  /// Mock analysis for demo purposes
  Future<FileAnalysis> _mockAnalysis(
    String fileName,
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
          analysisModel: 'ILMU-text-free-safe (Demo Mode)',
        );
      }
    }

    // General pattern analysis
    FileRiskLevel riskLevel = FileRiskLevel.low;
    ScamType scamType = ScamType.none;
    int confidence = 20;
    String reason = 'Fail kelihatan normal dan tiada tanda-tanda penipuan yang jelas.';
    String recommendedAction = 'Sentiasa berwaspada apabila menerima fail dari sumber tidak diketahui.';
    List<String> warningSigns = [];

    // Check for suspicious patterns
    final suspiciousKeywords = {
      'bank': ['bank', 'maybank', 'cimb', 'public bank', 'rhb', 'hsbc'],
      'police': ['polis', 'jpj', 'kdn', 'macc', 'pdrm'],
      'pos': ['poslaju', 'gdex', 'j&t', 'dhl'],
      'investment': ['investment', 'pelaburan', 'return', 'profit', 'bonus'],
      'security': ['security', 'update', 'patch', 'verification'],
      'urgent': ['urgent', 'segera', 'immediate', 'pantas'],
      'money': ['money', 'wang', 'payment', 'bayaran', 'claim'],
    };

    // Check file name for suspicious keywords
    for (final entry in suspiciousKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerFileName.contains(keyword)) {
          confidence += 15;
          warningSigns.add('Mengandungi kata kunci mencurigakan: "$keyword"');
          
          switch (entry.key) {
            case 'bank':
              scamType = ScamType.bank;
              break;
            case 'police':
              scamType = ScamType.police;
              break;
            case 'pos':
              scamType = ScamType.parcel;
              break;
            case 'investment':
              scamType = ScamType.investment;
              break;
          }
        }
      }
    }

    // Check file type risk
    if (fileType == FileType.apk) {
      confidence += 30;
      warningSigns.add('Fail APK boleh mengandungi malware');
      if (sourceApp != SourceApp.browser) {
        confidence += 20;
        warningSigns.add('APK dikongsi melalui messaging app (berisiko tinggi)');
      }
    }

    // Check permissions for APK
    if (fileType == FileType.apk && permissions.isNotEmpty) {
      final dangerousPermissions = [
        'camera', 'location', 'contacts', 'sms', 'call_log', 
        'microphone', 'storage', 'phone'
      ];
      
      for (final permission in permissions) {
        if (dangerousPermissions.contains(permission.toLowerCase())) {
          confidence += 10;
          warningSigns.add('Meminta kebenaran berbahaya: $permission');
        }
      }
    }

    // Check source app risk
    if (sourceApp == SourceApp.sms || sourceApp == SourceApp.telegram) {
      confidence += 10;
      warningSigns.add('Dihantar melalui sumber kurang selamat');
    }

    // Determine final risk level
    if (confidence >= 80) {
      riskLevel = FileRiskLevel.high;
      reason = 'Fail menunjukkan banyak tanda-tanda penipuan dan berbahaya.';
      recommendedAction = 'JANGAN buka atau install fail ini. Padam segera dan laporkan.';
    } else if (confidence >= 50) {
      riskLevel = FileRiskLevel.medium;
      reason = 'Fail mengandungi elemen mencurigakan dan perlu berhati-hati.';
      recommendedAction = 'Semak sumber fail dengan teliti sebelum membuka.';
    } else {
      riskLevel = FileRiskLevel.low;
      reason = 'Fail kelihatan selamat, tetapi sentiasa berwaspada.';
      recommendedAction = 'Pastikan fail dari sumber yang dipercayai.';
    }

    return FileAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
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
      analysisModel: 'ILMU-text-free-safe (Demo Mode)',
    );
  }

  /// Get sample files for demo
  List<Map<String, dynamic>> getSampleFiles() {
    return _sampleFiles;
  }

  /// Backend request payload for ILMU-text-free-safe model
  Map<String, dynamic> createILMUFileAnalysisPayload({
    required String fileName,
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
          'content': '''Anda adalah ILMU, AI assistant dari Malaysia yang pakar dalam mengesan penipuan dalam fail.

Analisis maklumat fail ini dan berikan penilaian risiko dalam konteks Malaysia:

Kriteria analisis:
- Nama fail yang mencurigakan
- Jenis fail berisiko (APK, PDF, DOC)
- Sumber aplikasi (WhatsApp, Telegram, dll)
- Kebenaran yang diminta (untuk APK)

Kategorikan penipuan:
- none: Tiada penipuan
- bank: Penipuan bank
- police: Penipuan polis/kerajaan
- parcel: Penipuan pos/penghantaran
- family: Penipuan keluarga/kecemasan
- investment: Penipuan pelaburan
- other: Lain-lain

Berikan jawapan dalam format JSON:
{
  "risk_level": "low|medium|high",
  "scam_type": "none|bank|police|parcel|family|investment|other",
  "confidence": 0-100,
  "reason": "...",
  "recommended_action": "..."
}

Gunakan Bahasa Malaysia dalam analisis anda.'''
        },
        {
          'role': 'user',
          'content': '''Analisis fail ini:
Nama Fail: $fileName
Jenis Fail: ${fileType.displayName}
Sumber: ${sourceApp.displayName}
${permissions.isNotEmpty ? 'Kebenaran: ${permissions.join(", ")}' : 'Tiada kebenaran (bukan APK)'}'''
        }
      ],
      'max_tokens': 300,
      'temperature': 0.2
    };
  }
}