import 'dart:io';
import 'dart:async';
import '../models/file_analysis.dart';

class FileMonitorService {
  static const List<String> _downloadPaths = [
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/sdcard/Download',
    '/sdcard/Downloads',
  ];

  static const List<String> _suspiciousExtensions = [
    'exe', 'scr', 'dll', 'js', 'vbs', 'bat', 'cmd', 'ps1',
    'apk', 'zip', 'rar', '7z', 'tar', 'gz',
    'iso', 'img', 'dmg',
    'msi', 'deb', 'rpm', 'pkg'
  ];

  DateTime? _lastScanTime;
  List<String> _lastScannedFiles = [];
  final StreamController<MonitoredFile> _fileDetectedController = 
      StreamController<MonitoredFile>.broadcast();

  Stream<MonitoredFile> get fileDetectedStream => _fileDetectedController.stream;

  /// Simulate monitoring download folders for new files
  Future<List<MonitoredFile>> scanDownloadFolders() async {
    final List<MonitoredFile> newFiles = [];
    final currentTime = DateTime.now();

    for (final path in _downloadPaths) {
      try {
        final directory = Directory(path);
        if (await directory.exists()) {
          final files = await directory.list().toList();
          
          for (final file in files) {
            if (file is File) {
              final fileName = file.path.split('/').last;
              final extension = fileName.split('.').last.toLowerCase();
              
              // Check if file has suspicious extension
              if (_suspiciousExtensions.contains(extension)) {
                final stat = await file.stat();
                final modifiedTime = stat.modified;
                
                // Check if file is new (modified after last scan)
                if (_lastScanTime == null || 
                    modifiedTime.isAfter(_lastScanTime!)) {
                  
                  final monitoredFile = MonitoredFile(
                    name: fileName,
                    path: file.path,
                    size: stat.size,
                    modifiedTime: modifiedTime,
                    extension: extension,
                    isSuspicious: true,
                  );
                  
                  newFiles.add(monitoredFile);
                }
              }
            }
          }
        }
      } catch (e) {
        // Continue to next path if current one is not accessible
        continue;
      }
    }

    _lastScanTime = currentTime;
    return newFiles;
  }

  /// Simulate detection of a new downloaded file (for demo purposes)
  void simulateNewFileDetection() {
    final demoFiles = [
      {
        'name': 'Banking_Security_Update.apk',
        'extension': 'apk',
        'size': 1024 * 1024 * 5, // 5MB
      },
      {
        'name': 'System_Cleaner_Pro.exe',
        'extension': 'exe',
        'size': 1024 * 1024 * 2, // 2MB
      },
      {
        'name': 'Important_Document.zip',
        'extension': 'zip',
        'size': 1024 * 1024 * 10, // 10MB
      },
      {
        'name': 'Invoice_2024.js',
        'extension': 'js',
        'size': 1024 * 50, // 50KB
      },
    ];

    // Pick a random demo file
    final randomFile = demoFiles[(DateTime.now().millisecondsSinceEpoch) % demoFiles.length];
    
    final monitoredFile = MonitoredFile(
      name: randomFile['name'] as String,
      path: '/storage/emulated/0/Download/${randomFile['name']}',
      size: randomFile['size'] as int,
      modifiedTime: DateTime.now(),
      extension: randomFile['extension'] as String,
      isSuspicious: true,
    );

    // Emit the detected file
    _fileDetectedController.add(monitoredFile);
  }

  /// Get the most recently modified file from download folders
  Future<MonitoredFile?> getLatestDownloadedFile() async {
    MonitoredFile? latestFile;

    for (final path in _downloadPaths) {
      try {
        final directory = Directory(path);
        if (await directory.exists()) {
          final files = await directory.list().toList();
          
          for (final file in files) {
            if (file is File) {
              final fileName = file.path.split('/').last;
              final extension = fileName.split('.').last.toLowerCase();
              
              if (_suspiciousExtensions.contains(extension)) {
                final stat = await file.stat();
                final modifiedTime = stat.modified;
                
                final monitoredFile = MonitoredFile(
                  name: fileName,
                  path: file.path,
                  size: stat.size,
                  modifiedTime: modifiedTime,
                  extension: extension,
                  isSuspicious: true,
                );

                if (latestFile == null || 
                    modifiedTime.isAfter(latestFile.modifiedTime)) {
                  latestFile = monitoredFile;
                }
              }
            }
          }
        }
      } catch (e) {
        // Continue to next path if current one is not accessible
        continue;
      }
    }

    return latestFile;
  }

  /// Check for new files (for background service)
  Future<List<MonitoredFile>> checkForNewFiles() async {
    final newFiles = await scanDownloadFolders();
    
    // Emit detected files to stream
    for (final file in newFiles) {
      _fileDetectedController.add(file);
    }
    
    return newFiles;
  }

  void dispose() {
    _fileDetectedController.close();
  }
}

class MonitoredFile {
  final String name;
  final String path;
  final int size;
  final DateTime modifiedTime;
  final String extension;
  final bool isSuspicious;

  MonitoredFile({
    required this.name,
    required this.path,
    required this.size,
    required this.modifiedTime,
    required this.extension,
    required this.isSuspicious,
  });

  /// Get file size in human readable format
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file type display name
  String get fileTypeDisplayName {
    switch (extension) {
      case 'apk':
        return 'Android App';
      case 'exe':
        return 'Windows Executable';
      case 'scr':
        return 'Screensaver';
      case 'dll':
        return 'Dynamic Library';
      case 'js':
        return 'JavaScript';
      case 'vbs':
        return 'VBScript';
      case 'bat':
        return 'Batch File';
      case 'cmd':
        return 'Command Script';
      case 'ps1':
        return 'PowerShell Script';
      case 'zip':
        return 'ZIP Archive';
      case 'rar':
        return 'RAR Archive';
      case '7z':
        return '7-Zip Archive';
      case 'tar':
        return 'TAR Archive';
      case 'gz':
        return 'GZIP Archive';
      case 'iso':
        return 'Disk Image';
      case 'img':
        return 'Image File';
      case 'dmg':
        return 'macOS Disk Image';
      case 'msi':
        return 'Windows Installer';
      case 'deb':
        return 'Debian Package';
      case 'rpm':
        return 'RPM Package';
      case 'pkg':
        return 'macOS Package';
      default:
        return '${extension.toUpperCase()} File';
    }
  }
}