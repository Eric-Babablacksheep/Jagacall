# JagaCall - AI-Powered Scam Detection Assistant

<div align="center">

![JagaCall Logo](https://img.shields.io/badge/JagaCall-v1.0.0-red?style=for-the-badge&logo=flutter)

**A comprehensive mobile application for detecting and preventing scams through AI-powered analysis**

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.10.4+-0175C2?style=flat-square&logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Made in Malaysia](https://img.shields.io/badge/Made%20in%20Malaysia-🇲🇾-red?style=flat-square)](https://www.ytlailabs.tech/)

</div>

## 📱 About JagaCall

JagaCall is an intelligent mobile application designed to protect Malaysians from various types of scams through advanced AI analysis. Developed by YTL AI Labs, the app leverages the power of ILMU (Intelek Luhur Malaysia Untukmu) AI technology to analyze phone calls, files, and voice recordings for potential scam threats.

### 🎯 Key Features

- **📞 Call Detection**: Analyze call transcripts to identify scam patterns and red flags
- **📁 File Analysis**: Scan files for malicious content and security threats
- **🎤 Voice Detection**: Detect voice scams through transcript analysis and behavioral pattern recognition
- **🔒 Demo Mode**: Safe testing environment with simulated responses
- **🌏 Localized**: Optimized for Malaysian context with support for English and Bahasa Malaysia
- **⚡ Real-time Analysis**: Get instant risk assessments and recommendations

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart SDK 3.10.4 or higher
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/YTL-AI-Labs/UMSIC_2025.git
   cd UMSIC_2025/jagacall
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### First Launch

The app starts in **Demo Mode** by default, which provides simulated responses for testing without requiring API keys or backend connection. This is perfect for exploring the app's features immediately.

## 📋 Navigation & Features

### Main Navigation

The app features a clean, intuitive interface with four main sections accessible via the bottom navigation bar:

| Tab          | Icon | Description                                       |
| ------------ | ---- | ------------------------------------------------- |
| **Calls**    | 📞   | Analyze phone call transcripts for scam detection |
| **Files**    | 📁   | Scan and analyze files for security threats       |
| **Voice**    | 🎤   | Detect voice scams through audio analysis         |
| **Settings** | ⚙️   | Configure app settings and toggle demo mode       |

### Detailed Features

#### 📞 Call Detection

- **Sample Scams**: Pre-loaded examples of common scam scenarios
- **Custom Input**: Manually enter call transcripts for analysis
- **Risk Assessment**: Get detailed risk levels (Safe, Suspicious, High Risk, Scam)
- **Red Flags**: Identify specific scam patterns and manipulation tactics
- **Recommendations**: Receive actionable advice on how to respond

#### 📁 File Analysis

- **Multi-format Support**: Analyze APK, PDF, DOC, and other common file types
- **Security Scanning**: Detect malware, phishing attempts, and suspicious content
- **Metadata Analysis**: Examine file properties and origins
- **Threat Indicators**: Identify specific security concerns
- **Safe Handling**: Get recommendations for file safety

#### 🎤 Voice Detection

- **Audio Recording**: Record voice calls for analysis (simulated in demo mode)
- **Transcript Analysis**: Convert speech to text and analyze content
- **Behavioral Patterns**: Detect emotional manipulation and pressure tactics
- **Linguistic Analysis**: Identify language patterns common in scams
- **Cultural Context**: Understand Malaysia-specific scam tactics

#### ⚙️ Settings

- **Demo Mode Toggle**: Switch between demo and live modes
- **App Information**: View version details and developer information
- **Privacy Settings**: Manage data and privacy preferences
- **Help & Support**: Access documentation and support resources

## 🛠️ Technical Architecture

### Frontend (Flutter)

- **Framework**: Flutter 3.10.4+
- **Language**: Dart 3.10.4+
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Local Storage**: SharedPreferences
- **HTTP Client**: HTTP package for API communication

### Backend (Optional)

- **Node.js/Express** or **Python/FastAPI** server
- **ILMU AI API integration** for advanced analysis
- **PostgreSQL/MongoDB** for data persistence
- **JWT authentication** for enhanced security
- **Rate limiting** and **input validation**

### Key Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  permission_handler: ^11.1.0
  file_picker: ^8.0.3
  flutter_local_notifications: ^17.2.2
```

## 📖 Documentation

### Essential Reading

- [**Testing Guide**](TESTING_GUIDE.md) - Comprehensive testing instructions
- [**Disclaimer**](DISCLAIMER.md) - Important limitations and usage guidelines
- [**Backend Architecture**](backend/README.md) - Server setup and API documentation

### API Integration

The app integrates with ILMU AI APIs for advanced analysis:

- **ILMU-text**: Text analysis for call and voice detection
- **ILMU-text-free-safe**: File security analysis
- **ILMU-asr**: Speech-to-text conversion (future enhancement)

## 🧪 Testing

### Demo Mode Testing

1. Launch the app (starts in demo mode automatically)
2. Navigate to any tab (Calls, Files, Voice)
3. Use sample data or input custom content
4. Observe simulated analysis results
5. Test all features without API requirements

### Live Mode Testing

1. Go to Settings and toggle Demo Mode OFF
2. Set up the backend service (see [Backend README](backend/README.md))
3. Configure API keys in environment variables
4. Test with real AI analysis

### Test Coverage

- ✅ UI/UX testing across all screens
- ✅ Feature functionality testing
- ✅ Error handling validation
- ✅ Performance testing
- ✅ Security testing
- ✅ Accessibility testing

## 🔒 Security & Privacy

### Data Protection

- **Local Processing**: Sensitive data processed locally when possible
- **Secure Transmission**: HTTPS for all API communications
- **Privacy Compliance**: Adheres to Malaysia's Personal Data Protection Act (PDPA) 2010
- **No Data Selling**: User data is never sold to third parties

### Security Features

- **Input Validation**: All user inputs are validated and sanitized
- **Rate Limiting**: Prevents abuse and API overuse
- **Secure Storage**: API keys and sensitive data stored securely
- **Regular Updates**: Security patches and updates

## 🌏 Malaysian Context

JagaCall is specifically designed for the Malaysian market:

### Localized Scam Detection

- **Bank Negara Malaysia** impersonation scams
- **MCMC** and government agency scams
- **Telekom** and utility company scams
- **Courier** and delivery scams
- **Family emergency** scams in Bahasa Malaysia

### Emergency Contacts

The app provides quick access to Malaysian emergency services:

- **PDRM**: 999 (Emergency) / 03-2262 6555 (Non-emergency)
- **NSRC**: 997 (National Scam Response Centre)
- **BNM**: 1-300-88-5465 (Bank Negara Malaysia)
- **CyberSecurity Malaysia**: 1-300-88-2999 (Cyber999)

## 🤝 Contributing

We welcome contributions from the community! Please follow these guidelines:

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style

- Follow Dart/Flutter official style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Include unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Feedback

### Get Help

- **Email**: support@jagacall.com
- **Website**: www.jagacall.com
- **Documentation**: See [Testing Guide](TESTING_GUIDE.md) and [Disclaimer](DISCLAIMER.md)

### Report Issues

- **GitHub Issues**: Report bugs and feature requests
- **Emergency**: For immediate threats, contact local law enforcement

### Feedback

We value your feedback! Help us improve JagaCall by:

- Reporting false positives/negatives
- Suggesting new features
- Sharing user experience insights
- Contributing to scam pattern database

## 🙏 Acknowledgments

- **YTL AI Labs Malaysia** - For providing ILMU AI technology
- **Flutter Community** - For the amazing cross-platform framework
- **Malaysian Authorities** - For scam prevention guidelines and resources
- **Beta Testers** - For valuable feedback and testing contributions

---

<div align="center">

**Developed with ❤️ in Malaysia by YTL AI Labs**

_Protecting Malaysians through AI-powered scam detection_

[![YTL AI Labs](https://img.shields.io/badge/Powered%20by-ILMU%20AI-red?style=flat-square)](https://www.ytlailabs.tech/)

</div>

---

**Last Updated**: December 20, 2025  
**Version**: 1.0.0  
**Build**: Flutter 3.10.4+ • Dart 3.10.4+
