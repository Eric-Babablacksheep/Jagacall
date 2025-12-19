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
          _buildRiskLevelCard(),
          const SizedBox(height: 16),
          _buildTranscriptCard(),
          const SizedBox(height: 16),
          _buildAnalysisDetails(),
          const SizedBox(height: 16),
          _buildRecommendedAction(),
          const SizedBox(height: 16),
          _buildDisclaimer(),
          if (onAnalyzeAnother != null) ...[
            const SizedBox(height: 24),
            _buildAnalyzeAnotherButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard() {
    Color cardColor;
    Color textColor;
    IconData iconData;
    String title;

    switch (analysis.riskLevel) {
      case VoiceRiskLevel.scam:
        cardColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        iconData = Icons.dangerous;
        title = 'HIGH RISK - SCAM DETECTED';
        break;
      case VoiceRiskLevel.highRisk:
        cardColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        iconData = Icons.warning;
        title = 'HIGH RISK - SUSPICIOUS';
        break;
      case VoiceRiskLevel.suspicious:
        cardColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade900;
        iconData = Icons.priority_high;
        title = 'SUSPICIOUS';
        break;
      case VoiceRiskLevel.safe:
        cardColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        iconData = Icons.check_circle;
        title = 'APPEARS SAFE';
        break;
    }

    return Card(
      color: cardColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(iconData, color: textColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildConfidenceBar(),
                ),
                const SizedBox(width: 16),
                Text(
                  '${analysis.confidenceScore.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            if (analysis.scamType != VoiceScamType.none) ...[
              const SizedBox(height: 8),
              Text(
                'Type: ${_getScamTypeDisplay(analysis.scamType)}',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade300,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: analysis.confidenceScore / 100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _getConfidenceColor(analysis.confidenceScore),
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.red;
    if (confidence >= 60) return Colors.orange;
    if (confidence >= 40) return Colors.yellow;
    return Colors.green;
  }

  String _getScamTypeDisplay(VoiceScamType type) {
    switch (type) {
      case VoiceScamType.impersonation:
        return 'Authority Impersonation';
      case VoiceScamType.urgency:
        return 'Urgency Tactics';
      case VoiceScamType.emotionalManipulation:
        return 'Emotional Manipulation';
      case VoiceScamType.financialRequest:
        return 'Financial Request';
      case VoiceScamType.threat:
        return 'Threat/Intimidation';
      case VoiceScamType.other:
        return 'Other Suspicious Activity';
      case VoiceScamType.none:
        return 'None Detected';
    }
  }

  Widget _buildTranscriptCard() {
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
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (analysis.linguisticRedFlags.isNotEmpty) ...[
              _buildFlagSection('Linguistic Red Flags:', analysis.linguisticRedFlags, Colors.red),
              const SizedBox(height: 12),
            ],
            if (analysis.behavioralRedFlags.isNotEmpty) ...[
              _buildFlagSection('Behavioral Red Flags:', analysis.behavioralRedFlags, Colors.orange),
              const SizedBox(height: 12),
            ],
            _buildMetadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagSection(String title, List<String> flags, Color color) {
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
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          _buildMetadataRow('Model:', analysis.analysisModel),
          _buildMetadataRow('Timestamp:', _formatDateTime(analysis.timestamp)),
          if (analysis.isDemoMode)
            _buildMetadataRow('Mode:', 'Demo Mode', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedAction() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.blue.shade900,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended Action',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              analysis.recommendedAction,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
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

  Widget _buildAnalyzeAnotherButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAnalyzeAnother,
        icon: const Icon(Icons.mic),
        label: const Text('Analyze Another Voice'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
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