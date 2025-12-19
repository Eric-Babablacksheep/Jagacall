import 'package:flutter/material.dart';
import '../models/file_analysis.dart';

class FileInputWidget extends StatelessWidget {
  final TextEditingController fileNameController;
  final FileType selectedFileType;
  final SourceApp selectedSourceApp;
  final List<String> selectedPermissions;
  final Function(FileType) onFileTypeChanged;
  final Function(SourceApp) onSourceAppChanged;
  final Function(List<String>) onPermissionsChanged;
  final Function(Map<String, dynamic>) onSampleSelected;
  final List<Map<String, dynamic>> sampleFiles;
  final bool isAnalyzing;

  const FileInputWidget({
    super.key,
    required this.fileNameController,
    required this.selectedFileType,
    required this.selectedSourceApp,
    required this.selectedPermissions,
    required this.onFileTypeChanged,
    required this.onSourceAppChanged,
    required this.onPermissionsChanged,
    required this.onSampleSelected,
    required this.sampleFiles,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fileNameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Example: Maybank_Security_Update.apk',
                border: OutlineInputBorder(),
              ),
              enabled: !isAnalyzing,
            ),
            const SizedBox(height: 16),
            _buildFileTypeDropdown(),
            const SizedBox(height: 16),
            _buildSourceAppDropdown(),
            if (selectedFileType == FileType.apk) ...[
              const SizedBox(height: 16),
              _buildPermissionsSection(),
            ],
            const SizedBox(height: 16),
            _buildSampleFilesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeDropdown() {
    return DropdownButtonFormField<FileType>(
      value: selectedFileType,
      decoration: const InputDecoration(
        labelText: 'File Type',
        border: OutlineInputBorder(),
      ),
      items: FileType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: isAnalyzing ? null : (type) {
        if (type != null) onFileTypeChanged(type);
      },
    );
  }

  Widget _buildSourceAppDropdown() {
    return DropdownButtonFormField<SourceApp>(
      value: selectedSourceApp,
      decoration: const InputDecoration(
        labelText: 'Source App',
        border: OutlineInputBorder(),
      ),
      items: SourceApp.values.map((app) {
        return DropdownMenuItem(
          value: app,
          child: Text(app.displayName),
        );
      }).toList(),
      onChanged: isAnalyzing ? null : (app) {
        if (app != null) onSourceAppChanged(app);
      },
    );
  }

  Widget _buildPermissionsSection() {
    final allPermissions = [
      'camera', 'location', 'contacts', 'sms', 'call_log',
      'microphone', 'storage', 'phone', 'calendar', 'body_sensors'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requested Permissions (APK):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: allPermissions.map((permission) {
            final isSelected = selectedPermissions.contains(permission);
            return FilterChip(
              label: Text(
                permission.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: isAnalyzing ? null : (selected) {
                final newPermissions = List<String>.from(selectedPermissions);
                if (selected) {
                  newPermissions.add(permission);
                } else {
                  newPermissions.remove(permission);
                }
                onPermissionsChanged(newPermissions);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.orange[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSampleFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sample Files for Demo:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sampleFiles.asMap().entries.map((entry) {
          final index = entry.key;
          final sample = entry.value;
          final riskLevel = sample['riskLevel'] as String;
          final scamType = sample['scamType'] as String;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: isAnalyzing ? null : () => onSampleSelected(sample),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRiskColor(riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRiskColor(riskLevel).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRiskIcon(riskLevel),
                          size: 16,
                          color: _getRiskColor(riskLevel),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sample['fileName'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(riskLevel),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${sample['confidence']}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getRiskColor(riskLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${FileType.values.firstWhere((e) => e.name == sample['fileType']).displayName} • ',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          ScamType.values.firstWhere((e) => e.name == scamType).displayName,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (sample['permissions'] != null &&
                        (sample['permissions'] as List).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Permissions: ${(sample['permissions'] as List).take(3).join(", ")}${(sample['permissions'] as List).length > 3 ? "..." : ""}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Click to use',
                      style: TextStyle(
                        fontSize: 10,
                        color: isAnalyzing ? Colors.grey : Colors.blue[600],
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

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }
}