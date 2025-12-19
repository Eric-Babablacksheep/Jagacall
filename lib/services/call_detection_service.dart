import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/call_analysis.dart';
import '../constants/app_constants.dart';

class CallDetectionService {
  static const String _baseUrl = 'https://api.ilmu.ai.my';
  static const String _apiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';

  // Sample Manglish and Bahasa Malaysia scam transcripts for demo
  static const List<Map<String, String>> _sampleTranscripts = [
    {
      'text': 'Selamat pagi, saya dari Bank Negara. Akaun anda ada masalah dan perlu dikemas kini segera. Sila berikan nombor IC anda untuk pengesahan.',
      'title': 'Bank Impersonation Scam',
      'description': 'Caller claims to be from Bank Negara and requests personal information',
      'category': 'bankImpersonation',
      'risk': 'scam'
    },
    {
      'text': 'Tahniah! Anda telah menangi Toyota Vios dalam cabutan bertuah kami. Sila bayar yuran proses RM500 untuk mengclaim hadiah anda.',
      'title': 'Lottery Scam',
      'description': 'Fake lottery win requiring upfront payment for processing fees',
      'category': 'lotteryScam',
      'risk': 'scam'
    },
    {
      'text': 'Hello, saya dari Microsoft. Komputer anda ada virus dan kami perlu akses remote untuk fix. Segera call balik nombor ini.',
      'title': 'Tech Support Scam',
      'description': 'Fake technical support requesting remote access to computer',
      'category': 'techSupport',
      'risk': 'highRisk'
    },
    {
      'text': 'Anak anda ada dengan kami. Kalau mahu anak anda selamat, sila hantar RM50,000 ke akaun ini dalam masa 2 jam.',
      'title': 'Kidnapping Scam',
      'description': 'False kidnapping threat demanding immediate ransom payment',
      'category': 'kidnapping',
      'risk': 'scam'
    },
    {
      'text': 'Saya encik Ahmad dari LHDN. Anda ada tunggakan cukai dan perlu bayar sekarang atau akan ditangkap.',
      'title': 'Tax Authority Impersonation',
      'description': 'Caller claims to be from LHDN threatening arrest for unpaid taxes',
      'category': 'governmentImpersonation',
      'risk': 'scam'
    },
    {
      'text': 'Hai, saya nak tanya pasal promotion bank kita. Ada interest rendah untuk personal loan. Berminat tak?',
      'title': 'Legitimate Telemarketing',
      'description': 'Normal promotional call about banking services (safe example)',
      'category': 'other',
      'risk': 'safe'
    }
  ];

  /// Analyze call transcript using ILMU-text model
  Future<CallAnalysis> analyzeCallTranscript(String transcript) async {
    try {
      // In production, this would call the actual ILMU API
      // For demo, we'll use mock analysis
      return await _mockAnalysis(transcript);
    } catch (e) {
      throw Exception('Gagal menganalisis panggilan: $e');
    }
  }

  /// Mock analysis for demo purposes
  Future<CallAnalysis> _mockAnalysis(String transcript) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final lowerTranscript = transcript.toLowerCase();
    CallRiskLevel riskLevel = CallRiskLevel.safe;
    ScamCategory category = ScamCategory.other;
    double confidenceScore = 0.5;
    List<String> warningSigns = [];
    List<String> recommendedActions = [];

    // Bank impersonation detection
    if (lowerTranscript.contains('bank') || lowerTranscript.contains('akaun')) {
      if (lowerTranscript.contains('masalah') || lowerTranscript.contains('sekat')) {
        riskLevel = CallRiskLevel.scam;
        category = ScamCategory.bankImpersonation;
        confidenceScore = 0.95;
        warningSigns.addAll([
          'Claims to be from bank',
          'Threatens bank account',
          'Requests personal information'
        ]);
        recommendedActions.addAll([
          'Do not provide any information',
          'End the call immediately',
          'Call bank directly using official number',
          'Report to Bank Negara'
        ]);
      }
    }

    // Lottery scam detection
    if (lowerTranscript.contains('menang') || lowerTranscript.contains('hadiah')) {
      if (lowerTranscript.contains('bayar') || lowerTranscript.contains('yuran')) {
        riskLevel = CallRiskLevel.scam;
        category = ScamCategory.lotteryScam;
        confidenceScore = 0.92;
        warningSigns.addAll([
          'Announces winnings',
          'Requests upfront payment',
          'Offer too good to be true'
        ]);
        recommendedActions.addAll([
          'Do not pay any fees',
          'End the call',
          'Verify with relevant parties directly'
        ]);
      }
    }

    // Government impersonation
    if (lowerTranscript.contains('kerajaan') || lowerTranscript.contains('lhdn') || 
        lowerTranscript.contains('polis') || lowerTranscript.contains('kdn')) {
      if (lowerTranscript.contains('tangkap') || lowerTranscript.contains('tunggakan')) {
        riskLevel = CallRiskLevel.scam;
        category = ScamCategory.governmentImpersonation;
        confidenceScore = 0.88;
        warningSigns.addAll([
          'Claims to be from government agency',
          'Threatens legal action',
          'Requests immediate payment'
        ]);
        recommendedActions.addAll([
          'Do not panic',
          'Ask for reference number and officer name',
          'Call agency directly using official number',
          'Do not make any payments'
        ]);
      }
    }

    // Tech support scam
    if (lowerTranscript.contains('microsoft') || lowerTranscript.contains('virus') || 
        lowerTranscript.contains('komputer')) {
      if (lowerTranscript.contains('remote') || lowerTranscript.contains('akses')) {
        riskLevel = CallRiskLevel.highRisk;
        category = ScamCategory.techSupport;
        confidenceScore = 0.85;
        warningSigns.addAll([
          'Claims to be from tech company',
          'Requests remote access',
          'Threatens with technical issues'
        ]);
        recommendedActions.addAll([
          'Do not provide remote access',
          'End the call',
          'Scan computer with trusted antivirus'
        ]);
      }
    }

    // Kidnapping threat
    if (lowerTranscript.contains('anak') && lowerTranscript.contains('kami')) {
      if (lowerTranscript.contains('selamat') || lowerTranscript.contains('hantar')) {
        riskLevel = CallRiskLevel.scam;
        category = ScamCategory.kidnapping;
        confidenceScore = 0.98;
        warningSigns.addAll([
          'Threatens family member safety',
          'Requests ransom money',
          'Creates panic situation'
        ]);
        recommendedActions.addAll([
          'REMAIN CALM',
          'Do not give any money',
          'Try to contact the family member involved',
          'Report to police immediately (999)'
        ]);
      }
    }

    // Default safe call
    if (riskLevel == CallRiskLevel.safe) {
      confidenceScore = 0.15;
      recommendedActions.addAll([
        'Continue conversation cautiously',
        'Do not provide sensitive information',
        'Record call if necessary'
      ]);
    }

    return CallAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transcript: transcript,
      riskLevel: riskLevel,
      category: category,
      confidenceScore: confidenceScore,
      warningSigns: warningSigns,
      recommendedActions: recommendedActions,
      timestamp: DateTime.now(),
      analysisModel: 'ILMU-text (Demo Mode)',
    );
  }

  /// Get sample transcripts for demo
  List<Map<String, String>> getSampleTranscripts() {
    return _sampleTranscripts;
  }

  /// Backend request payload structure for ILMU API
  Map<String, dynamic> createILMUPayload(String transcript) {
    return {
      'model': 'ILMU-text',
      'api_key': _apiKey,
      'messages': [
        {
          'role': 'system',
          'content': '''Anda adalah ILMU, AI assistant dari Malaysia yang pakar dalam mengesan penipuan panggilan. 
          Analisis transkrip panggilan ini dan berikan penilaian risiko dalam konteks Malaysia.
          Kategorikan penipuan mengikut jenis biasa di Malaysia: bank impersonation, government impersonation, 
          lottery scam, tech support, love scam, investment scam, kidnapping, atau other.
          Berikan tanda-tanda amaran dan tindakan yang disyorkan dalam Bahasa Malaysia.'''
        },
        {
          'role': 'user',
          'content': 'Analisis transkrip panggilan ini: "$transcript"'
        }
      ],
      'max_tokens': 500,
      'temperature': 0.3
    };
  }
}