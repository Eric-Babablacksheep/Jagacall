import 'package:flutter/material.dart';
import '../models/call_analysis.dart';

class CallAnalysisWidget extends StatelessWidget {
  final CallAnalysis analysis;

  const CallAnalysisWidget({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskLevelHeader(context),
            const SizedBox(height: 16),
            _buildTranscriptSection(context),
            const SizedBox(height: 16),
            _buildAnalysisDetails(context),
            if (analysis.warningSigns.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWarningSigns(context),
            ],
            if (analysis.recommendedActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRecommendedActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskLevelHeader(BuildContext context) {
    final riskColor = _getRiskColor(analysis.riskLevel);
    final riskIcon = _getRiskIcon(analysis.riskLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            riskIcon,
            size: 48,
            color: riskColor,
          ),
          const SizedBox(height: 8),
          Text(
            analysis.riskLevel.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: riskColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            analysis.riskLevel.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: riskColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(analysis.confidenceScore * 100).toInt()}% Keyakinan',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transkrip Panggilan:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            analysis.transcript,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maklumat Analisis:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Kategori', analysis.category.displayName),
        _buildDetailRow('Model', analysis.analysisModel),
        _buildDetailRow('Masa', _formatDateTime(analysis.timestamp)),
      ],
    );
  }

  Widget _buildWarningSigns(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Tanda-tanda Amaran:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...analysis.warningSigns.map((sign) => Padding(
          padding: const EdgeInsets.only(left: 28, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(sign)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRecommendedActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Tindakan Disyorkan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...analysis.recommendedActions.map((action) => Padding(
          padding: const EdgeInsets.only(left: 28, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✓ ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(action)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getRiskColor(CallRiskLevel riskLevel) {
    switch (riskLevel) {
      case CallRiskLevel.safe:
        return Colors.green;
      case CallRiskLevel.suspicious:
        return Colors.orange;
      case CallRiskLevel.highRisk:
        return Colors.red;
      case CallRiskLevel.scam:
        return Colors.red[900]!;
    }
  }

  IconData _getRiskIcon(CallRiskLevel riskLevel) {
    switch (riskLevel) {
      case CallRiskLevel.safe:
        return Icons.check_circle;
      case CallRiskLevel.suspicious:
        return Icons.warning;
      case CallRiskLevel.highRisk:
        return Icons.error;
      case CallRiskLevel.scam:
        return Icons.dangerous;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}