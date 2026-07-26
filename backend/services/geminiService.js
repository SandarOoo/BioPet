require("dotenv").config();

const API_KEY = process.env.GEMINI_API_KEY;

console.log("GEMINI KEY EXISTS:", !!API_KEY);

// =====================================================
// SAFE JSON PARSER
// =====================================================

function safeParseAI(text) {
  try {
    console.log("🔥 RAW GEMINI AI:", text);

    let cleaned = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");

    if (start === -1 || end === -1) {
      throw new Error("No JSON found");
    }

    const jsonString = cleaned.substring(start, end + 1);

    return JSON.parse(jsonString);
  } catch (err) {
    console.error("❌ AI PARSE ERROR:", err.message);

    return {
      allowed: true,
      petRelated: true,
      category: "general",
      reason: "AI response could not be parsed",
    };
  }
}

// =====================================================
// ANALYZE POST (TEXT + IMAGES)
// =====================================================

async function analyzePost(text, images = []) {
  try {
    if (!API_KEY) {
      throw new Error("GEMINI_API_KEY is missing");
    }

    console.log("🤖 Sending post to Gemini...");
    console.log("🖼️ Image count:", images.length);

    const promptText = `
You are a strict AI moderator for a PET social media application.

RULES:

1. Allow ONLY pet-related posts (text AND images).
2. Allow posts about dogs, cats, birds, animals, pets, veterinary care, pet health, pet food, pet adoption, pet grooming and pet products.
3. Block spam.
4. Block scams.
5. Block hate speech.
6. Block unrelated content (including images that are not pet-related).
7. Block advertisements that are not related to pets.
8. If images are attached, check that the images also show pets or pet-related content.

Return ONLY valid JSON.

Do not use markdown.
Do not use code blocks.
Do not write any explanation outside JSON.

JSON FORMAT:

{
  "allowed": true,
  "petRelated": true,
  "category": "health",
  "reason": "Short explanation"
}

Allowed categories:

health
adoption
food
grooming
product
general
spam
scam
hate
unrelated

POST TEXT:

"${text}"
    `;

    // Build image parts for Gemini (inline base64)
    const imageParts = images
      .filter((img) => img && img.data)
      .map((img) => {
        const base64Data = img.data.includes(",")
          ? img.data.split(",").pop()
          : img.data;

        return {
          inline_data: {
            mime_type: img.contentType || "image/jpeg",
            data: base64Data,
          },
        };
      });

    const parts = [{ text: promptText }, ...imageParts];

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: parts,
            },
          ],
        }),
      }
    );

    console.log("GEMINI STATUS:", response.status);

    const data = await response.json();

    console.log("GEMINI RESPONSE:", JSON.stringify(data, null, 2));

    if (!response.ok) {
      console.error("❌ GEMINI API ERROR:", data);

      throw new Error(
        data?.error?.message || `Gemini API error: ${response.status}`
      );
    }

    const raw = data?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!raw) {
      throw new Error("Gemini returned no text");
    }

    return safeParseAI(raw);
  } catch (err) {
    console.error("❌ GEMINI ERROR:", err.message);

    return {
      allowed: true,
      petRelated: true,
      category: "general",
      reason: "AI service temporarily unavailable",
    };
  }
}

module.exports = {
  analyzePost,
};