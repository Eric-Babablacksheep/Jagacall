import 'package:flutter/material.dart';
import '../models/file_analysis.dart';

class FileAnalysisWidget extends StatelessWidget {
  final FileAnalysis analysis;

  const FileAnalysisWidget({
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
            _buildFileInfo(context),
            const SizedBox(height: 16),
            _buildAnalysisDetails(context),
            if (analysis.warningSigns.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWarningSigns(context),
            ],
            const SizedBox(height: 16),
            _buildRecommendedAction(context),
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
              '${analysis.confidence}% Keyakinan',
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

  Widget _buildFileInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Information:',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('File Name', analysis.fileName),
              _buildInfoRow('File Type', analysis.fileType.displayName),
              _buildInfoRow('Source', analysis.sourceApp.displayName),
              if (analysis.permissions.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  'Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: analysis.permissions.map((permission) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        permission.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
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
          'AI Analysis:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Scam Type', analysis.scamType.displayName),
              _buildInfoRow('AI Model', analysis.analysisModel),
              _buildInfoRow('Analysis Time', _formatDateTime(analysis.timestamp)),
              const SizedBox(height: 8),
              Text(
                'Reason:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                analysis.reason,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
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
              'Warning Signs:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: analysis.warningSigns.map((sign) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(sign, style: const TextStyle(fontSize: 12))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedAction(BuildContext context) {
    final actionColor = analysis.riskLevel == FileRiskLevel.high
        ? Colors.red
        : analysis.riskLevel == FileRiskLevel.medium
            ? Colors.orange
            : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: actionColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recommended Action:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: actionColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: actionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: actionColor.withOpacity(0.3)),
          ),
          child: Text(
            analysis.recommendedAction,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: actionColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Color _getRiskColor(FileRiskLevel riskLevel) {
    switch (riskLevel) {
      case FileRiskLevel.low:
        return Colors.green;
      case FileRiskLevel.medium:
        return Colors.orange;
      case FileRiskLevel.high:
        return Colors.red;
    }
  }

  IconData _getRiskIcon(FileRiskLevel riskLevel) {
    switch (riskLevel) {
      case FileRiskLevel.low:
        return Icons.check_circle;
      case FileRiskLevel.medium:
        return Icons.warning;
      case FileRiskLevel.high:
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