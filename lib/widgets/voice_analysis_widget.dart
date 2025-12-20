import 'package:flutter/material.dart';
import '../models/voice_analysis.dart';

class VoiceAnalysisWidget extends StatelessWidget {
  final VoiceAnalysis analysis;
  final VoidCallback? onAnalyzeAnother;

  const VoiceAnalysisWidget({
    Key? key,
    required this.analysis,
    this.onAnalyzeAnother,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRiskLevelCard(context),
          const SizedBox(height: 16),
          _buildTranscriptCard(context),
          const SizedBox(height: 16),
          _buildAnalysisDetails(context),
          const SizedBox(height: 16),
          _buildRecommendedAction(context),
          const SizedBox(height: 16),
          _buildDisclaimer(context),
          if (onAnalyzeAnother != null) ...[
            const SizedBox(height: 24),
            _buildAnalyzeAnotherButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color cardColor;
    Color textColor;
    IconData iconData;
    String title;

    switch (analysis.riskLevel) {
      case VoiceRiskLevel.scam:
        cardColor = colorScheme.errorContainer;
        textColor = colorScheme.error;
        iconData = Icons.dangerous;
        title = 'LIKELY VOICE CLONE';
        break;
      case VoiceRiskLevel.highRisk:
        cardColor = colorScheme.secondaryContainer;
        textColor = colorScheme.secondary;
        iconData = Icons.warning;
        title = 'HIGH RISK';
        break;
      case VoiceRiskLevel.suspicious:
        cardColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.tertiary;
        iconData = Icons.priority_high;
        title = 'SUSPICIOUS';
        break;
      case VoiceRiskLevel.safe:
        cardColor = colorScheme.primaryContainer;
        textColor = colorScheme.primary;
        iconData = Icons.check_circle;
        title = 'LOW RISK';
        break;
    }

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(iconData, color: textColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (analysis.scamType != VoiceScamType.none) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getScamTypeDisplay(analysis.scamType),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence Level',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${analysis.confidenceScore.toInt()}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildConfidenceBar(colorScheme, context),
                  ],
                ),
              ),
              if (analysis.isDemoMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI DEEPFAKE DETECTION (DEMO)',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(ColorScheme colorScheme, BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colorScheme.surfaceVariant,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: analysis.confidenceScore / 100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                _getConfidenceColor(analysis.confidenceScore, context),
                _getConfidenceColor(analysis.confidenceScore, context).withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence, BuildContext context) {
    final theme = Theme.of(context);
    if (confidence >= 80) return theme.colorScheme.error;
    if (confidence >= 60) return theme.colorScheme.secondary;
    if (confidence >= 40) return theme.colorScheme.tertiary;
    return theme.colorScheme.primary;
  }

  String _getScamTypeDisplay(VoiceScamType type) {
    switch (type) {
      case VoiceScamType.familyEmergency:
        return 'Fake Family Emergency';
      case VoiceScamType.authorityImpersonation:
        return 'Fake Authority Call';
      case VoiceScamType.bankVerification:
        return 'Fake Bank Verification';
      case VoiceScamType.other:
        return 'Other Suspicious Activity';
      case VoiceScamType.none:
        return 'None Detected';
    }
  }

  Widget _buildTranscriptCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Transcript',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                analysis.transcript,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  Icons.analytics,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Analysis Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (analysis.voiceIndicators.isNotEmpty) ...[
              _buildVoiceIndicatorsSection(colorScheme, context),
              const SizedBox(height: 16),
            ],
            if (analysis.linguisticRedFlags.isNotEmpty) ...[
              _buildFlagSection('Linguistic Red Flags:', analysis.linguisticRedFlags, colorScheme.error, context),
              const SizedBox(height: 16),
            ],
            if (analysis.behavioralRedFlags.isNotEmpty) ...[
              _buildFlagSection('Behavioral Red Flags:', analysis.behavioralRedFlags, colorScheme.secondary, context),
              const SizedBox(height: 16),
            ],
            _buildMetadataSection(colorScheme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceIndicatorsSection(ColorScheme colorScheme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.graphic_eq,
                color: colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Analysis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.voiceIndicators.map((indicator) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    indicator,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFlagSection(String title, List<String> flags, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        ...flags.map((flag) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_right,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMetadataSection(ColorScheme colorScheme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetadataRow('AI Model:', analysis.analysisModel, colorScheme, context),
          _buildMetadataRow('Timestamp:', _formatDateTime(analysis.timestamp), colorScheme, context),
          if (analysis.recordingDuration != null)
            _buildMetadataRow('Duration:', '${analysis.recordingDuration!.inSeconds}s', colorScheme, context),
          if (analysis.audioFilePath != null)
            _buildMetadataRow('Source:', 'Audio File', colorScheme, context),
          if (analysis.isDemoMode)
            _buildMetadataRow('Mode:', 'Prototype Demo', colorScheme, context),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, ColorScheme colorScheme, BuildContext context, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedAction(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Safety Advice',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  analysis.recommendedAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Disclaimer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            analysis.disclaimer,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeAnotherButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onAnalyzeAnother,
        icon: const Icon(Icons.mic),
        label: const Text('Analyze Another Voice'),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}