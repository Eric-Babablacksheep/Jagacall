import 'package:flutter/material.dart';
import '../services/demo_mode_service.dart';

class DemoModeToggle extends StatefulWidget {
  const DemoModeToggle({Key? key}) : super(key: key);

  @override
  State<DemoModeToggle> createState() => _DemoModeToggleState();
}

class _DemoModeToggleState extends State<DemoModeToggle> {
  bool _isDemoMode = DemoModeService.isDemoMode;

  @override
  void initState() {
    super.initState();
    _updateDemoModeStatus();
  }

  void _updateDemoModeStatus() {
    setState(() {
      _isDemoMode = DemoModeService.isDemoMode;
    });
  }

  Future<void> _toggleDemoMode() async {
    await DemoModeService.toggleDemoMode();
    _updateDemoModeStatus();
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(DemoModeService.demoModeDescription),
        backgroundColor: _isDemoMode ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isDemoMode ? Icons.science : Icons.cloud,
                  color: _isDemoMode ? Colors.orange : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isDemoMode ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
                Switch(
                  value: _isDemoMode,
                  onChanged: (value) => _toggleDemoMode(),
                  activeColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DemoModeService.demoModeDescription,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isDemoMode ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isDemoMode ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: _isDemoMode ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isDemoMode 
                        ? 'Currently using simulated responses. No API calls are made.'
                        : 'Currently making real API calls to ILMU backend.',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isDemoMode ? Colors.orange.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}