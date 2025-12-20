import 'dart:async';
import 'package:flutter/material.dart';
import '../models/file_analysis.dart';
import '../services/file_analysis_service.dart';
import '../services/file_monitor_service.dart';
import '../services/notification_service.dart';
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
  final FileMonitorService _monitorService = FileMonitorService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _fileNameController = TextEditingController();
  FileAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;
  String? _selectedFilePath; // Added to store file path
  bool _isAutoScanning = false;
  String _autoScanMessage = '';
  StreamSubscription<MonitoredFile>? _fileDetectionSubscription;
  
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
    
    // Listen for new file detections
    _fileDetectionSubscription = _monitorService.fileDetectedStream.listen(
      _handleNewFileDetection,
    );
    
    // Auto-trigger scan when app gains focus (demo simulation)
    WidgetsBinding.instance.addObserver(_LifecycleObserver(this));
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _pulseController.dispose();
    _fileDetectionSubscription?.cancel();
    _monitorService.dispose();
    WidgetsBinding.instance.removeObserver(_LifecycleObserver(this));
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
        filePath: _selectedFilePath, // Pass file path
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
        title: const Text('Malware & File Scanner'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About File Scanner',
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 24),
            _buildAutoScanSection(colorScheme),
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
                      Icons.security,
                      size: 64,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Malware & File Scanner',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Powered by ILMU AI • Advanced malware detection for executable files',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DEMO MODE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

  Widget _buildAutoScanSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
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
                    Icons.autorenew,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Automatic Download Scan (Demo)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Automatically monitors your Downloads folder for suspicious files and scans them for threats.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isAutoScanning ? null : _scanLatestDownloadedFile,
                      icon: _isAutoScanning
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.folder_open),
                      label: Text(_isAutoScanning ? 'Scanning...' : 'Scan Latest Download'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _simulateNewDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('Simulate Download'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (_autoScanMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isAutoScanning
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAutoScanning
                          ? colorScheme.primary.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAutoScanning ? Icons.scanner : Icons.check_circle,
                        size: 16,
                        color: _isAutoScanning
                            ? colorScheme.primary
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _autoScanMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isAutoScanning
                                ? colorScheme.primary
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 1,
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
                      'Test Malware',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Dangerous file',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
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
            elevation: 1,
            child: InkWell(
              onTap: _loadSampleSafe,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test Safe File',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Clean document',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
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
              onFilePathChanged: (filePath) => setState(() => _selectedFilePath = filePath),
              onSampleSelected: (sample) {
                _fileNameController.text = sample['fileName'] as String;
                setState(() {
                  _selectedFilePath = null; // Clear file path for sample files
                  final fileTypeString = sample['fileType'] as String;
                  _selectedFileType = FileType.values.firstWhere(
                    (e) => e.name == fileTypeString,
                    orElse: () => FileType.other,
                  );
                  final sourceAppString = sample['sourceApp'] as String;
                  _selectedSourceApp = SourceApp.values.firstWhere(
                    (e) => e.name == sourceAppString,
                    orElse: () => SourceApp.other,
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
      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze File'),
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
        FileAnalysisWidget(
          analysis: _lastAnalysis!,
          onFileDeleted: _handleFileDeleted,
        ),
      ],
    );
  }

  Widget _buildSafetyTips(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      color: colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gpp_good,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Malware Protection Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTip('Never run .exe, .scr, or .dll files from unknown sources', colorScheme),
            _buildTip('Scan all email attachments before opening', colorScheme),
            _buildTip('Be suspicious of files with double extensions (e.g., file.pdf.exe)', colorScheme),
            _buildTip('Keep your antivirus software updated', colorScheme),
            _buildTip('Use virtualization for testing suspicious files', colorScheme),
            _buildTip('Enable file extension visibility in your system', colorScheme),
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
        orElse: () => FileType.other,
      );
      _selectedSourceApp = SourceApp.values.firstWhere(
        (e) => e.name == maliciousSample['sourceApp'],
        orElse: () => SourceApp.other,
      );
      _selectedPermissions = List<String>.from(maliciousSample['permissions'] as List);
    });
    
    _showCustomSnackBar(
      'Scam sample loaded',
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
        orElse: () => FileType.other,
      );
      _selectedSourceApp = SourceApp.values.firstWhere(
        (e) => e.name == safeSample['sourceApp'],
        orElse: () => SourceApp.other,
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
                'APK & File Scam Detection System',
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
                      '• ILMU-text-free-safe - File scam detection\n'
                      '• Heuristic analysis - Pattern recognition',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
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
                          'Disclaimer',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This is a demo system for educational purposes.\n'
                      'Always verify files through official channels.\n'
                      'Use updated antivirus software for real protection.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
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

  void _handleFileDeleted() {
    setState(() {
      _lastAnalysis = null;
      _selectedFilePath = null;
      _fileNameController.clear();
    });
    
    _showCustomSnackBar(
      'File deleted successfully!',
      Icons.delete,
      Colors.green,
    );
  }

  void _handleNewFileDetection(MonitoredFile monitoredFile) {
    setState(() {
      _autoScanMessage = 'New file detected: ${monitoredFile.name}. Scanning for threats...';
      _isAutoScanning = true;
    });

    // Show notification for new file detection
    _notificationService.showFileDetectionNotification(monitoredFile);

    // Automatically analyze the detected file
    _analyzeMonitoredFile(monitoredFile);
  }

  Future<void> _scanLatestDownloadedFile() async {
    setState(() {
      _isAutoScanning = true;
      _autoScanMessage = 'Scanning Downloads folder for latest file...';
    });

    try {
      final latestFile = await _monitorService.getLatestDownloadedFile();
      
      if (latestFile != null) {
        setState(() {
          _autoScanMessage = 'Found: ${latestFile.name} (${latestFile.formattedSize})';
        });
        
        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));
        
        await _analyzeMonitoredFile(latestFile);
      } else {
        setState(() {
          _autoScanMessage = 'No suspicious files found in Downloads folder';
          _isAutoScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _autoScanMessage = 'Error scanning Downloads folder: $e';
        _isAutoScanning = false;
      });
    }
  }

  void _simulateNewDownload() {
    _monitorService.simulateNewFileDetection();
  }

  Future<void> _analyzeMonitoredFile(MonitoredFile monitoredFile) async {
    try {
      // Show progress notification
      await _notificationService.showScanProgressNotification(monitoredFile.name, 25);

      // Determine file type from extension
      FileType fileType = FileType.other;
      for (final type in FileType.values) {
        if (type.name == monitoredFile.extension) {
          fileType = type;
          break;
        }
      }

      // Update progress
      await _notificationService.showScanProgressNotification(monitoredFile.name, 50);

      // Determine source app (simulate based on file type)
      SourceApp sourceApp = SourceApp.browser;
      if (fileType == FileType.apk) {
        sourceApp = SourceApp.whatsapp; // APKs often shared via messaging
      }

      // Update progress
      await _notificationService.showScanProgressNotification(monitoredFile.name, 75);

      final analysis = await _analysisService.analyzeFile(
        fileName: monitoredFile.name,
        filePath: monitoredFile.path,
        fileType: fileType,
        sourceApp: sourceApp,
        permissions: fileType == FileType.apk ? ['camera', 'storage'] : [],
      );

      // Cancel progress notification
      await _notificationService.cancelProgressNotification();

      // Show completion notification
      await _notificationService.showScanCompleteNotification(analysis);

      setState(() {
        _lastAnalysis = analysis;
        _fileNameController.text = monitoredFile.name;
        _selectedFilePath = monitoredFile.path;
        _selectedFileType = fileType;
        _selectedSourceApp = sourceApp;
        _autoScanMessage = 'Analysis complete! Risk level: ${analysis.riskLevel.displayName}';
        _isAutoScanning = false;
      });

      _showCustomSnackBar(
        'Automatic scan complete: ${analysis.riskLevel.displayName} risk',
        analysis.riskLevel == FileRiskLevel.high ? Icons.warning : Icons.check_circle,
        analysis.riskLevel == FileRiskLevel.high ? Colors.orange : Colors.green,
      );
    } catch (e) {
      // Cancel progress notification on error
      await _notificationService.cancelProgressNotification();
      
      setState(() {
        _autoScanMessage = 'Error analyzing file: $e';
        _isAutoScanning = false;
      });
    }
  }
}

// Lifecycle observer to trigger scan when app regains focus
class _LifecycleObserver extends WidgetsBindingObserver {
  final _FileScanScreenState _screenState;
  
  _LifecycleObserver(this._screenState);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Simulate auto-scan when app regains focus
      Future.delayed(const Duration(seconds: 1), () {
        if (_screenState.mounted) {
          _screenState._scanLatestDownloadedFile();
        }
      });
    }
  }
}