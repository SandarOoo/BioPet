const express = require("express");
const router = express.Router();

const {
  reviewPost,
} = require("../services/geminiService");

router.post("/test-gemini", async (req, res) => {
  try {
    const { text } = req.body;

    if (!text) {
      return res.status(400).json({
        message: "Text is required",
      });
    }

    const result = await reviewPost(text);

    res.json({
      success: true,
      ai: result,
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Gemini test failed",
    });
  }
});

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