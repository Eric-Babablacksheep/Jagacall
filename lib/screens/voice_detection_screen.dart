import 'package:flutter/material.dart';
import '../models/voice_analysis.dart';
import '../services/voice_analysis_service.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/voice_analysis_widget.dart';

class VoiceDetectionScreen extends StatefulWidget {
  const VoiceDetectionScreen({Key? key}) : super(key: key);

  @override
  State<VoiceDetectionScreen> createState() => _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState extends State<VoiceDetectionScreen> {
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  VoiceAnalysis? _currentAnalysis;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Scam Detection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              VoiceInputWidget(
                onTranscriptSubmitted: _analyzeVoiceTranscript,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              if (_currentAnalysis != null) ...[
                VoiceAnalysisWidget(
                  analysis: _currentAnalysis!,
                  onAnalyzeAnother: _resetAnalysis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: Colors.blue.shade900,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voice Scam Detection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Analyze voice transcripts for scam indicators using ILMU AI. '
              'This tool helps identify suspicious patterns in phone conversations, '
              'including authority impersonation, urgency tactics, and financial requests.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Detects authority impersonation (Bank Negara, PDRM, LHDN)',
      'Identifies urgency and pressure tactics',
      'Recognizes emotional manipulation patterns',
      'Flags financial requests and threats',
      'Supports English and Bahasa Malaysia analysis',
      'Provides risk assessment and recommendations',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _analyzeVoiceTranscript(String transcript) async {
    setState(() {
      _isLoading = true;
      _currentAnalysis = null;
    });

    try {
      final analysis = await _voiceService.analyzeVoiceTranscript(transcript);
      setState(() {
        _currentAnalysis = analysis;
        _isLoading = false;
      });

      // Show result notification
      _showResultNotification(analysis);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResultNotification(VoiceAnalysis analysis) {
    Color backgroundColor;
    String message;

    switch (analysis.riskLevel) {
      case VoiceRiskLevel.scam:
        backgroundColor = Colors.red;
        message = '⚠️ SCAM DETECTED! High risk indicators found.';
        break;
      case VoiceRiskLevel.highRisk:
        backgroundColor = Colors.orange;
        message = '⚠️ HIGH RISK: Multiple suspicious elements detected.';
        break;
      case VoiceRiskLevel.suspicious:
        backgroundColor = Colors.yellow;
        message = '⚠️ SUSPICIOUS: Some elements require caution.';
        break;
      case VoiceRiskLevel.safe:
        backgroundColor = Colors.green;
        message = '✅ APPEARS SAFE: No major scam indicators detected.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {
            // Scroll to analysis results
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

  void _resetAnalysis() {
    setState(() {
      _currentAnalysis = null;
    });
  }
}