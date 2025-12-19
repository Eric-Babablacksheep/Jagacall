import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/call_analysis.dart';
import '../services/call_detection_service.dart';
import '../constants/app_constants.dart';
import '../widgets/call_analysis_widget.dart';

class CallDetectionScreen extends StatefulWidget {
  const CallDetectionScreen({super.key});

  @override
  State<CallDetectionScreen> createState() => _CallDetectionScreenState();
}

class _CallDetectionScreenState extends State<CallDetectionScreen>
    with TickerProviderStateMixin {
  final CallDetectionService _detectionService = CallDetectionService();
  final TextEditingController _transcriptController = TextEditingController();
  CallAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;
  bool _isSimulatingCall = false;
  bool _isDemoMode = true; // Demo mode toggle
  bool _isTranscriptExamplesExpanded = false;
  bool _isDraggingFile = false;
  String? _selectedAudioFile;
  
  // Scam number warning state
  bool _showScamWarning = false;
  String _scamNumber = '';
  String _scamReason = '';
  
  late AnimationController _pulseController;
  late AnimationController _warningController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _warningAnimation;

  // Predefined scam numbers for demo
  final List<Map<String, String>> _scamNumbers = [
    {'number': '+60123456789', 'reason': 'Frequently reported scam number'},
    {'number': '+60198765432', 'reason': 'Impersonating Bank Negara'},
    {'number': '+60111223344', 'reason': 'Tax scam reports'},
    {'number': '+60155566677', 'reason': 'Lottery scam detected'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _warningAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _warningController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _pulseController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  Future<void> _analyzeTranscript() async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      _showCustomSnackBar('Please enter a call transcript', Icons.warning, Colors.orange);
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
      _showResultNotification(analysis);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showCustomSnackBar('Error during analysis: $e', Icons.error, Colors.red);
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
      if (mounted) {
        final currentTranscript = callSegments.sublist(0, i + 1).join(' ');
        _transcriptController.text = currentTranscript;
        
        if (i == callSegments.length - 1) {
          // Analyze final transcript
          await _analyzeTranscript();
        }
      }
    }

    if (mounted) {
      setState(() {
        _isSimulatingCall = false;
      });
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      // Use a more robust approach for file picking
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name ?? 'audio_file';
        
        setState(() {
          _selectedAudioFile = fileName;
        });
        
        // Simulate audio transcription (Demo Mode)
        _simulateAudioTranscription(fileName);
      }
    } catch (e) {
      _showCustomSnackBar('Error picking file: $e', Icons.error, Colors.red);
      // Fallback: simulate with a dummy filename
      final dummyFileName = 'demo_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      setState(() {
        _selectedAudioFile = dummyFileName;
      });
      _simulateAudioTranscription(dummyFileName);
    }
  }

  void _simulateAudioTranscription(String fileName) {
    // Simulated transcription for demo
    final simulatedTranscript = '''
    [Audio File: $fileName]
    Caller: Hello, this is John from the technical support department. We've detected suspicious activity on your account.
    Victim: Oh really? What kind of activity?
    Caller: Someone tried to access your bank account from an unusual location. We need to verify your identity immediately.
    Victim: What do you need me to do?
    Caller: Please provide your IC number and the OTP code you just received. This is urgent!
    ''';
    
    _transcriptController.text = simulatedTranscript;
    _showCustomSnackBar(
      'Audio transcribed successfully (Demo Mode)',
      Icons.check_circle,
      Colors.green,
    );
  }

  void _simulateIncomingScamCall() {
    if (!_isDemoMode) return;
    
    final scamData = _scamNumbers[(_scamNumbers.length * DateTime.now().millisecond) ~/ 10000];
    setState(() {
      _scamNumber = scamData['number']!;
      _scamReason = scamData['reason']!;
      _showScamWarning = true;
    });
    
    _warningController.forward();
    
    // Auto-hide warning after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _hideScamWarning();
      }
    });
  }

  void _hideScamWarning() {
    _warningController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showScamWarning = false;
        });
      }
    });
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

  void _showResultNotification(CallAnalysis analysis) {
    Color backgroundColor;
    IconData icon;
    String message;

    switch (analysis.riskLevel) {
      case CallRiskLevel.scam:
        backgroundColor = Colors.red;
        icon = Icons.dangerous;
        message = '⚠️ SCAM DETECTED!';
        break;
      case CallRiskLevel.highRisk:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        message = '⚠️ HIGH RISK DETECTED';
        break;
      case CallRiskLevel.suspicious:
        backgroundColor = Colors.amber;
        icon = Icons.priority_high;
        message = '⚠️ SUSPICIOUS CONTENT';
        break;
      case CallRiskLevel.safe:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        message = '✅ APPEARS SAFE';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Confidence: ${analysis.confidenceScore.toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {
            // Scroll to results
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Scam Detection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About Call Detection',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _lastAnalysis = null;
                _transcriptController.clear();
                _selectedAudioFile = null;
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  const SizedBox(height: 24),
                  _buildScamWarningBanner(colorScheme),
                  const SizedBox(height: 24),
                  _buildQuickActions(colorScheme),
                  const SizedBox(height: 24),
                  _buildInputSection(colorScheme),
                  const SizedBox(height: 24),
                  _buildTranscriptExamples(colorScheme),
                  const SizedBox(height: 24),
                  if (_lastAnalysis != null) ...[
                    _buildResultsSection(colorScheme),
                    const SizedBox(height: 24),
                  ],
                  _buildEmergencyContacts(colorScheme),
                  const SizedBox(height: 100), // Extra padding for bottom nav
                ],
              ),
            ),
          ),
          // Scam warning overlay
          if (_showScamWarning)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _warningAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - _warningAnimation.value)),
                    child: Opacity(
                      opacity: _warningAnimation.value,
                      child: _buildScamWarningOverlay(colorScheme),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
          child: Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.phone_in_talk,
                      size: 64,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Call Scam Detection',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Powered by ILMU AI • Analyze calls for scam patterns',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    if (_isDemoMode) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DEMO MODE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScamWarningBanner(ColorScheme colorScheme) {
    if (!_isDemoMode) {
      return Card(
        color: colorScheme.errorContainer.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-time Call Detection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time call interception requires system permissions and is not available in demo mode. Use manual number check or recent call scan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: _simulateIncomingScamCall,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning, color: colorScheme.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulate Scam Call Warning',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to simulate incoming scam call detection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScamWarningOverlay(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: colorScheme.onError, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCAM CALL DETECTED!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scamNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _scamReason,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onError.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _hideScamWarning,
            icon: Icon(Icons.close, color: colorScheme.onError),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: _isSimulatingCall ? null : _simulateLiveCall,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isSimulatingCall
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                            )
                          : Icon(Icons.play_arrow, color: colorScheme.primary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Live Simulation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Try a demo call',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                _transcriptController.clear();
                setState(() {
                  _lastAnalysis = null;
                  _selectedAudioFile = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.refresh, color: colorScheme.secondary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Clear & Reset',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Start fresh',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Analyze Call Content',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter transcript manually or upload audio file for analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            
            // Audio file upload area
            _buildAudioUploadArea(colorScheme),
            
            const SizedBox(height: 20),
            
            // Manual transcript input
            Text(
              'Or enter transcript manually:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _transcriptController,
              maxLines: 5,
              enabled: !_isAnalyzing && !_isSimulatingCall,
              decoration: InputDecoration(
                hintText: 'Enter call transcript here...\n\nExample: "Hello, saya dari Bank Negara. Akaun anda ada masalah..."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_isAnalyzing || _isSimulatingCall) ? null : _analyzeTranscript,
                    icon: _isAnalyzing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Call'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  onPressed: () {
                    _transcriptController.clear();
                    setState(() {
                      _lastAnalysis = null;
                      _selectedAudioFile = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioUploadArea(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: _isDraggingFile ? colorScheme.primary : colorScheme.outline,
          width: _isDraggingFile ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _isDraggingFile 
            ? colorScheme.primary.withOpacity(0.1) 
            : colorScheme.surface,
      ),
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isDraggingFile = true;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _isDraggingFile = false;
          });
        },
        onAcceptWithDetails: (details) {
          setState(() {
            _isDraggingFile = false;
          });
          
          // Handle different types of dragged data
          final data = details.data;
          String fileName = '';
          
          if (data is String) {
            fileName = data;
          } else if (data.toString().contains('name:')) {
            // Try to extract filename from platform file data
            final dataString = data.toString();
            final nameMatch = RegExp(r'name: ([^,]+)').firstMatch(dataString);
            if (nameMatch != null) {
              fileName = nameMatch.group(1) ?? 'audio_file';
            }
          } else {
            fileName = 'audio_file_${DateTime.now().millisecondsSinceEpoch}';
          }
          
          setState(() {
            _selectedAudioFile = fileName;
          });
          _simulateAudioTranscription(fileName);
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: _pickAudioFile,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedAudioFile != null ? Icons.audio_file : Icons.cloud_upload,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                if (_selectedAudioFile != null) ...[
                  Text(
                    _selectedAudioFile!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to change file',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Drag & drop audio file here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'or tap to browse',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MP3, WAV, M4A, AAC • Max 10MB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranscriptExamples(ColorScheme colorScheme) {
    final samples = _detectionService.getSampleTranscripts();
    
    return Card(
      elevation: 1,
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isTranscriptExamplesExpanded = !_isTranscriptExamplesExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                leading: Icon(Icons.description, color: colorScheme.primary),
                title: Text(
                  'View Example Scam Call Transcripts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${samples.length} examples available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: samples.map((sample) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _transcriptController.text = sample['text']!;
                        setState(() {
                          _isTranscriptExamplesExpanded = false;
                        });
                        _showCustomSnackBar(
                          'Example loaded',
                          Icons.check_circle,
                          Colors.green,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sample['title'] ?? 'Scam Call Example',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sample['description'] ?? 'Example of scam call pattern',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sample['text']!.length > 100 
                                    ? '${sample['text']!.substring(0, 100)}...'
                                    : sample['text']!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            isExpanded: _isTranscriptExamplesExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Analysis Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CallAnalysisWidget(analysis: _lastAnalysis!),
      ],
    );
  }

  Widget _buildEmergencyContacts(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: colorScheme.error, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Emergency Contacts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem('Police', AppConstants.policeHotline, Icons.local_police, colorScheme),
            _buildContactItem('Bank Negara', AppConstants.bankNegaraHotline, Icons.account_balance, colorScheme),
            _buildContactItem('MCMC', AppConstants.mcmcHotline, Icons.security, colorScheme),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Scams',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.scamReportPortal,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String number, IconData icon, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  number,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // In a real app, this would make a phone call
              _showCustomSnackBar('Would call: $number', Icons.call, Colors.blue);
            },
            icon: const Icon(Icons.call),
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About JagaCall'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${AppConstants.appVersion}'),
              const SizedBox(height: 8),
              Text(AppConstants.appDescription),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Models Used:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ILMU-text - Scam text analysis\n'
                      '• ILMU-asr - Speech to text (Demo Mode)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Important Notice',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This tool is for assistance only. Always be vigilant and verify information with relevant parties.\n\nAudio transcription and real-time call detection are simulated in demo mode.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}