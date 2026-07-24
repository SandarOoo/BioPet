const express = require("express");
const router = express.Router();
const {createPost} = require("../controllers/postController");

router.post("create", createPost);

const { testGemini } = require("../../lib/services/geminiService");

router.get("/hello", async (req, res) => {
  try {
    const result = await testGemini();

    res.json({
      success: true,
      message: result,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "AI test failed",
      error: err.message,
    });
  }
});

module.exports = router;