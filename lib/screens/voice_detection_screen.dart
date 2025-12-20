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
        title: const Text('AI Voice Detection'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About Deepfake Detection',
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
            _buildInputSection(colorScheme),
            const SizedBox(height: 24),
            if (_currentAnalysis != null) ...[
              _buildResultsSection(colorScheme),
              const SizedBox(height: 24),
            ],
            _buildSafetyTips(colorScheme),
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
                borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 80,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AI Voice Detection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Detect voice cloning & scam calls\nProtect from fake emergencies & impersonation',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PROTOTYPE DEMO',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildInputSection(ColorScheme colorScheme) {
    return VoiceInputWidget(
      onVoiceSubmitted: _analyzeVoice,
      isLoading: _isLoading,
    );
  }

  Widget _buildSafetyTips(ColorScheme colorScheme) {
    final tips = [
      {
        'icon': Icons.phone_disabled,
        'title': 'Hang Up Immediately',
        'description': 'If suspicious, end the call immediately',
        'color': colorScheme.error,
      },
      {
        'icon': Icons.contact_phone,
        'title': 'Verify Independently',
        'description': 'Use official numbers to verify',
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.no_encryption,
        'title': 'Never Share OTP',
        'description': 'Never share OTP codes',
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.record_voice_over,
        'title': 'Trust Your Instincts',
        'description': 'Unnatural voice = be suspicious',
        'color': colorScheme.tertiary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shield,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Protection Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      tip['color'] as Color,
                      (tip['color'] as Color).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tip['icon'] as IconData,
                        size: 32,
                        color: tip['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip['title'] as String,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (tip['color'] as Color),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
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


  Future<void> _analyzeVoice(String transcript, {String? audioFilePath, Duration? duration}) async {
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


  void _resetAnalysis() {
    setState(() {
      _currentAnalysis = null;
    });
    _fadeController.reset();
  }

  void _showInfo() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About AI Voice Detection'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Voice Detection by ILMU',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'AI Technology',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Voice cloning detection\n'
                      '• Voice pattern analysis\n'
                      '• Scam pattern recognition\n'
                      '• Behavioral indicators',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gpp_good, color: colorScheme.onTertiaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'Detection Capabilities',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Fake emergency calls\n'
                      '• Authority impersonation\n'
                      '• Bank verification scams\n'
                      '• Voice synthesis',
                      style: TextStyle(
                        color: colorScheme.onTertiaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Important Disclaimer',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a PROTOTYPE DEMO for educational purposes.\n'
                      'Always verify suspicious calls through official channels.\n'
                      'JagaCall and ILMU are not responsible for decisions made based on this analysis.',
                      style: TextStyle(
                        color: colorScheme.error,
                        height: 1.4,
                      ),
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
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}