const {
  GoogleGenerativeAI,
} = require("@google/generative-ai");

const genAI =
  new GoogleGenerativeAI(
    process.env.GEMINI_API_KEY
  );

// =====================================================
// ANALYZE POST
// =====================================================

const analyzePost = async (text) => {
  try {
    if (!text || text.trim().length === 0) {
      throw new Error(
        "Text is required"
      );
    }

    const model =
      genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
      });

    const prompt = `
Analyze this social media post for a pet community app.

Post:
"${text}"

Return ONLY valid JSON.
Do not use markdown.
Do not use \`\`\`json.

Format:
{
  "allowed": true,
  "petRelated": true,
  "reason": "short explanation"
}

Rules:
- allowed: false if content is harmful, abusive, sexual, violent, or inappropriate.
- petRelated: true if related to pets, animals, pet care, veterinary, grooming, pet products, or pet community.
- Informal language is allowed.
`;

    const result =
      await model.generateContent(
        prompt
      );

    const response =
      result.response.text();

    console.log(
      "GEMINI RAW RESPONSE:",
      response
    );

    const cleaned =
      response
        .replace(/```json/gi, "")
        .replace(/```/g, "")
        .trim();

    const parsed =
      JSON.parse(cleaned);

    return parsed;

  } catch (error) {

    console.error(
      "Gemini analyzePost error:",
      error
    );

    // IMPORTANT:
    // Do not hide Gemini errors during testing.
    throw error;
  }
};


// =====================================================
// TEST GEMINI
// =====================================================

const testGemini = async () => {

  const result =
    await analyzePost(
      "My dog is sick and needs veterinary care."
    );

  return result;
};


// =====================================================
// EXPORT
// =====================================================

module.exports = {
  analyzePost,
  testGemini,
};