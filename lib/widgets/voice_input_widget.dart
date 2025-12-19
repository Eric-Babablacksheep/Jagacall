import 'package:flutter/material.dart';
import '../services/voice_analysis_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTranscriptSubmitted;
  final bool isLoading;

  const VoiceInputWidget({
    Key? key,
    required this.onTranscriptSubmitted,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final TextEditingController _transcriptController = TextEditingController();
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  bool _isRecording = false;

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Scam Detection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter a voice transcript or select a sample to analyze for scam indicators.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildTranscriptInput(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildSampleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice Transcript:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _transcriptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter the voice transcript here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.isLoading ? null : _analyzeTranscript,
            icon: widget.isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
            label: Text(widget.isLoading ? 'Analyzing...' : 'Analyze Transcript'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? 'Stop' : 'Record'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSampleSection() {
    final samples = _voiceService.getSampleVoiceScams();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sample Voice Scams (for testing):',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...samples.asMap().entries.map((entry) {
          final index = entry.key;
          final sample = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: Colors.grey.shade50,
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: _getSampleColor(sample['riskLevel'] as String),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  sample['transcript'] as String,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Risk: ${(sample['riskLevel'] as String).toUpperCase()} | '
                  'Type: ${(sample['scamType'] as String).replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () => _selectSample(sample['transcript'] as String),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getSampleColor(String riskLevel) {
    switch (riskLevel) {
      case 'scam':
        return Colors.red;
      case 'highRisk':
        return Colors.orange;
      case 'suspicious':
        return Colors.yellow;
      case 'safe':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _analyzeTranscript() {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a voice transcript to analyze.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    widget.onTranscriptSubmitted(transcript);
  }

  void _selectSample(String transcript) {
    setState(() {
      _transcriptController.text = transcript;
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    
    // Show recording dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Recording Voice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Recording... Speak clearly into your microphone.'),
            const SizedBox(height: 8),
            Text(
              'Note: This is a demo. Actual speech-to-text would use ILMU-asr.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopRecording();
            },
            child: const Text('Stop Recording'),
          ),
        ],
      ),
    );

    // Simulate recording for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isRecording) {
        Navigator.of(context).pop();
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });

    // Simulate speech-to-text result
    final mockTranscripts = [
      'Hello sir, I am calling from Bank Negara Malaysia. Your account has been compromised and we need you to provide your OTP number immediately to secure it.',
      'Assalamualaikum, saya dari Jabatan Hasil Dalam Negeri. Anda ada tunggakan cukai RM5,000 dan perlu bayar sekarang.',
      'Congratulations! You have won a luxury car in our lucky draw. To claim your prize, please pay RM2,000 for processing fees.',
    ];

    final randomTranscript = mockTranscripts[
      (DateTime.now().millisecondsSinceEpoch) % mockTranscripts.length
    ];

    setState(() {
      _transcriptController.text = randomTranscript;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice transcript captured! You can now analyze it.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}