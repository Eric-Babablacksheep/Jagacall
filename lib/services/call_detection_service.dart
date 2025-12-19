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
      'category': 'bankImpersonation',
      'risk': 'scam'
    },
    {
      'text': 'Tahniah! Anda telah menangi Toyota Vios dalam cabutan bertuah kami. Sila bayar yuran proses RM500 untuk mengclaim hadiah anda.',
      'category': 'lotteryScam',
      'risk': 'scam'
    },
    {
      'text': 'Hello, saya dari Microsoft. Komputer anda ada virus dan kami perlu akses remote untuk fix. Segera call balik nombor ini.',
      'category': 'techSupport',
      'risk': 'highRisk'
    },
    {
      'text': 'Anak anda ada dengan kami. Kalau mahu anak anda selamat, sila hantar RM50,000 ke akaun ini dalam masa 2 jam.',
      'category': 'kidnapping',
      'risk': 'scam'
    },
    {
      'text': 'Saya encik Ahmad dari LHDN. Anda ada tunggakan cukai dan perlu bayar sekarang atau akan ditangkap.',
      'category': 'governmentImpersonation',
      'risk': 'scam'
    },
    {
      'text': 'Hai, saya nak tanya pasal promotion bank kita. Ada interest rendah untuk personal loan. Berminat tak?',
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
          'Mengaku dari bank',
          'Mengancam akaun bank',
          'Meminta maklumat peribadi'
        ]);
        recommendedActions.addAll([
          'Jangan berikan sebarang maklumat',
          'Tamatkan panggilan segera',
          'Call bank secara langsung menggunakan nombor rasmi',
          'Laporkan kepada Bank Negara'
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
          'Mengumumkan kemenangan',
          'Meminta bayaran terlebih dahulu',
          'Tawaran yang terlalu baik untuk menjadi kenyataan'
        ]);
        recommendedActions.addAll([
          'Jangan bayar sebarang yuran',
          'Tamatkan panggilan',
          'Semak dengan pihak berkenaan secara langsung'
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
          'Mengaku dari agensi kerajaan',
          'Mengancam tindakan undang-undang',
          'Meminta pembayaran segera'
        ]);
        recommendedActions.addAll([
          'Jangan panik',
          'Minta nombor rujukan dan nama pegawai',
          'Call agensi berkenaan menggunakan nombor rasmi',
          'Jangan buat sebarang pembayaran'
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
          'Mengaku dari syarikat teknologi',
          'Meminta akses remote',
          'Mengancam dengan isu teknikal'
        ]);
        recommendedActions.addAll([
          'Jangan berikan akses remote',
          'Tamatkan panggilan',
          'Scan komputer dengan antivirus yang dipercayai'
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
          'Mengancam keselamatan ahli keluarga',
          'Meminta wang tebusan',
          'Mewujudkan keadaan panik'
        ]);
        recommendedActions.addAll([
          'KEKALKAN KETENANGAN',
          'Jangan berikan sebarang wang',
          'Cuba hubungi ahli keluarga terbabit',
          'Laporkan kepada polis segera (999)'
        ]);
      }
    }

    // Default safe call
    if (riskLevel == CallRiskLevel.safe) {
      confidenceScore = 0.15;
      recommendedActions.addAll([
        'Teruskan perbualan dengan berhati-hati',
        'Jangan berikan maklumat sensitif',
        'Rekodkan panggilan jika perlu'
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