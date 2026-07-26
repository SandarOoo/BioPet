const express = require("express");
const router = express.Router();

const { testGemini } = require("../services/geminiService");

router.get("/test", async (req, res) => {
  try {
    const result = await testGemini();

    console.log("✅ GEMINI RESULT:", result);

    res.json({
      success: true,
      message: "Gemini connected successfully",
      result,
    });
  } catch (error) {
    console.error("❌ GEMINI FULL ERROR:", error);

    res.status(500).json({
      success: false,
      message: "Gemini test failed",
      error: error.message,
      name: error.name,
      status: error.status,
    });
  }
});

module.exports = router;