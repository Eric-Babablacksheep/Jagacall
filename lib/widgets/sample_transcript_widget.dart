import 'package:flutter/material.dart';

class SampleTranscriptWidget extends StatelessWidget {
  final List<Map<String, String>> samples;
  final Function(Map<String, String>) onSampleSelected;

  const SampleTranscriptWidget({
    super.key,
    required this.samples,
    required this.onSampleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contoh Transkrip:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...samples.asMap().entries.map((entry) {
          final index = entry.key;
          final sample = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => onSampleSelected(sample),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRiskColor(sample['risk']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRiskColor(sample['risk']).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRiskIcon(sample['risk']),
                          size: 16,
                          color: _getRiskColor(sample['risk']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Contoh ${index + 1}: ${_getCategoryName(sample['category'])}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(sample['risk']),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sample['text']!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Klik untuk gunakan',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getRiskColor(String? risk) {
    switch (risk) {
      case 'safe':
        return Colors.green;
      case 'suspicious':
        return Colors.orange;
      case 'highRisk':
        return Colors.red;
      case 'scam':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String? risk) {
    switch (risk) {
      case 'safe':
        return Icons.check_circle;
      case 'suspicious':
        return Icons.warning;
      case 'highRisk':
        return Icons.error;
      case 'scam':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  String _getCategoryName(String? category) {
    switch (category) {
      case 'bankImpersonation':
        return 'Penyamaran Bank';
      case 'governmentImpersonation':
        return 'Penyamaran Kerajaan';
      case 'lotteryScam':
        return 'Penipuan Hadiah';
      case 'techSupport':
        return 'Sokongan Teknikal Palsu';
      case 'loveScam':
        return 'Penipuan Cinta';
      case 'investmentScam':
        return 'Penipuan Pelaburan';
      case 'kidnapping':
        return 'Ancaman Penculikan';
      case 'other':
        return 'Lain-lain';
      default:
        return 'Tidak Diketahui';
    }
  }
}