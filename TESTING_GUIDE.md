# JagaCall Testing Guide

## 🧪 How to Test JagaCall Functionality

This guide provides comprehensive instructions for testing all features of the JagaCall scam detection app.

## 📋 Prerequisites

### 1. Flutter Development Environment

```bash
# Ensure Flutter is installed
flutter --version

# Check connected devices
flutter devices

# Get dependencies
flutter pub get
```

### 2. Backend Service (Optional for Live Mode)

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Start backend server
npm start
```

## 🚀 Quick Start Testing

### 1. Run the App in Demo Mode (Recommended for Initial Testing)

```bash
# From the jagacall root directory
flutter run
```

**Why Demo Mode First?**

- ✅ No backend server required
- ✅ No API keys needed
- ✅ Instant responses for testing
- ✅ Safe for development without costs

### 2. Navigate Through the App

The app has 4 main tabs:

1. **Calls** - Test call transcript analysis
2. **Files** - Test file security scanning
3. **Voice** - Test voice scam detection
4. **Settings** - Configure demo mode and view app info

## 🔍 Feature-by-Feature Testing

### 1. Call Detection Testing

#### **Test Case 1: Using Sample Transcripts**

1. Go to **Calls** tab
2. Scroll down to "Sample Call Scams" section
3. Tap on any sample transcript (e.g., "Bank Negara Malaysia scam")
4. Observe the auto-filled transcript
5. Tap **"Analyze Call"**
6. **Expected Result**: Risk assessment with confidence score and red flags

#### **Test Case 2: Custom Transcript Input**

1. In the **Calls** tab, type a custom transcript:
   ```
   "Hello, this is John from Microsoft. Your computer has a virus. Please provide your credit card details to fix it."
   ```
2. Tap **"Analyze Call"**
3. **Expected Result**: High risk detection with "impersonation" scam type

#### **Test Case 3: Legitimate Call**

1. Type a legitimate transcript:
   ```
   "Hello, this is your bank calling to confirm a recent transaction of RM50 at Tesco. Was this you?"
   ```
2. Tap **"Analyze Call"**
3. **Expected Result**: "Safe" or "Suspicious" (not "Scam")

### 2. File Analysis Testing

#### **Test Case 1: Sample File Selection**

1. Go to **Files** tab
2. Scroll to "Sample File Scams" section
3. Tap on any sample (e.g., "Malicious APK")
4. Observe the auto-filled file information
5. Tap **"Analyze File"**
6. **Expected Result**: Risk assessment with threat indicators

#### **Test Case 2: File Upload (Demo Mode)**

1. Tap **"Choose File"** button
2. Select any file from your device (PDF, DOC, APK, etc.)
3. Tap **"Analyze File"**
4. **Expected Result**: Analysis based on file metadata and type

#### **Test Case 3: Different File Types**

Test various file types:

- **APK files**: Should trigger security analysis
- **PDF files**: Should check for malicious content
- **DOC files**: Should scan for phishing links
- **Unknown files**: Should show "suspicious" by default

### 3. Voice Detection Testing

#### **Test Case 1: Sample Voice Scams**

1. Go to **Voice** tab
2. Scroll to "Sample Voice Scams" section
3. Tap on any sample (e.g., "Family Emergency Scam")
4. Observe the auto-filled transcript
5. Tap **"Analyze Transcript"**
6. **Expected Result**: Voice-specific risk assessment with behavioral red flags

#### **Test Case 2: Simulated Recording**

1. Tap the **"Record"** button
2. A recording dialog will appear
3. Wait 3 seconds for simulated recording
4. **Expected Result**: Auto-filled mock transcript
5. Tap **"Analyze Transcript"** to see results

#### **Test Case 3: Custom Voice Input**

1. Type a voice transcript:
   ```
   "Mak, I kemalangan! Saya di hospital dan perlu duit segera untuk pembedahan. Sila transfer RM10,000 sekarang."
   ```
2. Tap **"Analyze Transcript"**
3. **Expected Result**: High risk with "emotional manipulation" detection

### 4. Demo Mode Testing

#### **Test Case 1: Toggle Demo Mode**

1. Go to **Settings** tab
2. Find the "Demo Mode" toggle
3. Toggle it **OFF** (Live Mode)
4. **Expected Result**: Warning message about API calls
5. Toggle it **ON** (Demo Mode)
6. **Expected Result**: Confirmation message about simulated responses

#### **Test Case 2: Live Mode Behavior (Without Backend)**

1. Set Demo Mode to **OFF**
2. Try to analyze any content
3. **Expected Result**: Error message about backend connection
4. This confirms the app is trying to reach the backend

## 🧪 Advanced Testing Scenarios

### 1. Edge Cases Testing

#### **Empty Input Testing**

1. Submit empty transcript in any analysis screen
2. **Expected Result**: Validation error message

#### **Very Long Input Testing**

1. Paste a very long transcript (1000+ words)
2. **Expected Result**: App should handle it gracefully or show size limit error

#### **Special Characters Testing**

1. Test with special characters: `!@#$%^&*()_+-=[]{}|;':",./<>?`
2. Test with emojis: 😊🎉💰🏦📞
3. **Expected Result**: App should not crash and process correctly

### 2. Performance Testing

#### **Response Time Testing**

1. Time how long each analysis takes in Demo Mode
2. **Expected Result**: Should be under 3 seconds for Demo Mode
3. In Live Mode (with backend), should be under 10 seconds

#### **Memory Testing**

1. Use the app for 10-15 minutes continuously
2. Switch between all tabs
3. Perform multiple analyses
4. **Expected Result**: App should remain responsive

### 3. UI/UX Testing

#### **Navigation Testing**

1. Test all navigation flows between tabs
2. Test back navigation if applicable
3. **Expected Result**: Smooth transitions without crashes

#### **Orientation Testing**

1. Rotate device between portrait and landscape
2. **Expected Result**: UI should adapt properly

#### **Accessibility Testing**

1. Test with larger font sizes in device settings
2. **Expected Result**: Text should remain readable

## 🔧 Backend Testing (Optional)

If you set up the backend service:

### 1. Health Check

```bash
curl http://localhost:3000/api/health
```

**Expected Result**: JSON response with status "healthy"

### 2. API Endpoint Testing

```bash
# Test call detection
curl -X POST http://localhost:3000/api/call-detect \
  -H "Content-Type: application/json" \
  -d '{"transcript": "This is a test scam call"}'
```

### 3. File Upload Testing

```bash
# Test file analysis
curl -X POST http://localhost:3000/api/file-analyze \
  -F "file=@test.pdf" \
  -F "fileName=test.pdf"
```

## 📊 Test Results Checklist

### Call Detection Tests

- [ ] Sample scam transcripts detected as "Scam" or "High Risk"
- [ ] Legitimate calls marked as "Safe" or "Suspicious"
- [ ] Empty input validation works
- [ ] Custom transcripts analyzed correctly
- [ ] Risk confidence scores displayed (0-100%)
- [ ] Red flags and recommendations shown

### File Analysis Tests

- [ ] File upload works for supported types
- [ ] Sample file scams detected correctly
- [ ] File size limits enforced
- [ ] Metadata analysis works
- [ ] Threat indicators displayed

### Voice Detection Tests

- [ ] Sample voice scams detected with behavioral analysis
- [ ] Simulated recording generates transcripts
- [ ] Linguistic and behavioral red flags identified
- [ ] Emotional manipulation detection works

### Demo Mode Tests

- [ ] Toggle switches between Demo/Live modes
- [ ] Demo mode shows simulated responses
- [ ] Live mode shows connection errors (without backend)
- [ ] Settings persistence works

### General UI Tests

- [ ] All tabs navigate correctly
- [ ] No crashes during normal usage
- [ ] Loading states show during analysis
- [ ] Error messages display appropriately
- [ ] App theme and styling consistent

## 🐛 Common Issues & Troubleshooting

### Issue 1: App Won't Start

**Solution**: Run `flutter clean` then `flutter pub get`

### Issue 2: Analysis Always Returns Error

**Solution**: Ensure Demo Mode is ON for initial testing

### Issue 3: Backend Connection Errors

**Solution**:

1. Ensure backend server is running on port 3000
2. Check network connectivity
3. Verify environment variables in backend

### Issue 4: File Upload Fails

**Solution**:

1. Check file size is under 10MB
2. Ensure file type is supported
3. Check permissions in Android manifest

## 📝 Testing Report Template

Use this template to document your test results:

```
Test Date: ___________
Tester Name: ___________
Device: ___________
App Version: 1.0.0

Call Detection Tests:
□ Sample Scam Detection: PASS/FAIL - Notes: _____
□ Legitimate Call Detection: PASS/FAIL - Notes: _____
□ Custom Input: PASS/FAIL - Notes: _____

File Analysis Tests:
□ Sample File Detection: PASS/FAIL - Notes: _____
□ File Upload: PASS/FAIL - Notes: _____
□ Different File Types: PASS/FAIL - Notes: _____

Voice Detection Tests:
□ Sample Voice Scams: PASS/FAIL - Notes: _____
□ Simulated Recording: PASS/FAIL - Notes: _____
□ Custom Voice Input: PASS/FAIL - Notes: _____

Demo Mode Tests:
□ Toggle Functionality: PASS/FAIL - Notes: _____
□ Demo Responses: PASS/FAIL - Notes: _____

Overall Issues Found:
1. ___________
2. ___________
3. ___________

Recommendations:
1. ___________
2. ___________
```

## 🎯 Success Criteria

The app is considered successfully tested if:

- ✅ All sample scams are detected as high risk
- ✅ Legitimate content is not flagged as scams
- ✅ Demo mode works without backend
- ✅ UI is responsive and user-friendly
- ✅ No crashes during normal usage
- ✅ Error handling works appropriately

Happy testing! 🧪
