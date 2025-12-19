class AppConstants {
  // App Information
  static const String appName = 'JagaCall';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Pengesan Penipuan Panggilan Live untuk Pengguna Malaysia';
  
  // ILMU API Configuration
  static const String ilmuApiKey = 'sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc';
  static const String ilmuBaseUrl = 'https://api.ilmu.ai.my';
  
  // Emergency Contacts (Malaysia)
  static const String policeHotline = '999';
  static const String bankNegaraHotline = '1-300-88-5465';
  static const String mcmcHotline = '1-800-188-0302';
  static const String scamReportPortal = 'https://www.rmp.gov.my/report-scam';
  
  // Scam Categories in Bahasa Malaysia
  static const Map<String, String> scamCategoriesBM = {
    'bankImpersonation': 'Penyamaran Bank',
    'governmentImpersonation': 'Penyamaran Kerajaan',
    'lotteryScam': 'Penipuan Hadiah',
    'techSupport': 'Sokongan Teknikal Palsu',
    'loveScam': 'Penipuan Cinta',
    'investmentScam': 'Penipuan Pelaburan',
    'kidnapping': 'Ancaman Penculikan',
    'other': 'Lain-lain'
  };
  
  // Risk Levels in Bahasa Malaysia
  static const Map<String, String> riskLevelsBM = {
    'safe': 'Selamat',
    'suspicious': 'Mencurigakan',
    'highRisk': 'Risiko Tinggi',
    'scam': 'Penipuan'
  };
  
  // Common scam keywords in Malaysia
  static const List<String> scamKeywordsBM = [
    'akaun tersekat',
    'wang segera',
    'hadiah bertuah',
    'yuran proses',
    'cukai tunggakan',
    'tindakan undang-undang',
    'virus komputer',
    'akses remote',
    'anak anda',
    'wang tebusan'
  ];
  
  // Common scam keywords in Manglish
  static const List<String> scamKeywordsManglish = [
    'account blocked',
    'urgent money',
    'lucky draw',
    'processing fee',
    'tax arrears',
    'legal action',
    'computer virus',
    'remote access',
    'your child',
    'ransom money',
    'bank verification',
    'prize winner',
    'act now',
    'limited offer',
    'confirm details'
  ];

  // Emergency Contacts (Malaysia)
  static const Map<String, String> emergencyContacts = {
    'Police': '999',
    'Fire': '994',
    'Ambulance': '999',
    'Bank Negara Malaysia': '1-300-88-5465',
    'MCMC': '1-800-188-0301',
    'CyberSecurity Malaysia': '1-300-88-2999',
    'National Scam Response Centre': '997'
  };
}