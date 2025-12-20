import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import '../models/file_analysis.dart';

class FileInputWidget extends StatefulWidget {
  final TextEditingController fileNameController;
  final FileType selectedFileType;
  final SourceApp selectedSourceApp;
  final List<String> selectedPermissions;
  final Function(FileType) onFileTypeChanged;
  final Function(SourceApp) onSourceAppChanged;
  final Function(List<String>) onPermissionsChanged;
  final Function(Map<String, dynamic>) onSampleSelected;
  final Function(String?) onFilePathChanged; // Added callback for file path
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
    required this.onFilePathChanged, // Added required callback
    required this.sampleFiles,
    required this.isAnalyzing,
  });

  @override
  State<FileInputWidget> createState() => _FileInputWidgetState();
}

class _FileInputWidgetState extends State<FileInputWidget> {
  bool _isDragOver = false;

  Future<void> _pickFile() async {
    if (widget.isAnalyzing) return;

    try {
      fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: [
          'exe', 'scr', 'dll', 'js', 'vbs', 'zip', 'rar', 'apk', 'iso', 'img',
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'gif', 'txt'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final fileName = file.name;
        final filePath = file.path;
        final extension = fileName.split('.').last.toLowerCase();
        
        // Determine file type
        FileType fileType = FileType.other;
        for (final type in FileType.values) {
          if (type.name == extension) {
            fileType = type;
            break;
          }
        }

        widget.fileNameController.text = fileName;
        widget.onFileTypeChanged(fileType);
        widget.onFilePathChanged(filePath); // Pass file path to parent
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? colorScheme.primary : colorScheme.outline,
              width: _isDragOver ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isDragOver
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surface,
          ),
          child: DragTarget<Object>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _isDragOver = true;
              });
              return true;
            },
            onLeave: (data) {
              setState(() {
                _isDragOver = false;
              });
            },
            onAcceptWithDetails: (details) {
              setState(() {
                _isDragOver = false;
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
                  fileName = nameMatch.group(1) ?? 'file';
                }
              } else {
                fileName = 'file_${DateTime.now().millisecondsSinceEpoch}';
              }
              
              widget.fileNameController.text = fileName;
              widget.onFilePathChanged(null); // Clear file path for drag & drop (demo mode)
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File selected: $fileName'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.fileNameController.text.isNotEmpty ? Icons.description : Icons.cloud_upload,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    if (widget.fileNameController.text.isNotEmpty) ...[
                      Text(
                        widget.fileNameController.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                        'Drag & drop file here',
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
                        'EXE, SCR, DLL, JS, VBS, ZIP, RAR, APK, ISO, IMG, PDF, DOC, XLS, Images, TXT',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.fileNameController,
          decoration: InputDecoration(
            labelText: 'File Name',
            hintText: 'Selected file name will appear here',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description),
          ),
          enabled: !widget.isAnalyzing,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildFileTypeDropdown(),
        const SizedBox(height: 16),
        _buildSourceAppDropdown(),
        if (widget.selectedFileType == FileType.apk) ...[
          const SizedBox(height: 16),
          _buildPermissionsSection(),
        ],
        const SizedBox(height: 16),
        _buildSampleFilesSection(),
      ],
    );
  }

  Widget _buildFileTypeDropdown() {
    return DropdownButtonFormField<FileType>(
      value: widget.selectedFileType,
      decoration: const InputDecoration(
        labelText: 'File Type',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.description),
      ),
      items: FileType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: widget.isAnalyzing ? null : (type) {
        if (type != null) widget.onFileTypeChanged(type);
      },
    );
  }

  Widget _buildSourceAppDropdown() {
    return DropdownButtonFormField<SourceApp>(
      value: widget.selectedSourceApp,
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
      onChanged: widget.isAnalyzing ? null : (app) {
        if (app != null) widget.onSourceAppChanged(app);
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
            final isSelected = widget.selectedPermissions.contains(permission);
            return FilterChip(
              label: Text(
                permission.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: widget.isAnalyzing ? null : (selected) {
                final newPermissions = List<String>.from(widget.selectedPermissions);
                if (selected) {
                  newPermissions.add(permission);
                } else {
                  newPermissions.remove(permission);
                }
                widget.onPermissionsChanged(newPermissions);
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
        ...widget.sampleFiles.asMap().entries.map((entry) {
          final index = entry.key;
          final sample = entry.value;
          final riskLevel = sample['riskLevel'] as String;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: widget.isAnalyzing ? null : () => widget.onSampleSelected(sample),
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
                    Text(
                      'Click to use',
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.isAnalyzing ? Colors.grey : Colors.blue[600],
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