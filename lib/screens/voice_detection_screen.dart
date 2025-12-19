import 'package:flutter/material.dart';
import '../models/voice_analysis.dart';
import '../services/voice_analysis_service.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/voice_analysis_widget.dart';

class VoiceDetectionScreen extends StatefulWidget {
  const VoiceDetectionScreen({super.key});

  @override
  State<VoiceDetectionScreen> createState() => _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState extends State<VoiceDetectionScreen>
    with TickerProviderStateMixin {
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  VoiceAnalysis? _currentAnalysis;
  bool _isLoading = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Scam Detection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About Voice Detection',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 24),
            _buildQuickActions(colorScheme),
            const SizedBox(height: 24),
            _buildInputSection(colorScheme),
            const SizedBox(height: 24),
            if (_currentAnalysis != null) ...[
              _buildResultsSection(colorScheme),
              const SizedBox(height: 24),
            ],
            _buildFeaturesSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading ? _pulseAnimation.value : 1.0,
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
                      Icons.mic,
                      size: 64,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Voice Scam Detection',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyze voice transcripts for scam indicators using ILMU AI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: _loadScamExample,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 32,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Load Scam Example',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
              onTap: _loadSafeExample,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Load Safe Example',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice Transcript Input',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            VoiceInputWidget(
              onTranscriptSubmitted: _analyzeVoiceTranscript,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analysis Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              VoiceAnalysisWidget(
                analysis: _currentAnalysis!,
                onAnalyzeAnother: _resetAnalysis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(ColorScheme colorScheme) {
    final features = [
      {
        'icon': Icons.gavel,
        'title': 'Authority Detection',
        'description': 'Detects impersonation of Bank Negara, PDRM, LHDN',
      },
      {
        'icon': Icons.timer,
        'title': 'Urgency Tactics',
        'description': 'Identifies pressure and time-sensitive requests',
      },
      {
        'icon': Icons.psychology,
        'title': 'Emotional Analysis',
        'description': 'Recognizes manipulation and fear tactics',
      },
      {
        'icon': Icons.attach_money,
        'title': 'Financial Flags',
        'description': 'Flags suspicious payment requests',
      },
      {
        'icon': Icons.language,
        'title': 'Multi-Language',
        'description': 'Supports English and Bahasa Malaysia',
      },
      {
        'icon': Icons.assessment,
        'title': 'Risk Assessment',
        'description': 'Provides detailed risk analysis',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
      
      // Trigger fade-in animation
      _fadeController.forward();
      
      // Show result notification
      _showResultNotification(analysis);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showCustomSnackBar(
        'Analysis failed: ${e.toString()}',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showResultNotification(VoiceAnalysis analysis) {
    Color backgroundColor;
    String message;
    IconData icon;

    switch (analysis.riskLevel) {
      case VoiceRiskLevel.scam:
        backgroundColor = Colors.red;
        message = 'SCAM DETECTED! High risk indicators found.';
        icon = Icons.dangerous;
        break;
      case VoiceRiskLevel.highRisk:
        backgroundColor = Colors.orange;
        message = 'HIGH RISK: Multiple suspicious elements detected.';
        icon = Icons.warning;
        break;
      case VoiceRiskLevel.suspicious:
        backgroundColor = Colors.amber;
        message = 'SUSPICIOUS: Some elements require caution.';
        icon = Icons.warning_amber;
        break;
      case VoiceRiskLevel.safe:
        backgroundColor = Colors.green;
        message = 'APPEARS SAFE: No major scam indicators detected.';
        icon = Icons.check_circle;
        break;
    }

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
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
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

  void _loadScamExample() {
    const scamTranscript = '''
    Hello, this is Officer Ahmad from Bank Negara Malaysia. We have detected suspicious activity in your bank account. 
    You need to transfer your money to a secure government account immediately to protect your funds. 
    This is a matter of national security. Do not tell anyone about this call as it is confidential. 
    Please provide your banking details now or your account will be frozen within the hour.
    ''';
    
    _analyzeVoiceTranscript(scamTranscript);
    _showCustomSnackBar(
      'Scam example loaded',
      Icons.warning,
      Colors.orange,
    );
  }

  void _loadSafeExample() {
    const safeTranscript = '''
    Hi, this is Sarah from your local bank. I'm calling to inform you about our new mobile banking app features. 
    There's no urgent action required from your side. You can visit our website at your convenience 
    to learn more about the updated security features. Have a great day!
    ''';
    
    _analyzeVoiceTranscript(safeTranscript);
    _showCustomSnackBar(
      'Safe example loaded',
      Icons.check_circle,
      Colors.green,
    );
  }

  void _resetAnalysis() {
    setState(() {
      _currentAnalysis = null;
    });
    _fadeController.reset();
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About Voice Detection'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Voice Scam Detection using ILMU AI',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
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
                      '• ILMU-text-free-safe - Voice pattern analysis\n'
                      '• ILMU-text-intent - Intent recognition\n'
                      '• ILMU-text-emotion - Emotional analysis',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How it works:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text('1. Input voice transcript or use examples'),
              const Text('2. AI analyzes patterns and intent'),
              const Text('3. Risk assessment is provided'),
              const Text('4. Detailed recommendations are given'),
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
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Disclaimer',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool is for assistance only. Always verify suspicious calls through official channels.',
                      style: TextStyle(color: Colors.red),
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
      ),
    );
  }
}