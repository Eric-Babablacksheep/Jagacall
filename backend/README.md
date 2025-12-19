# JagaCall Backend Service Architecture

## Overview

The JagaCall backend service acts as a secure intermediary between the Flutter mobile app and the ILMU AI APIs. It handles API key management, request forwarding, and response processing.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │───▶│  Backend Service │───▶│   ILMU APIs     │
│   (Client)      │    │   (Node.js/Python)   │    │  (YTL AI Labs) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Database       │
                       │ (PostgreSQL/MongoDB) │
                       └──────────────────┘
```

## Key Responsibilities

### 1. API Security

- **API Key Management**: Store ILMU API keys as environment variables (`ILMU_API_KEY`)
- **Request Validation**: Validate and sanitize all incoming requests from Flutter app
- **Rate Limiting**: Implement rate limiting to prevent abuse
- **Authentication**: Optional JWT-based authentication for enhanced security

### 2. Request Forwarding

- **Call Detection**: Forward call transcripts to ILMU-text API
- **File Analysis**: Forward file content to ILMU-text-free-safe API
- **Voice Analysis**: Forward voice transcripts to ILMU-text API (after speech-to-text processing)
- **Speech-to-Text**: Forward audio data to ILMU-asr API (future enhancement)

### 3. Response Processing

- **Data Transformation**: Transform ILMU API responses to Flutter-friendly format
- **Error Handling**: Standardize error responses and logging
- **Caching**: Implement caching for frequently requested analyses
- **Audit Logging**: Log all requests for monitoring and compliance

## API Endpoints

### 1. Call Detection Endpoint

```
POST /api/call-detect
Content-Type: application/json

Request Body:
{
  "transcript": "Call transcript text here",
  "language": "en|ms|mixed",
  "metadata": {
    "callerNumber": "+60123456789",
    "timestamp": "2025-12-18T10:30:00Z"
  }
}

Response:
{
  "success": true,
  "data": {
    "riskLevel": "safe|suspicious|highRisk|scam",
    "scamType": "impersonation|urgency|financialRequest|threat|other|none",
    "confidenceScore": 85.5,
    "redFlags": ["Authority impersonation", "Urgency language"],
    "recommendedAction": "End the call and verify through official channels",
    "analysisModel": "ILMU-text",
    "timestamp": "2025-12-18T10:30:05Z"
  }
}
```

### 2. File Analysis Endpoint

```
POST /api/file-analyze
Content-Type: multipart/form-data

Request Body:
- file: [binary file data]
- fileName: "app.apk"
- fileType: "apk|pdf|doc|exe"

Response:
{
  "success": true,
  "data": {
    "riskLevel": "safe|suspicious|highRisk|malicious",
    "threatType": "malware|phishing|suspicious|none",
    "confidenceScore": 92.3,
    "indicators": ["Suspicious permissions", "Unknown signer"],
    "recommendedAction": "Delete file and scan device with antivirus",
    "analysisModel": "ILMU-text-free-safe",
    "timestamp": "2025-12-18T10:30:05Z"
  }
}
```

### 3. Voice Analysis Endpoint

```
POST /api/voice-analyze
Content-Type: application/json

Request Body:
{
  "transcript": "Voice transcript text here",
  "audioDuration": 45.2,
  "language": "en|ms|mixed",
  "metadata": {
    "callerNumber": "+60123456789",
    "timestamp": "2025-12-18T10:30:00Z"
  }
}

Response:
{
  "success": true,
  "data": {
    "riskLevel": "safe|suspicious|highRisk|scam",
    "scamType": "impersonation|urgency|emotionalManipulation|financialRequest|threat|other|none",
    "confidenceScore": 78.9,
    "linguisticRedFlags": ["Authority impersonation", "Urgency language"],
    "behavioralRedFlags": ["Creating false emergency", "Requesting sensitive information"],
    "recommendedAction": "END THE CALL IMMEDIATELY. Do not provide any information.",
    "analysisModel": "ILMU-asr + ILMU-text",
    "timestamp": "2025-12-18T10:30:05Z"
  }
}
```

### 4. Speech-to-Text Endpoint (Future)

```
POST /api/speech-to-text
Content-Type: multipart/form-data

Request Body:
- audio: [binary audio data]
- audioFormat: "wav|mp3|m4a"
- language: "en|ms|auto"

Response:
{
  "success": true,
  "data": {
    "transcript": "Converted speech to text here",
    "confidence": 0.95,
    "language": "ms",
    "duration": 45.2,
    "model": "ILMU-asr"
  }
}
```

## Environment Variables

```bash
# ILMU API Configuration
ILMU_API_KEY=sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc
ILMU_BASE_URL=https://api.ytlailabs.tech/v1

# Server Configuration
PORT=3000
NODE_ENV=production

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/jagacall

# Security
JWT_SECRET=your-jwt-secret-here
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# File Upload
MAX_FILE_SIZE=10485760  # 10MB
UPLOAD_PATH=./uploads
```

## Technology Stack Recommendations

### Option 1: Node.js + Express

```javascript
// server.js
const express = require("express");
const multer = require("multer");
const rateLimit = require("express-rate-limit");
const helmet = require("helmet");
const cors = require("cors");

const app = express();

// Security middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// File upload configuration
const upload = multer({
  dest: "uploads/",
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
});

// Routes
app.post("/api/call-detect", callDetectionController);
app.post("/api/file-analyze", upload.single("file"), fileAnalysisController);
app.post("/api/voice-analyze", voiceAnalysisController);

app.listen(process.env.PORT, () => {
  console.log(`JagaCall backend running on port ${process.env.PORT}`);
});
```

### Option 2: Python + FastAPI

```python
# main.py
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
import uvicorn

app = FastAPI(title="JagaCall Backend API")

# Security middleware
app.add_middleware(HTTPSRedirectMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate limiting
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(429, _rate_limit_exceeded_handler)

@app.post("/api/call-detect")
@limiter.limit("100/15minutes")
async def call_detect(request: Request, data: CallDetectionRequest):
    # Implementation here
    pass

@app.post("/api/file-analyze")
@limiter.limit("50/15minutes")
async def file_analyze(request: Request, file: UploadFile = File(...)):
    # Implementation here
    pass

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=3000)
```

## Database Schema (Optional)

### Analysis History Table

```sql
CREATE TABLE analysis_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_type VARCHAR(50) NOT NULL, -- 'call', 'file', 'voice'
    input_data JSONB NOT NULL,
    result_data JSONB NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    confidence_score DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(255), -- Optional user identification
    ip_address INET
);

CREATE INDEX idx_analysis_history_type ON analysis_history(analysis_type);
CREATE INDEX idx_analysis_history_created ON analysis_history(created_at);
CREATE INDEX idx_analysis_history_risk ON analysis_history(risk_level);
```

## Deployment Considerations

### 1. Security

- Use HTTPS/TLS for all communications
- Implement proper input validation and sanitization
- Regular security updates and dependency scanning
- API key rotation policies

### 2. Scalability

- Load balancing for high availability
- Horizontal scaling with container orchestration (Docker/Kubernetes)
- Database connection pooling
- CDN for static assets

### 3. Monitoring

- Application performance monitoring (APM)
- Error tracking and alerting
- API usage analytics
- Health check endpoints

### 4. Compliance

- Data privacy compliance (PDPA for Malaysia)
- Audit logging for all API calls
- Data retention policies
- Secure data disposal

## Integration with Flutter

The Flutter app should make HTTP requests to the backend endpoints instead of directly calling ILMU APIs. The backend service will:

1. Receive requests from Flutter app
2. Validate and process the requests
3. Forward to appropriate ILMU API with secure API key
4. Process and transform responses
5. Return standardized responses to Flutter app

This architecture ensures:

- **Security**: API keys never exposed to client
- **Control**: Centralized control over API usage
- **Monitoring**: Ability to monitor and log all API calls
- **Flexibility**: Easy to add new features or change AI providers
- **Performance**: Caching and optimization at backend level
