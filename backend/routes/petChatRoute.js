const express = require("express");
const { sendPetMessage } = require("../controllers/petChatController");

const router = express.Router();

router.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "BioPet local knowledge chat is ready",
  });
});

// POST /api/pet-chat
router.post("/", sendPetMessage);

module.exports = router;
