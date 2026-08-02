const OpenAI = require("openai");

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function moderatePetPost(text) {
  try {
    const response = await openai.responses.create({
      model: "gpt-4o-mini",
      input: [
        {
          role: "system",
          content: `
You are a content moderator for BioPet, a pet community application.

Analyze the user's post and determine:

1. Is the post related to pets or animals?
2. Is the content safe and appropriate?
3. Should the post be allowed?

Return ONLY valid JSON in this exact format:

{
  "allowed": true,
  "petRelated": true,
  "reason": "Short explanation"
}

Rules:
- allowed = true only if the content is pet-related and appropriate.
- allowed = false if the content is unrelated to pets, spam, advertising, or inappropriate.
- Keep the reason short.
          `,
        },
        {
          role: "user",
          content: text || "",
        },
      ],
    });

    const resultText = response.output_text;

    const result = JSON.parse(resultText);

    return {
      allowed: Boolean(result.allowed),
      petRelated: Boolean(result.petRelated),
      reason:
        result.reason ||
        "Content moderation completed.",
    };
  } catch (error) {
    console.error(
      "OPENAI MODERATION ERROR:",
      error
    );

    throw new Error(
      "AI moderation failed."
    );
  }
}

module.exports = {
  moderatePetPost,
};