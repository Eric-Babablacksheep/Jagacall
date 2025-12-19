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

class _FileScanScreenState extends State<FileScanScreen>
    with TickerProviderStateMixin {
  final FileAnalysisService _analysisService = FileAnalysisService();
  final TextEditingController _fileNameController = TextEditingController();
  FileAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;
  
  FileType _selectedFileType = FileType.apk;
  SourceApp _selectedSourceApp = SourceApp.whatsapp;
  List<String> _selectedPermissions = [];
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFile() async {
    final fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) {
      _showCustomSnackBar(
        'Please enter a file name',
        Icons.warning_amber,
        Colors.orange,
      );
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
      
      _showCustomSnackBar(
        'File analysis completed successfully!',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showCustomSnackBar(
        'Error during analysis: $e',
        Icons.error,
        Colors.red,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About File Scanner',
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
            _buildAnalyzeButton(colorScheme),
            const SizedBox(height: 24),
            if (_lastAnalysis != null) ...[
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
          scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
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
                      Icons.insert_drive_file,
                      size: 64,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'APK & File Scam Detection',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use ILMU AI to detect dangerous files and scams',
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
              onTap: _loadSampleMalicious,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bug_report,
                      size: 32,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Load Malicious Sample',
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
              onTap: _loadSampleSafe,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Load Safe Sample',
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
            Text(
              'File Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _isAnalyzing ? null : _analyzeFile,
      icon: _isAnalyzing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.scanner),
      label: Text(_isAnalyzing ? 'Analyzing...' : 'Scan File'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResultsSection(ColorScheme colorScheme) {
    return Column(
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
        FileAnalysisWidget(analysis: _lastAnalysis!),
      ],
    );
  }

  Widget _buildSafetyTips(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'File Safety Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTip('Do not install APKs from unknown sources', colorScheme),
            _buildTip('Check sender name before opening files', colorScheme),
            _buildTip('Pay attention to requested permissions', colorScheme),
            _buildTip('Use antivirus to scan files', colorScheme),
            _buildTip('Report suspicious files to authorities', colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadSampleMalicious() {
    final maliciousSample = _analysisService.getSampleFiles().firstWhere(
      (sample) => sample['riskLevel'] == 'high',
      orElse: () => _analysisService.getSampleFiles().first,
    );
    
    _fileNameController.text = maliciousSample['fileName'] as String;
    setState(() {
      _selectedFileType = FileType.values.firstWhere(
        (e) => e.name == maliciousSample['fileType'],
      );
      _selectedSourceApp = SourceApp.values.firstWhere(
        (e) => e.name == maliciousSample['sourceApp'],
      );
      _selectedPermissions = List<String>.from(maliciousSample['permissions'] as List);
    });
    
    _showCustomSnackBar(
      'Malicious sample loaded',
      Icons.warning,
      Colors.orange,
    );
  }

  void _loadSampleSafe() {
    final safeSample = _analysisService.getSampleFiles().firstWhere(
      (sample) => sample['riskLevel'] == 'low',
      orElse: () => _analysisService.getSampleFiles().last,
    );
    
    _fileNameController.text = safeSample['fileName'] as String;
    setState(() {
      _selectedFileType = FileType.values.firstWhere(
        (e) => e.name == safeSample['fileType'],
      );
      _selectedSourceApp = SourceApp.values.firstWhere(
        (e) => e.name == safeSample['sourceApp'],
      );
      _selectedPermissions = List<String>.from(safeSample['permissions'] as List);
    });
    
    _showCustomSnackBar(
      'Safe sample loaded',
      Icons.check_circle,
      Colors.green,
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About File Scanner'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${AppConstants.appVersion}'),
              const SizedBox(height: 12),
              const Text(
                'Dangerous file detector using ILMU AI',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
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
                      '• ILMU-text-free-safe - File risk analysis',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Supported File Types:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...['APK (Android App)', 'PDF (Document)', 'DOC/DOCX (Word)', 
                   'XLS/XLSX (Excel)', 'IMG (Image)'].map(
                (type) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.description, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(type),
                    ],
                  ),
                ),
              ),
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
                          'Warning',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool is for assistance only. Always be cautious with files from unknown sources.',
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