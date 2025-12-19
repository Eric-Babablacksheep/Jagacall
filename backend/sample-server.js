/**
 * JagaCall Backend Service - Sample Implementation
 * This is a reference implementation for the backend service that
 * acts as a secure intermediary between Flutter app and ILMU APIs.
 */

const express = require("express");
const multer = require("multer");
const axios = require("axios");
const rateLimit = require("express-rate-limit");
const helmet = require("helmet");
const cors = require("cors");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

// ILMU API Configuration
const ILMU_API_KEY =
  process.env.ILMU_API_KEY ||
  "sk-svcacct-x-2_lwcUJ-jyEiheiduSDL2v5z_HCn6zJ5sK-6KTDHc";
const ILMU_BASE_URL =
  process.env.ILMU_BASE_URL || "https://api.ytlailabs.tech/v1";

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin: ["http://localhost:3000", "http://127.0.0.1:3000"], // Flutter app origins
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: "Too many requests from this IP, please try again later.",
    retryAfter: "15 minutes",
  },
});
app.use("/api/", limiter);

// Body parsing middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// File upload configuration
const upload = multer({
  dest: "uploads/",
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      "application/vnd.android.package-archive",
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/x-msdownload",
      "audio/wav",
      "audio/mpeg",
      "audio/mp4",
    ];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Invalid file type"), false);
    }
  },
});

// Ensure uploads directory exists
if (!fs.existsSync("uploads")) {
  fs.mkdirSync("uploads");
}

// Utility Functions
function createILMURequest(
  model,
  messages,
  maxTokens = 400,
  temperature = 0.2
) {
  return {
    model: model,
    api_key: ILMU_API_KEY,
    messages: messages,
    max_tokens: maxTokens,
    temperature: temperature,
  };
}

function standardizeResponse(success, data = null, error = null) {
  const response = {
    success: success,
    timestamp: new Date().toISOString(),
  };

  if (success && data) {
    response.data = data;
  }

  if (!success && error) {
    response.error = {
      message: error.message || "Unknown error occurred",
      code: error.code || "INTERNAL_ERROR",
    };
  }

  return response;
}

// Logging middleware
app.use((req, res, next) => {
  console.log(
    `[${new Date().toISOString()}] ${req.method} ${req.path} - IP: ${req.ip}`
  );
  next();
});

// API Routes

/**
 * Call Detection Endpoint
 * Analyzes call transcripts for scam indicators using ILMU-text
 */
app.post("/api/call-detect", async (req, res) => {
  try {
    const { transcript, language = "mixed", metadata = {} } = req.body;

    if (!transcript || transcript.trim().length === 0) {
      return res.status(400).json(
        standardizeResponse(false, null, {
          message: "Transcript is required",
          code: "INVALID_INPUT",
        })
      );
    }

    // Create ILMU API request
    const ilmuMessages = [
      {
        role: "system",
        content: `You are ILMU, an AI assistant from Malaysia specializing in call scam detection.

Analyze this call transcript for scam indicators focusing on Malaysian context:
- Authority impersonation (Bank Negara, PDRM, LHDN, JPJ, etc.)
- Urgency tactics (sekarang, segera, immediately)
- Financial requests (OTP, money transfer, payment)
- Threats (arrest, legal action, account suspension)

Provide risk assessment in JSON format:
{
  "risk_level": "safe|suspicious|highRisk|scam",
  "scam_type": "none|impersonation|urgency|financialRequest|threat|other",
  "confidence": 0-100,
  "red_flags": ["flag1", "flag2"],
  "recommended_action": "..."
}

Language: ${language}`,
      },
      {
        role: "user",
        content: `Call transcript analysis: "${transcript}"`,
      },
    ];

    const ilmuRequest = createILMURequest("ILMU-text", ilmuMessages);

    // Call ILMU API
    const ilmuResponse = await axios.post(
      `${ILMU_BASE_URL}/chat/completions`,
      ilmuRequest,
      {
        headers: {
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    // Parse ILMU response
    let analysisResult;
    try {
      const content = ilmuResponse.data.choices[0].message.content;
      analysisResult = JSON.parse(content);
    } catch (parseError) {
      // Fallback if JSON parsing fails
      analysisResult = {
        risk_level: "suspicious",
        scam_type: "other",
        confidence: 50,
        red_flags: ["Unable to parse AI response"],
        recommended_action: "Please review manually",
      };
    }

    const responseData = {
      riskLevel: analysisResult.risk_level || "suspicious",
      scamType: analysisResult.scam_type || "other",
      confidenceScore: analysisResult.confidence || 50,
      redFlags: analysisResult.red_flags || [],
      recommendedAction:
        analysisResult.recommended_action || "Please exercise caution",
      analysisModel: "ILMU-text",
      timestamp: new Date().toISOString(),
      metadata: metadata,
    };

    res.json(standardizeResponse(true, responseData));
  } catch (error) {
    console.error("Call detection error:", error.message);
    res.status(500).json(standardizeResponse(false, null, error));
  }
});

/**
 * File Analysis Endpoint
 * Analyzes files for malware and security threats using ILMU-text-free-safe
 */
app.post("/api/file-analyze", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json(
        standardizeResponse(false, null, {
          message: "File is required",
          code: "INVALID_INPUT",
        })
      );
    }

    const { fileName, fileType } = req.body;
    const filePath = req.file.path;

    // Read file content (for text-based files)
    let fileContent = "";
    try {
      if (
        req.file.mimetype.startsWith("text/") ||
        req.file.mimetype.includes("pdf")
      ) {
        fileContent = fs.readFileSync(filePath, "utf8");
      } else {
        // For binary files, we'll analyze metadata and file info
        fileContent = `File analysis: ${
          fileName || req.file.originalname
        }, Type: ${fileType || req.file.mimetype}, Size: ${
          req.file.size
        } bytes`;
      }
    } catch (readError) {
      fileContent = `Unable to read file content. File info: ${
        fileName || req.file.originalname
      }, Type: ${fileType || req.file.mimetype}`;
    }

    // Create ILMU API request for file analysis
    const ilmuMessages = [
      {
        role: "system",
        content: `You are ILMU, an AI assistant specializing in file security analysis.

Analyze this file for security threats and malicious indicators:
- Malware signatures and patterns
- Suspicious file metadata
- Phishing indicators in document content
- Security vulnerabilities

Provide analysis in JSON format:
{
  "risk_level": "safe|suspicious|highRisk|malicious",
  "threat_type": "none|malware|phishing|suspicious|vulnerability",
  "confidence": 0-100,
  "indicators": ["indicator1", "indicator2"],
  "recommended_action": "..."
}

File Type: ${fileType || req.file.mimetype}`,
      },
      {
        role: "user",
        content: `File security analysis: "${fileContent}"`,
      },
    ];

    const ilmuRequest = createILMURequest("ILMU-text-free-safe", ilmuMessages);

    // Call ILMU API
    const ilmuResponse = await axios.post(
      `${ILMU_BASE_URL}/chat/completions`,
      ilmuRequest,
      {
        headers: {
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    // Parse ILMU response
    let analysisResult;
    try {
      const content = ilmuResponse.data.choices[0].message.content;
      analysisResult = JSON.parse(content);
    } catch (parseError) {
      analysisResult = {
        risk_level: "suspicious",
        threat_type: "other",
        confidence: 50,
        indicators: ["Unable to parse AI response"],
        recommended_action: "Please scan with antivirus software",
      };
    }

    const responseData = {
      fileName: fileName || req.file.originalname,
      fileType: fileType || req.file.mimetype,
      fileSize: req.file.size,
      riskLevel: analysisResult.risk_level || "suspicious",
      threatType: analysisResult.threat_type || "other",
      confidenceScore: analysisResult.confidence || 50,
      indicators: analysisResult.indicators || [],
      recommendedAction:
        analysisResult.recommended_action || "Please exercise caution",
      analysisModel: "ILMU-text-free-safe",
      timestamp: new Date().toISOString(),
    };

    // Clean up uploaded file
    fs.unlinkSync(filePath);

    res.json(standardizeResponse(true, responseData));
  } catch (error) {
    console.error("File analysis error:", error.message);

    // Clean up uploaded file if it exists
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    res.status(500).json(standardizeResponse(false, null, error));
  }
});

/**
 * Voice Analysis Endpoint
 * Analyzes voice transcripts for scam indicators using ILMU-text
 */
app.post("/api/voice-analyze", async (req, res) => {
  try {
    const {
      transcript,
      audioDuration,
      language = "mixed",
      metadata = {},
    } = req.body;

    if (!transcript || transcript.trim().length === 0) {
      return res.status(400).json(
        standardizeResponse(false, null, {
          message: "Transcript is required",
          code: "INVALID_INPUT",
        })
      );
    }

    // Create ILMU API request for voice analysis
    const ilmuMessages = [
      {
        role: "system",
        content: `You are ILMU, an AI assistant from Malaysia specializing in voice scam detection.

Analyze this voice transcript for scam indicators focusing on:
- Authority impersonation (bank, police, government agencies)
- Urgency tactics
- Emotional manipulation
- Financial requests
- Threats

Provide analysis in JSON format:
{
  "risk_level": "safe|suspicious|highRisk|scam",
  "scam_type": "none|impersonation|urgency|emotionalManipulation|financialRequest|threat|other",
  "confidence": 0-100,
  "linguistic_red_flags": ["flag1", "flag2"],
  "behavioral_red_flags": ["pattern1", "pattern2"],
  "recommended_action": "..."
}

Consider Malaysian context and common scam patterns in the region.
Language: ${language}`,
      },
      {
        role: "user",
        content: `Voice transcript analysis: "${transcript}"`,
      },
    ];

    const ilmuRequest = createILMURequest("ILMU-text", ilmuMessages);

    // Call ILMU API
    const ilmuResponse = await axios.post(
      `${ILMU_BASE_URL}/chat/completions`,
      ilmuRequest,
      {
        headers: {
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    // Parse ILMU response
    let analysisResult;
    try {
      const content = ilmuResponse.data.choices[0].message.content;
      analysisResult = JSON.parse(content);
    } catch (parseError) {
      analysisResult = {
        risk_level: "suspicious",
        scam_type: "other",
        confidence: 50,
        linguistic_red_flags: ["Unable to parse AI response"],
        behavioral_red_flags: [],
        recommended_action: "Please exercise caution",
      };
    }

    const responseData = {
      riskLevel: analysisResult.risk_level || "suspicious",
      scamType: analysisResult.scam_type || "other",
      confidenceScore: analysisResult.confidence || 50,
      linguisticRedFlags: analysisResult.linguistic_red_flags || [],
      behavioralRedFlags: analysisResult.behavioral_red_flags || [],
      recommendedAction:
        analysisResult.recommended_action || "Please exercise caution",
      audioDuration: audioDuration,
      analysisModel: "ILMU-text",
      timestamp: new Date().toISOString(),
      metadata: metadata,
    };

    res.json(standardizeResponse(true, responseData));
  } catch (error) {
    console.error("Voice analysis error:", error.message);
    res.status(500).json(standardizeResponse(false, null, error));
  }
});

/**
 * Health Check Endpoint
 */
app.get("/api/health", (req, res) => {
  res.json(
    standardizeResponse(true, {
      status: "healthy",
      service: "JagaCall Backend",
      version: "1.0.0",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    })
  );
});

/**
 * Error Handling Middleware
 */
app.use((error, req, res, next) => {
  console.error("Unhandled error:", error);

  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json(
        standardizeResponse(false, null, {
          message: "File size too large. Maximum size is 10MB.",
          code: "FILE_TOO_LARGE",
        })
      );
    }
  }

  res.status(500).json(
    standardizeResponse(false, null, {
      message: "Internal server error",
      code: "INTERNAL_ERROR",
    })
  );
});

/**
 * 404 Handler
 */
app.use("*", (req, res) => {
  res.status(404).json(
    standardizeResponse(false, null, {
      message: "Endpoint not found",
      code: "NOT_FOUND",
    })
  );
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 JagaCall Backend Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔗 ILMU API: ${ILMU_BASE_URL}`);
  console.log(
    `🔒 Demo Mode: ${process.env.NODE_ENV === "development" ? "ON" : "OFF"}`
  );
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down gracefully");
  process.exit(0);
});

process.on("SIGINT", () => {
  console.log("SIGINT received, shutting down gracefully");
  process.exit(0);
});

module.exports = app;
