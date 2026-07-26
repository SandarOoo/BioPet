const express = require("express");

const {
  testGemini,
} = require("../services/geminiService");

const router =
  express.Router();

// =====================================================
// GET /api/gemini/test
// =====================================================

router.get(
  "/test",
  async (req, res) => {

    try {

      console.log(
        "================================="
      );

      console.log(
        "🤖 TESTING GEMINI API"
      );

      console.log(
        "================================="
      );

      const result =
        await testGemini();

      console.log(
        "🤖 GEMINI TEST RESULT:",
        result
      );

      return res.status(200).json({
        success: true,
        message:
          "Gemini API is working",
        ai: result,
      });

    } catch (error) {

      console.error(
        "❌ GEMINI TEST ERROR:",
        error
      );

      return res.status(500).json({
        success: false,
        message:
          "Gemini test failed",
        error:
          error.message,
        name:
          error.name,
      });
    }
  }
);

module.exports =
  router;