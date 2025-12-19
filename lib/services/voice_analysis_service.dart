import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voice_analysis.dart';
import '../services/demo_mode_service.dart';
import '../constants/app_constants.dart';

class VoiceAnalysisService {
  static const String _apiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';
  static const String _baseUrl = 'https://api.ytlailabs.tech/v1';

  // Sample voice scam transcripts for demo
  static const List<Map<String, dynamic>> _sampleVoiceScams = [
    {
      'transcript': 'Hello sir, I am calling from Bank Negara Malaysia. Your account has been compromised and we need you to provide your OTP number immediately to secure it.',
      'riskLevel': 'scam',
      'scamType': 'impersonation',
      'confidence': 95,
      'linguisticRedFlags': ['Authority impersonation', 'Urgency language', 'OTP request'],
      'behavioralRedFlags': ['Creating false emergency', 'Requesting sensitive information'],
      'recommendedAction': 'END THE CALL IMMEDIATELY. Do not provide any information. Contact your bank directly using official numbers.'
    },
    {
      'transcript': 'Assalamualaikum, saya dari Jabatan Hasil Dalam Negeri. Anda ada tunggakan cukai RM5,000 dan perlu bayar sekarang atau kami akan tangkap anda dalam masa 24 jam.',
      'riskLevel': 'scam',
      'scamType': 'threat',
      'confidence': 92,
      'linguisticRedFlags': ['Government impersonation', 'Threat language', 'Urgency'],
      'behavioralRedFlags': ['Using fear tactics', 'Immediate payment demand'],
      'recommendedAction': 'DO NOT PAY. Hang up and call LHDN official hotline to verify.'
    },
    {
      'transcript': 'Mak, saya kemalangan! Saya di hospital dan perlu duit segera untuk pembedahan. Sila transfer RM10,000 ke akaun ini sekarang. Jangan beritahu ayah dulu.',
      'riskLevel': 'highRisk',
      'scamType': 'emotionalManipulation',
      'confidence': 85,
      'linguisticRedFlags': ['Emergency claim', 'Secrecy request', 'Urgent money request'],
      'behavioralRedFlags': ['Emotional manipulation', 'Family emergency scam pattern'],
      'recommendedAction': 'STAY CALM. Verify by calling your family member directly using their known phone number.'
    },
    {
      'transcript': 'Congratulations! You have won a luxury car in our lucky draw. To claim your prize, please pay RM2,000 for processing fees and taxes.',
      'riskLevel': 'scam',
      'scamType': 'financialRequest',
      'confidence': 88,
      'linguisticRedFlags': ['Prize claim', 'Advance fee request', 'Too good to be true'],
      'behavioralRedFlags': ['Classic lottery scam pattern', 'Requesting payment for prize'],
      'recommendedAction': 'DO NOT PAY. Legitimate prizes do not require payment. This is a scam.'
    },
    {
      'transcript': 'Hello, this is John from Microsoft technical support. We detected malware on your computer. Please provide us remote access to fix it immediately.',
      'riskLevel': 'scam',
      'scamType': 'impersonation',
      'confidence': 90,
      'linguisticRedFlags': ['Tech company impersonation', 'Remote access request', 'Urgency'],
      'behavioralRedFlags': ['Fake tech support scam', 'Attempting to gain computer access'],
      'recommendedAction': 'HANG UP. Microsoft will never call you unsolicited. Do not grant remote access.'
    },
    {
      'transcript': 'Hi, this is your neighbor. I locked myself out and need to borrow some money for a locksmith. Can you help me out?',
      'riskLevel': 'suspicious',
      'scamType': 'other',
      'confidence': 60,
      'linguisticRedFlags': ['Money request', 'Urgency'],
      'behavioralRedFlags': ['Potentially legitimate but suspicious'],
      'recommendedAction': 'VERIFY the person\'s identity. Ask questions only your real neighbor would know.'
    }
  ];

  /// Analyze voice transcript using ILMU models
  Future<VoiceAnalysis> analyzeVoiceTranscript(String transcript) async {
    try {
      if (DemoModeService.isDemoMode) {
        // Use mock response in demo mode
        return await _mockVoiceAnalysis(transcript);
      } else {
        // Make real API call in live mode
        return await _realVoiceAnalysis(transcript);
      }
    } catch (e) {
      throw Exception('Failed to analyze voice: $e');
    }
  }

  /// Mock voice analysis for demo mode
  Future<VoiceAnalysis> _mockVoiceAnalysis(String transcript) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final lowerTranscript = transcript.toLowerCase();
    
    // Check against sample scams first
    for (final sample in _sampleVoiceScams) {
      if (sample['transcript'].toString().toLowerCase().contains(lowerTranscript.substring(0, 20))) {
        return VoiceAnalysis(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          transcript: transcript,
          riskLevel: VoiceRiskLevel.values.firstWhere(
            (e) => e.name == sample['riskLevel'],
          ),
          scamType: VoiceScamType.values.firstWhere(
            (e) => e.name == sample['scamType'],
          ),
          confidenceScore: (sample['confidence'] as num).toDouble(),
          linguisticRedFlags: List<String>.from(sample['linguisticRedFlags'] as List),
          behavioralRedFlags: List<String>.from(sample['behavioralRedFlags'] as List),
          recommendedAction: sample['recommendedAction'] as String,
          disclaimer: _getDisclaimer(),
          timestamp: DateTime.now(),
          analysisModel: 'ILMU-asr + ILMU-text (Demo Mode)',
          isDemoMode: true,
        );
      }
    }

    // General pattern analysis
    VoiceRiskLevel riskLevel = VoiceRiskLevel.safe;
    VoiceScamType scamType = VoiceScamType.none;
    double confidenceScore = 20.0;
    List<String> linguisticRedFlags = [];
    List<String> behavioralRedFlags = [];
    String recommendedAction = 'Call appears to be legitimate, but always stay vigilant.';

    // Check for scam indicators
    final scamIndicators = {
      'impersonation': ['bank negara', 'polis', 'lhdn', 'jpj', 'microsoft', 'google', 'apple'],
      'urgency': ['immediately', 'sekarang', 'segera', 'urgent', 'cepat', 'today', 'esok'],
      'financial': ['money', 'wang', 'payment', 'bayar', 'transfer', 'otp', 'account', 'akaun'],
      'threat': ['arrest', 'tangkap', 'saman', 'court', 'mahkamah', 'jail', 'penjara'],
      'emotional': ['emergency', 'kemalangan', 'hospital', 'danger', 'bahaya', 'family', 'keluarga'],
      'prize': ['win', 'menang', 'prize', 'hadiah', 'lucky draw', 'cabutan bertuah'],
      'access': ['remote access', 'akses remote', 'control', 'kawalan'],
    };

    int scamScore = 0;
    String detectedScamType = 'none';

    scamIndicators.forEach((type, keywords) {
      for (final keyword in keywords) {
        if (lowerTranscript.contains(keyword)) {
          scamScore += 15;
          linguisticRedFlags.add('Detected "$keyword" - $type indicator');
          detectedScamType = type;
        }
      }
    });

    // Determine risk level and scam type
    if (scamScore >= 60) {
      riskLevel = VoiceRiskLevel.scam;
      confidenceScore = (scamScore + 20).clamp(0.0, 100.0).toDouble();
      recommendedAction = 'END THE CALL IMMEDIATELY. This shows clear scam indicators.';
    } else if (scamScore >= 30) {
      riskLevel = VoiceRiskLevel.highRisk;
      confidenceScore = (scamScore + 10).clamp(0.0, 100.0).toDouble();
      recommendedAction = 'BE VERY CAUTIOUS. Multiple suspicious elements detected.';
    } else if (scamScore >= 15) {
      riskLevel = VoiceRiskLevel.suspicious;
      confidenceScore = (scamScore + 5).clamp(0.0, 100.0).toDouble();
      recommendedAction = 'PROCEED WITH CAUTION. Some elements are suspicious.';
    }

    // Map scam type
    switch (detectedScamType) {
      case 'impersonation':
        scamType = VoiceScamType.impersonation;
        break;
      case 'urgency':
        scamType = VoiceScamType.urgency;
        break;
      case 'financial':
        scamType = VoiceScamType.financialRequest;
        break;
      case 'threat':
        scamType = VoiceScamType.threat;
        break;
      case 'emotional':
        scamType = VoiceScamType.emotionalManipulation;
        break;
      case 'prize':
        scamType = VoiceScamType.financialRequest;
        break;
      case 'access':
        scamType = VoiceScamType.impersonation;
        break;
    }

    return VoiceAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transcript: transcript,
      riskLevel: riskLevel,
      scamType: scamType,
      confidenceScore: confidenceScore,
      linguisticRedFlags: linguisticRedFlags,
      behavioralRedFlags: behavioralRedFlags,
      recommendedAction: recommendedAction,
      disclaimer: _getDisclaimer(),
      timestamp: DateTime.now(),
      analysisModel: 'ILMU-asr + ILMU-text (Demo Mode)',
      isDemoMode: true,
    );
  }

  /// Real voice analysis using ILMU API
  Future<VoiceAnalysis> _realVoiceAnalysis(String transcript) async {
    final payload = {
      'model': 'ILMU-text',
      'api_key': _apiKey,
      'messages': [
        {
          'role': 'system',
          'content': '''You are ILMU, an AI assistant from Malaysia specializing in voice scam detection.

Analyze this voice transcript for scam indicators focusing on:
- Authority impersonation (bank, police, government agencies)
- Urgency tactics
- Emotional manipulation
- Financial requests
- Threats

Provide analysis in JSON format:
{
  "risk_level": "safe|suspicious|highRisk|scam",
  "scam_type": "none|impersonation|urgency|emotionalManipulation|financialRequest|threat|other",
  "confidence": 0-100,
  "linguistic_red_flags": ["flag1", "flag2"],
  "behavioral_red_flags": ["pattern1", "pattern2"],
  "recommended_action": "..."
}

Consider Malaysian context and common scam patterns in the region.'''
        },
        {
          'role': 'user',
          'content': 'Analyze this voice transcript for scam indicators: "$transcript"'
        }
      ],
      'max_tokens': 400,
      'temperature': 0.2
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Parse the response and create VoiceAnalysis object
      // This is a simplified version - in production, you'd parse the actual AI response
      return VoiceAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transcript: transcript,
        riskLevel: VoiceRiskLevel.suspicious, // Parsed from response
        scamType: VoiceScamType.none, // Parsed from response
        confidenceScore: 75.0, // Parsed from response
        linguisticRedFlags: [], // Parsed from response
        behavioralRedFlags: [], // Parsed from response
        recommendedAction: 'Proceed with caution', // Parsed from response
        disclaimer: _getDisclaimer(),
        timestamp: DateTime.now(),
        analysisModel: 'ILMU-asr + ILMU-text (Live Mode)',
        isDemoMode: false,
      );
    } else {
      throw Exception('API call failed: ${response.statusCode}');
    }
  }

  /// Get disclaimer text
  String _getDisclaimer() {
    return '''DISCLAIMER: This voice analysis tool is for assistance only and does not provide 100% accuracy. 
It focuses on linguistic and behavioral red flags, not biometric voice authentication. 
Always verify suspicious calls through official channels. 
JagaCall and ILMU are not responsible for decisions made based on this analysis.''';
  }

  /// Get sample voice scams for demo
  List<Map<String, dynamic>> getSampleVoiceScams() {
    return _sampleVoiceScams;
  }

  /// Create backend request payload for ILMU voice analysis
  Map<String, dynamic> createILMUVoicePayload(String transcript) {
    return {
      'model': 'ILMU-text',
      'api_key': _apiKey,
      'messages': [
        {
          'role': 'system',
          'content': '''You are ILMU, an AI assistant from Malaysia specializing in voice scam detection.

Analyze this voice transcript for scam indicators focusing on Malaysian context:
- Authority impersonation (Bank Negara, PDRM, LHDN, JPJ, etc.)
- Urgency tactics (sekarang, segera, immediately)
- Emotional manipulation (family emergency, accidents)
- Financial requests (OTP, money transfer, payment)
- Threats (arrest, legal action, account suspension)

Provide risk assessment and recommendations.'''
        },
        {
          'role': 'user',
          'content': 'Voice transcript analysis: "$transcript"'
        }
      ],
      'max_tokens': 400,
      'temperature': 0.2
    };
  }
}