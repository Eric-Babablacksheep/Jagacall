import 'package:flutter/material.dart';
import '../models/file_analysis.dart';
import '../services/file_analysis_service.dart';
import '../constants/app_constants.dart';
import '../widgets/file_analysis_widget.dart';
import '../widgets/file_input_widget.dart';

class FileScanScreen extends StatefulWidget {
  const FileScanScreen({super.key});

  @override
  State<FileScanScreen> createState() => _FileScanScreenState();
}

class _FileScanScreenState extends State<FileScanScreen> {
  final FileAnalysisService _analysisService = FileAnalysisService();
  final TextEditingController _fileNameController = TextEditingController();
  FileAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;
  
  FileType _selectedFileType = FileType.apk;
  SourceApp _selectedSourceApp = SourceApp.whatsapp;
  List<String> _selectedPermissions = [];

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFile() async {
    final fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) {
      _showSnackBar('Sila masukkan nama fail', Colors.orange);
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysis = await _analysisService.analyzeFile(
        fileName: fileName,
        fileType: _selectedFileType,
        sourceApp: _selectedSourceApp,
        permissions: _selectedPermissions,
      );
      setState(() {
        _lastAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Ralat semasa analisis: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JagaCall - File Scanner'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            FileInputWidget(
              fileNameController: _fileNameController,
              selectedFileType: _selectedFileType,
              selectedSourceApp: _selectedSourceApp,
              selectedPermissions: _selectedPermissions,
              onFileTypeChanged: (type) => setState(() => _selectedFileType = type),
              onSourceAppChanged: (app) => setState(() => _selectedSourceApp = app),
              onPermissionsChanged: (permissions) => setState(() => _selectedPermissions = permissions),
              onSampleSelected: (sample) {
                _fileNameController.text = sample['fileName'] as String;
                setState(() {
                  _selectedFileType = FileType.values.firstWhere(
                    (e) => e.name == sample['fileType'],
                  );
                  _selectedSourceApp = SourceApp.values.firstWhere(
                    (e) => e.name == sample['sourceApp'],
                  );
                  _selectedPermissions = List<String>.from(sample['permissions'] as List);
                });
              },
              sampleFiles: _analysisService.getSampleFiles(),
              isAnalyzing: _isAnalyzing,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeFile,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.scanner),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Scan File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_lastAnalysis != null) ...[
              const Text(
                'Analysis Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FileAnalysisWidget(analysis: _lastAnalysis!),
            ],
            const SizedBox(height: 24),
            _buildSafetyTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 48,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 8),
            Text(
              'APK & File Scam Detection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use ILMU AI to detect dangerous files and scams',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'File Safety Tips:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('• Do not install APKs from unknown sources'),
            _buildTip('• Check sender name before opening files'),
            _buildTip('• Pay attention to requested permissions'),
            _buildTip('• Use antivirus to scan files'),
            _buildTip('• Report suspicious files to authorities'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        tip,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About File Scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            const Text('Dangerous file detector using ILMU AI'),
            const SizedBox(height: 16),
            const Text('AI Models Used:'),
            const Text('• ILMU-text-free-safe - File risk analysis'),
            const SizedBox(height: 16),
            const Text(
              'Supported File Types:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• APK (Android App)'),
            const Text('• PDF (Document)'),
            const Text('• DOC/DOCX (Microsoft Word)'),
            const Text('• XLS/XLSX (Microsoft Excel)'),
            const Text('• IMG (Image)'),
            const SizedBox(height: 16),
            const Text(
              'Warning: This tool is for assistance only. Always be cautious with files from unknown sources.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}