import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/voice_analysis_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String, {String? audioFilePath, Duration? duration}) onVoiceSubmitted;
  final bool isLoading;

  const VoiceInputWidget({
    Key? key,
    required this.onVoiceSubmitted,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final TextEditingController _transcriptController = TextEditingController();
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  String? _selectedAudioPath;
  String? _selectedAudioName;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _transcriptController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Voice Detection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Record voice (max 10s) or upload audio file for analysis.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              _buildVoiceInputSection(colorScheme),
              const SizedBox(height: 20),
              _buildTranscriptInput(colorScheme),
              const SizedBox(height: 20),
              _buildActionButtons(colorScheme),
              const SizedBox(height: 20),
              _buildSampleSection(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceInputSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Input:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRecordingSection(colorScheme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFileUploadSection(colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordingSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mic,
            size: 32,
            color: _isRecording ? colorScheme.error : colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Record Voice',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (_isRecording) ...[
            Text(
              '$_recordingSeconds / 10s',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _recordingSeconds / 10.0,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.error),
            ),
          ] else ...[
            Text(
              'Max 10 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.isLoading ? null : (_isRecording ? _stopRecording : _startRecording),
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop' : 'Record'),
              style: FilledButton.styleFrom(
                backgroundColor: _isRecording ? colorScheme.error : colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: 32,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Audio',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '.mp3, .wav, .m4a',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedAudioName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _selectedAudioName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.isLoading ? null : _pickAudioFile,
              icon: const Icon(Icons.folder_open),
              label: Text(_selectedAudioPath != null ? 'Change File' : 'Choose File'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.secondary),
                foregroundColor: colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptInput(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transcript (Optional):',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _transcriptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter voice transcript here (optional, will be generated from audio)...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: widget.isLoading ? null : _analyzeVoice,
        icon: widget.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.security),
        label: Text(widget.isLoading ? 'Analyzing...' : 'Analyze Voice'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSampleSection(ColorScheme colorScheme) {
    final samples = _voiceService.getSampleVoiceScams();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.science,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Demo Samples:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...samples.asMap().entries.map((entry) {
          final index = entry.key;
          final sample = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 1,
              child: InkWell(
                onTap: () => _selectSample(sample['transcript'] as String),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getScamTypeDisplay(sample['scamType'] as String),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sample['transcript'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getSampleColor(sample['riskLevel'] as String).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (sample['riskLevel'] as String).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getSampleColor(sample['riskLevel'] as String),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${sample['confidence']}% confidence',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.play_arrow,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
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

  void _analyzeVoice() {
    final transcript = _transcriptController.text.trim();
    
    if (transcript.isEmpty && _selectedAudioPath == null && !_isRecording) {
      _showCustomSnackBar(
        'Please record voice, upload audio file, or enter transcript.',
        Icons.warning_amber,
        Colors.orange,
      );
      return;
    }
    
    // If no transcript but has audio or recording, generate mock transcript
    final finalTranscript = transcript.isNotEmpty ? transcript : _generateMockTranscript();
    
    widget.onVoiceSubmitted(
      finalTranscript,
      audioFilePath: _selectedAudioPath,
      duration: _recordingSeconds > 0 ? Duration(seconds: _recordingSeconds) : null,
    );
  }

  String _generateMockTranscript() {
    final mockTranscripts = [
      'Hello, this is your bank calling. We need to verify your account immediately.',
      'Dad, I\'m in trouble and need money right now. Please help.',
      'This is the police. We have a warrant for your arrest.',
    ];
    return mockTranscripts[DateTime.now().millisecond % mockTranscripts.length];
  }

  void _selectSample(String transcript) {
    setState(() {
      _transcriptController.text = transcript;
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
        if (_recordingSeconds >= 10) {
          _stopRecording();
        }
      });
    });

    _showCustomSnackBar(
      'Recording started... Maximum 10 seconds.',
      Icons.mic,
      Colors.green,
    );
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    
    setState(() {
      _isRecording = false;
    });

    // Simulate speech-to-text result for demo
    final mockTranscripts = [
      'Dad, I\'m in trouble! I had an accident and need RM5,000 for hospital bills right now.',
      'This is Sergeant Rahman from PDRM Cybercrime Unit. We need your OTP code immediately.',
      'Hello, I am calling from Maybank security department. Your account will be suspended in 30 minutes.',
    ];

    final randomTranscript = mockTranscripts[
      (DateTime.now().millisecondsSinceEpoch) % mockTranscripts.length
    ];

    setState(() {
      _transcriptController.text = randomTranscript;
      _selectedAudioPath = 'mock_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      _selectedAudioName = 'Recording_${_recordingSeconds}s.wav';
    });

    _showCustomSnackBar(
      'Recording stopped ($_recordingSeconds seconds). Transcript generated!',
      Icons.check_circle,
      Colors.green,
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAudioPath = result.files.single.path;
          _selectedAudioName = result.files.single.name;
        });
        
        _showCustomSnackBar(
          'Audio file selected: ${result.files.single.name}',
          Icons.check_circle,
          Colors.green,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        'Error picking file: $e',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showCustomSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getScamTypeDisplay(String scamType) {
    switch (scamType) {
      case 'familyEmergency':
        return 'Fake Family Emergency';
      case 'authorityImpersonation':
        return 'Fake Authority Call';
      case 'bankVerification':
        return 'Fake Bank Verification';
      default:
        return 'Other';
    }
  }
}