const { buildPetReply } = require("../services/petChatService");

function sendPetMessage(req, res, next) {
  try {
    const message = req.body?.message;

    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: "မေးခွန်းတစ်ခု ရေးပေးပါ။",
      });
    }

    const result = buildPetReply(message);

    return res.status(200).json({
      success: true,
      reply: result.reply,
      intent: result.intent,
      animal: result.animal,
      emergency: result.emergency,
      source: "biopet_local_knowledge",
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  sendPetMessage,
};
