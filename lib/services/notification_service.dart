import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:workmanager/workmanager.dart'; // Temporarily disabled
import '../models/file_analysis.dart';
import '../services/file_analysis_service.dart';
import '../services/file_monitor_service.dart';
import '../main.dart' as main_app;

/// Service for handling background file monitoring notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'file_monitoring_channel',
      'File Monitoring',
      description: 'Notifications for file monitoring and malware detection',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation to file analysis results using main app's navigation handler
    if (response.payload != null) {
      main_app.MainScreen.handleNotificationTap(response.payload);
      print('Notification tapped with payload: ${response.payload}');
    }
  }

  /// Show notification for new file detection
  Future<void> showFileDetectionNotification(MonitoredFile file) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'file_monitoring_channel',
      'File Monitoring',
      channelDescription: 'Notifications for file monitoring and malware detection',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2E7D32), // JagaCall green color
      ledColor: Color(0xFF2E7D32),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'JagaCall: New File Detected',
      'Scanning ${file.name} for threats...',
      notificationDetails,
      payload: file.path,
    );
  }

  /// Show notification for scan completion
  Future<void> showScanCompleteNotification(FileAnalysis analysis) async {
    if (!_isInitialized) await initialize();

    String title;
    String body;
    String? payload;

    if (analysis.riskLevel == FileRiskLevel.high) {
      title = '⚠️ JagaCall: Threat Detected!';
      body = '${analysis.fileName} may be malicious. Tap to view details.';
      payload = analysis.filePath;
    } else if (analysis.riskLevel == FileRiskLevel.medium) {
      title = '🔍 JagaCall: Suspicious File';
      body = '${analysis.fileName} requires attention. Tap to view analysis.';
      payload = analysis.filePath;
    } else {
      title = '✅ JagaCall: File Safe';
      body = '${analysis.fileName} appears to be safe.';
      payload = analysis.filePath;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'file_monitoring_channel',
      'File Monitoring',
      channelDescription: 'Notifications for file monitoring and malware detection',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2E7D32),
      ledColor: Color(0xFF2E7D32),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show notification for scan progress
  Future<void> showScanProgressNotification(String fileName, int progress) async {
    if (!_isInitialized) await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'file_monitoring_channel',
      'File Monitoring',
      channelDescription: 'Notifications for file monitoring and malware detection',
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
      playSound: false,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2E7D32),
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Fixed ID for progress notification
      'JagaCall: Scanning...',
      'Analyzing $fileName ($progress%)',
      notificationDetails,
    );
  }

  /// Cancel progress notification
  Future<void> cancelProgressNotification() async {
    await _notifications.cancel(999);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission = await androidImplementation?.requestNotificationsPermission();

    return grantedNotificationPermission ?? false;
  }
}

/// Helper function to map file extension to FileType enum
FileType _getFileTypeFromExtension(String extension) {
  switch (extension.toLowerCase()) {
    case 'exe':
      return FileType.exe;
    case 'scr':
      return FileType.scr;
    case 'dll':
      return FileType.dll;
    case 'js':
      return FileType.js;
    case 'vbs':
      return FileType.vbs;
    case 'zip':
      return FileType.zip;
    case 'rar':
      return FileType.rar;
    case 'apk':
      return FileType.apk;
    case 'iso':
      return FileType.iso;
    case 'img':
      return FileType.img;
    case 'pdf':
      return FileType.pdf;
    case 'doc':
    case 'docx':
      return FileType.doc;
    case 'xls':
    case 'xlsx':
      return FileType.xls;
    default:
      return FileType.other;
  }
}

/// Background task handler for file monitoring (temporarily disabled due to WorkManager compatibility issues)
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // Initialize notification service
//     final notificationService = NotificationService();
//     await notificationService.initialize();

//     // Initialize file monitor service
//     final fileMonitorService = FileMonitorService();
//     final fileAnalysisService = FileAnalysisService();

//     try {
//       // Check for new files in Downloads folder
//       final newFiles = await fileMonitorService.checkForNewFiles();
      
//       for (final file in newFiles) {
//         // Show detection notification
//         await notificationService.showFileDetectionNotification(file);
        
//         // Analyze the file
//         final fileType = _getFileTypeFromExtension(file.extension);
//         final analysis = await fileAnalysisService.analyzeFile(
//           fileName: file.name,
//           filePath: file.path,
//           fileType: fileType,
//           sourceApp: SourceApp.browser, // Default to browser for downloads
//           permissions: [], // No permissions info in background
//         );
        
//         // Show result notification
//         await notificationService.showScanCompleteNotification(analysis);
//       }
      
//       return Future.value(true);
//     } catch (e) {
//       print('Background task error: $e');
//       return Future.value(false);
//     }
//   });
// }