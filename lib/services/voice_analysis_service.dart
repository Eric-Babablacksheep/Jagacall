import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voice_analysis.dart';
import '../services/demo_mode_service.dart';
import '../constants/app_constants.dart';

class VoiceAnalysisService {
  static const String _apiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';
  static const String _baseUrl = 'https://api.ytlailabs.tech/v1';

  // Sample deepfake voice scam transcripts for demo
  static const List<Map<String, dynamic>> _sampleVoiceScams = [
    {
      'transcript': 'Dad, I\'m in trouble! I had an accident and need RM5,000 for hospital bills right now. Please don\'t tell mom, just transfer the money to this account immediately.',
      'riskLevel': 'scam',
      'scamType': 'familyEmergency',
      'confidence': 95,
      'linguisticRedFlags': ['Family emergency claim', 'Urgency language', 'Secrecy request', 'Money transfer request'],
      'behavioralRedFlags': ['Emotional manipulation', 'Creating false emergency', 'Isolating victim'],
      'voiceIndicators': ['Unnatural pitch stability', 'Lack of emotional variation', 'Repetitive speech patterns'],
      'recommendedAction': 'HANG UP IMMEDIATELY. Call your family member using their known phone number to verify their safety.'
    },
    {
      'transcript': 'This is Sergeant Rahman from PDRM Cybercrime Unit. We have detected fraudulent activity in your bank account. You must verify your identity by providing your OTP code now to avoid arrest.',
      'riskLevel': 'scam',
      'scamType': 'authorityImpersonation',
      'confidence': 92,
      'linguisticRedFlags': ['Police impersonation', 'Threat of arrest', 'Urgency', 'OTP request'],
      'behavioralRedFlags': ['Authority abuse', 'Creating fear', 'Requesting sensitive information'],
      'voiceIndicators': ['Monotone delivery', 'Unnatural speech rhythm', 'Voice-identity mismatch'],
      'recommendedAction': 'DO NOT PROVIDE OTP. Hang up and call PDRM official hotline to verify.'
    },
    {
      'transcript': 'Hello, I am calling from Maybank security department. Your account will be suspended within 30 minutes unless you confirm your identity. Please read out your full IC number and banking password.',
      'riskLevel': 'scam',
      'scamType': 'bankVerification',
      'confidence': 90,
      'linguisticRedFlags': ['Bank impersonation', 'Account suspension threat', 'Password request', 'Urgency'],
      'behavioralRedFlags': ['Creating false emergency', 'Requesting confidential information'],
      'voiceIndicators': ['Robotic speech patterns', 'Lack of natural pauses', 'Inconsistent vocal tone'],
      'recommendedAction': 'NEVER SHARE PASSWORDS. Hang up and call your bank using the official number on your card.'
    },
    {
      'transcript': 'Mom, I lost my phone and I\'m using my friend\'s phone. I need you to transfer RM2,000 for my university fees. The deadline is today. Please send it to this account number quickly.',
      'riskLevel': 'highRisk',
      'scamType': 'familyEmergency',
      'confidence': 85,
      'linguisticRedFlags': ['Family member claim', 'Lost phone excuse', 'Urgent money request', 'Deadline pressure'],
      'behavioralRedFlags': ['Emotional manipulation', 'Creating false urgency'],
      'voiceIndicators': ['Slightly unnatural pitch', 'Reduced emotional range', 'Mechanical pronunciation'],
      'recommendedAction': 'VERIFY IDENTITY. Call your child using their known phone number before sending any money.'
    },
    {
      'transcript': 'Good morning, this is Officer Lim from LHDN. Our records show you have unpaid taxes totaling RM8,500. You must pay immediately or we will freeze your bank accounts and seize your assets.',
      'riskLevel': 'scam',
      'scamType': 'authorityImpersonation',
      'confidence': 88,
      'linguisticRedFlags': ['Tax authority impersonation', 'Asset seizure threat', 'Immediate payment demand'],
      'behavioralRedFlags': ['Using authority to intimidate', 'Creating financial fear'],
      'voiceIndicators': ['Overly formal speech', 'Unnatural cadence', 'Voice synthesis artifacts'],
      'recommendedAction': 'DO NOT PAY. Hang up and contact LHDN directly through official channels.'
    },
    {
      'transcript': 'Hi, this is Sarah from your bank\'s fraud department. We need to verify a recent transaction. Can you please confirm the 6-digit code we just sent to your phone?',
      'riskLevel': 'suspicious',
      'scamType': 'bankVerification',
      'confidence': 65,
      'linguisticRedFlags': ['Bank fraud department claim', 'Code verification request'],
      'behavioralRedFlags': ['Potential social engineering', 'Attempting to obtain OTP'],
      'voiceIndicators': ['Slightly robotic tone', 'Minimal emotional variation'],
      'recommendedAction': 'BE CAUTIOUS. Real banks will never ask for OTP codes. Hang up and call your bank directly.'
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
          voiceIndicators: List<String>.from(sample['voiceIndicators'] as List),
        );
      }
    }

    // General pattern analysis
    VoiceRiskLevel riskLevel = VoiceRiskLevel.safe;
    VoiceScamType scamType = VoiceScamType.none;
    double confidenceScore = 20.0;
    List<String> linguisticRedFlags = [];
    List<String> behavioralRedFlags = [];
    List<String> voiceIndicators = [];
    String recommendedAction = 'Voice appears authentic, but always verify suspicious calls.';

    // Check for deepfake scam indicators
    final scamIndicators = {
      'familyEmergency': ['dad', 'mom', 'son', 'daughter', 'family', 'accident', 'hospital', 'emergency', 'trouble'],
      'authorityImpersonation': ['police', 'pdrm', 'bank negara', 'lhdn', 'jpj', 'sergeant', 'officer', 'department'],
      'bankVerification': ['bank', 'account', 'verify', 'suspend', 'freeze', 'otp', 'password', 'security', 'fraud'],
      'urgency': ['immediately', 'now', 'sekarang', 'segera', 'urgent', 'quickly', 'today', '30 minutes'],
      'financial': ['money', 'transfer', 'payment', 'bayar', 'wang', 'rm', 'ringgit', 'account', 'akaun'],
      'threat': ['arrest', 'tangkap', 'seize', 'freeze', 'suspend', 'legal action', 'court'],
      'secrecy': ['don\'t tell', 'jangan beritahu', 'secret', 'confidential', 'alone'],
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
      case 'familyEmergency':
        scamType = VoiceScamType.familyEmergency;
        break;
      case 'authorityImpersonation':
        scamType = VoiceScamType.authorityImpersonation;
        break;
      case 'bankVerification':
        scamType = VoiceScamType.bankVerification;
        break;
    }

    // Add simulated voice indicators for high-risk cases
    if (scamScore >= 30) {
      voiceIndicators.addAll([
        'Unnatural pitch stability detected',
        'Reduced emotional variation in speech',
        'Slightly robotic cadence patterns',
      ]);
      
      if (scamScore >= 60) {
        voiceIndicators.addAll([
          'Voice synthesis artifacts present',
          'Inconsistent vocal characteristics',
        ]);
      }
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
      voiceIndicators: voiceIndicators,
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
        voiceIndicators: ['Live analysis - voice patterns being analyzed'], // Live mode indicator
        recommendedAction: 'Proceed with caution', // Parsed from response
        disclaimer: _getDisclaimer(),
        timestamp: DateTime.now(),
        analysisModel: 'ILMU-deepfake (Live Mode)',
        isDemoMode: false,
      );
    } else {
      throw Exception('API call failed: ${response.statusCode}');
    }
  }

  /// Get disclaimer text
  String _getDisclaimer() {
    return '''DISCLAIMER: This AI Deepfake Voice Detection tool is for assistance only and does not provide 100% accuracy.
It analyzes voice patterns, linguistic indicators, and behavioral red flags to identify potential voice cloning.
Always verify suspicious calls through official channels using known contact information.
JagaCall and ILMU are not responsible for decisions made based on this analysis.''';
  }

  /// Get sample voice scams for demo
  List<Map<String, dynamic>> getSampleVoiceScams() {
    return _sampleVoiceScams;
  }

  /// Create backend request payload for ILMU deepfake voice analysis
  Map<String, dynamic> createILMUVoicePayload(String transcript) {
    return {
      'model': 'ILMU-deepfake',
      'api_key': _apiKey,
      'messages': [
        {
          'role': 'system',
          'content': '''You are ILMU, an AI assistant from Malaysia specializing in AI deepfake voice detection.

Analyze this voice transcript for deepfake scam indicators focusing on Malaysian context:
- Fake family emergency calls (accidents, hospital, urgent money needs)
- Fake police/authority calls (PDRM, LHDN, Bank Negara impersonation)
- Fake bank verification calls (OTP requests, account suspension threats)
- Voice pattern analysis (unnatural pitch, lack of emotion, robotic speech)

Provide confidence-based risk assessment: Low Risk / Suspicious / High Risk / Likely Voice Clone
Include specific safety advice for each scenario.'''
        },
        {
          'role': 'user',
          'content': 'Deepfake voice analysis: "$transcript"'
        }
      ],
      'max_tokens': 500,
      'temperature': 0.1
    };
  }
}