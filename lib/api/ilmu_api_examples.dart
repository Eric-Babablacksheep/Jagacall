/// ILMU API Integration Examples for JagaCall
/// 
/// This file contains examples of how to integrate with ILMU models
/// for scam detection in Malaysian context.

class ILMUApiExamples {
  
  /// Example: Backend Request Payload for ILMU-text Model
  /// 
  /// This payload would be sent from Flutter backend to ILMU API
  /// for analyzing call transcripts for scam intent.
  static Map<String, dynamic> getCallAnalysisPayload(String transcript) {
    return {
      "model": "ILMU-text",
      "api_key": "sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc",
      "messages": [
        {
          "role": "system",
          "content": """Anda adalah ILMU, AI assistant dari Malaysia yang pakar dalam mengesan penipuan panggilan. 
          
Analisis transkrip panggilan ini dan berikan penilaian risiko dalam konteks Malaysia.

Kategorikan penipuan mengikut jenis biasa di Malaysia:
- bankImpersonation: Penyamaran Bank
- governmentImpersonation: Penyamaran Kerajaan  
- lotteryScam: Penipuan Hadiah
- techSupport: Sokongan Teknikal Palsu
- loveScam: Penipuan Cinta
- investmentScam: Penipuan Pelaburan
- kidnapping: Ancaman Penculikan
- other: Lain-lain

Berikan jawapan dalam format JSON:
{
  "riskLevel": "safe|suspicious|highRisk|scam",
  "category": "kategori_penipuan",
  "confidenceScore": 0.0-1.0,
  "warningSigns": ["tanda1", "tanda2"],
  "recommendedActions": ["tindakan1", "tindakan2"],
  "reason": "sebab penilaian"
}

Gunakan Bahasa Malaysia dalam analisis anda."""
        },
        {
          "role": "user", 
          "content": "Analisis transkrip panggilan ini: \"$transcript\""
        }
      ],
      "max_tokens": 500,
      "temperature": 0.3
    };
  }

  /// Example: Mock Response from ILMU-text API
  /// 
  /// This is an example of what the ILMU API would return
  /// for a scam call analysis.
  static Map<String, dynamic> getMockScamResponse() {
    return {
      "id": "call_analysis_12345",
      "model": "ILMU-text",
      "created": "2025-12-18T02:06:00Z",
      "choices": [
        {
          "index": 0,
          "message": {
            "role": "assistant",
            "content": """{
  "riskLevel": "scam",
  "category": "bankImpersonation", 
  "confidenceScore": 0.95,
  "warningSigns": [
    "Mengaku dari Bank Negara",
    "Mengancam akaun bank akan disekat",
    "Meminta maklumat peribadi (nombor IC)",
    "Mewujudkan keadaan kecemasan palsu"
  ],
  "recommendedActions": [
    "Jangan berikan sebarang maklumat peribadi",
    "Tamatkan panggilan segera",
    "Call Bank Negara menggunakan nombor rasmi: 1-300-88-5465",
    "Laporkan insiden kepada polis atau Bank Negara"
  ],
  "reason": "Panggilan ini menunjukkan ciri-ciri jelas penipuan penyamaran bank. Pengguna mengaku dari Bank Negara dan mengancam untuk menyekat akaun, yang adalah taktik biasa penipu untuk mendapatkan maklumat peribadi."
}"""
          },
          "finish_reason": "stop"
        }
      ],
      "usage": {
        "prompt_tokens": 150,
        "completion_tokens": 200,
        "total_tokens": 350
      }
    };
  }

  /// Example: Backend Request Payload for ILMU-asr Model
  /// 
  /// This payload would be used for speech-to-text conversion
  /// from call audio (future feature).
  static Map<String, dynamic> getSpeechToTextPayload(String audioBase64) {
    return {
      "model": "ILMU-asr",
      "api_key": "sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc",
      "audio": audioBase64,
      "language": "ms-MY", // Bahasa Malaysia
      "format": "wav",
      "sample_rate": 16000
    };
  }

  /// Example: Mock Response from ILMU-asr API
  /// 
  /// This is an example of speech-to-text conversion result.
  static Map<String, dynamic> getMockSpeechToTextResponse() {
    return {
      "text": "Selamat pagi, saya dari Bank Negara Malaysia. Akaun anda ada masalah dan perlu dikemas kini segera. Sila berikan nombor IC anda untuk pengesahan.",
      "confidence": 0.92,
      "language": "ms-MY",
      "duration": 8.5
    };
  }

  /// Sample Manglish Transcripts for Testing
  static const List<String> sampleManglishTranscripts = [
    "Hello sir, I'm from CIMB bank. Your account got some problem la. Need your IC number immediately to fix.",
    "Congratulations! You win iPhone 15 in our lucky draw. Just pay RM300 processing fee first.",
    "Your computer got virus very serious! I from Microsoft technical support. Need remote access now.",
    "Your son is with us. If you want him safe, transfer RM50,000 to this account within 2 hours."
  ];

  /// Sample Bahasa Malaysia Transcripts for Testing
  static const List<String> sampleBMTranscripts = [
    "Selamat pagi, saya dari Jabatan Hasil Dalam Negeri. Anda ada tunggakan cukai dan perlu bayar sekarang.",
    "Tahniah! Anda telah menangi kereta Perodua Axia dalam cabutan bertuah kami.",
    "Saya dari Tenaga Nasional. Bekalan elektrik rumah anda akan dipotong jika tidak bayar tunggakan.",
    "Anak anda kemalangan. Saya dari hospital. Perlu deposit RM10,000 untuk pembedahan segera."
  ];

  /// Example: Backend Request Payload for ILMU-text-free-safe Model (File Analysis)
  ///
  /// This payload would be sent from Flutter backend to ILMU API
  /// for analyzing files for scam content.
  static Map<String, dynamic> getFileAnalysisPayload({
    required String fileName,
    required String fileType,
    required String sourceApp,
    List<String> permissions = const [],
  }) {
    return {
      "model": "ILMU-text-free-safe",
      "api_key": "sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc",
      "messages": [
        {
          "role": "system",
          "content": """Anda adalah ILMU, AI assistant dari Malaysia yang pakar dalam mengesan penipuan dalam fail.

Analisis maklumat fail ini dan berikan penilaian risiko dalam konteks Malaysia:

Kriteria analisis:
- Nama fail yang mencurigakan (bank, polis, pos, pelaburan, dll)
- Jenis fail berisiko (APK sangat berisiko)
- Sumber aplikasi (WhatsApp/Telegram berisiko tinggi)
- Kebenaran yang diminta (camera, location, contacts berbahaya)

Kategorikan penipuan:
- none: Tiada penipuan
- bank: Penipuan bank (Maybank, CIMB, dll)
- police: Penipuan polis/kerajaan (PDRM, JPJ, LHDN)
- parcel: Penipuan pos/penghantaran (PosLaju, GDEx)
- family: Penipuan keluarga/kecemasan
- investment: Penipuan pelaburan (return tinggi)
- other: Lain-lain

Berikan jawapan dalam format JSON sahaja:
{
  "risk_level": "low|medium|high",
  "scam_type": "none|bank|police|parcel|family|investment|other",
  "confidence": 0-100,
  "reason": "...",
  "recommended_action": "..."
}

Gunakan Bahasa Malaysia. Fokus pada keselamatan pengguna Malaysia."""
        },
        {
          "role": "user",
          "content": """Analisis fail ini:
Nama Fail: $fileName
Jenis Fail: $fileType
Sumber: $sourceApp
${permissions.isNotEmpty ? 'Kebenaran: ${permissions.join(", ")}' : 'Tiada kebenaran (bukan APK)'}"""
        }
      ],
      "max_tokens": 300,
      "temperature": 0.2
    };
  }

  /// Example: Mock Response from ILMU-text-free-safe API (File Analysis)
  ///
  /// This is an example of what the ILMU API would return
  /// for a dangerous file analysis.
  static Map<String, dynamic> getMockFileScamResponse() {
    return {
      "id": "file_analysis_67890",
      "model": "ILMU-text-free-safe",
      "created": "2025-12-18T02:12:00Z",
      "choices": [
        {
          "index": 0,
          "message": {
            "role": "assistant",
            "content": """{
  "risk_level": "high",
  "scam_type": "bank",
  "confidence": 95,
  "reason": "Nama fail 'Maybank_Security_Update.apk' jelas meniru bank rasmi Malaysia. Fail APK sentiasa berisiko, apabila digabungkan dengan nama bank dan kebenaran berbahaya (camera, location, contacts, sms), ini menunjukkan percubaan penipuan yang sangat serius untuk mencuri maklumat peribadi dan kewangan pengguna.",
  "recommended_action": "JANGAN install fail ini under apa keadaan sekalipun. Padam fail segera. Jika mahu kemas kini aplikasi Maybank, muat turun dari Google Play Store atau laman web rasmi Maybank sahaja. Laporkan insiden ini kepada Maybank dan MCMC."
}"""
          },
          "finish_reason": "stop"
        }
      ],
      "usage": {
        "prompt_tokens": 180,
        "completion_tokens": 150,
        "total_tokens": 330
      }
    };
  }

  /// Example: Mock Response for Safe File
  static Map<String, dynamic> getMockFileSafeResponse() {
    return {
      "id": "file_analysis_12345",
      "model": "ILMU-text-free-safe",
      "created": "2025-12-18T02:12:00Z",
      "choices": [
        {
          "index": 0,
          "message": {
            "role": "assistant",
            "content": """{
  "risk_level": "low",
  "scam_type": "none",
  "confidence": 15,
  "reason": "Nama fail 'Company_Report_2024.pdf' kelihatan profesional dan tiada kata kunci mencurigakan. Fail PDF dari sumber email yang diketahui mempunyai risiko rendah. Tiada tanda-tanda penipuan yang jelas.",
  "recommended_action": "Fail kelihatan selamat, tetapi sentiasa pastikan penghantar adalah kenalan yang dipercayai sebelum membuka. Gunakan antivirus yang dikemaskini."
}"""
          },
          "finish_reason": "stop"
        }
      ],
      "usage": {
        "prompt_tokens": 160,
        "completion_tokens": 120,
        "total_tokens": 280
      }
    };
  }
}