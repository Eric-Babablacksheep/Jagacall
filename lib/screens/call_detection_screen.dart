import 'package:flutter/material.dart';
import '../models/call_analysis.dart';
import '../services/call_detection_service.dart';
import '../constants/app_constants.dart';
import '../widgets/call_analysis_widget.dart';
import '../widgets/sample_transcript_widget.dart';

class CallDetectionScreen extends StatefulWidget {
  const CallDetectionScreen({super.key});

  @override
  State<CallDetectionScreen> createState() => _CallDetectionScreenState();
}

class _CallDetectionScreenState extends State<CallDetectionScreen> {
  final CallDetectionService _detectionService = CallDetectionService();
  final TextEditingController _transcriptController = TextEditingController();
  CallAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;
  bool _isSimulatingCall = false;

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _analyzeTranscript() async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      _showSnackBar('Please enter a call transcript', Colors.orange);
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysis = await _detectionService.analyzeCallTranscript(transcript);
      setState(() {
        _lastAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Error during analysis: $e', Colors.red);
    }
  }

  Future<void> _simulateLiveCall() async {
    setState(() {
      _isSimulatingCall = true;
      _lastAnalysis = null;
    });

    // Simulate live call segments
    final callSegments = [
      'Hello, saya dari Bank Negara Malaysia...',
      'Kami ada masalah dengan akaun anda...',
      'Akaun anda akan disekat dalam 24 jam...',
      'Sila berikan nombor IC dan kata laluan anda...'
    ];

    for (int i = 0; i < callSegments.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final currentTranscript = callSegments.sublist(0, i + 1).join(' ');
      _transcriptController.text = currentTranscript;
      
      if (i == callSegments.length - 1) {
        // Analyze final transcript
        await _analyzeTranscript();
      }
    }

    setState(() {
      _isSimulatingCall = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JagaCall - Scam Detector'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSimulationSection(),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 24),
            if (_lastAnalysis != null) ...[
              const Text(
                'Analysis Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CallAnalysisWidget(analysis: _lastAnalysis!),
            ],
            const SizedBox(height: 24),
            _buildEmergencyContacts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.phone_in_talk,
              size: 48,
              color: Colors.red[700],
            ),
            const SizedBox(height: 8),
            Text(
              'Live Call Intent Detection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use ILMU AI to detect scams during calls',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Call Simulation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try a scam call simulation to see how the system works',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSimulatingCall ? null : _simulateLiveCall,
                icon: _isSimulatingCall
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isSimulatingCall ? 'Simulating...' : 'Start Simulation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Transcript Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _transcriptController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter call transcript here...\n\nExample: "Hello, saya dari Bank Negara. Akaun anda ada masalah..."',
                border: OutlineInputBorder(),
              ),
              enabled: !_isAnalyzing && !_isSimulatingCall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isAnalyzing || _isSimulatingCall) ? null : _analyzeTranscript,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _transcriptController.clear();
                    setState(() {
                      _lastAnalysis = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SampleTranscriptWidget(
              samples: _detectionService.getSampleTranscripts(),
              onSampleSelected: (sample) {
                _transcriptController.text = sample['text']!;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactItem('Police', AppConstants.policeHotline),
            _buildContactItem('Bank Negara', AppConstants.bankNegaraHotline),
            _buildContactItem('MCMC', AppConstants.mcmcHotline),
            const SizedBox(height: 8),
            const Text(
              'Report scams: ${AppConstants.scamReportPortal}',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About JagaCall'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            Text(AppConstants.appDescription),
            const SizedBox(height: 16),
            const Text('AI Models Used:'),
            const Text('• ILMU-text - Scam text analysis'),
            const Text('• ILMU-asr - Speech to text (future)'),
            const SizedBox(height: 16),
            const Text(
              'Warning: This tool is for assistance only. Always be vigilant and verify information with relevant parties.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}