require("dotenv").config();

const API_KEY = process.env.GEMINI_API_KEY;
console.log("GEMINI KEY EXISTS:", !!API_KEY);

//json extract
function safeParseAI(text) {
  try {
    console.log("🔥 RAW AI:", text);

    // remove markdown
    let cleaned = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    // extract JSON only
    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");

    if (start === -1 || end === -1) {
      throw new Error("No JSON found");
    }

    const jsonString = cleaned.substring(start, end + 1);

    return JSON.parse(jsonString);
  } catch (err) {
    console.log("PARSE ERROR:", err.message);

    return {
      allowed: true,
      petRelated: true,
      category: "general",
      reason: "fallback safe mode"
    };
  }
}

//ai function
async function analyzePost(text) {
  try {
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
              parts: [
                {
                  text: `
You are a strict moderator for a PET social app.

RULES:
- Allow ONLY pet-related posts
- Block spam, ads, scams, hate

Return ONLY JSON (NO markdown, NO explanation):

{
  "allowed": true,
  "petRelated": true,
  "category": "health | adoption | food | spam | general",
  "reason": "short reason"
}

POST:
"${text}"
                  `,
                },
              ],
            },
          ],
        }),
      }
    );

    const data = await response.json();
    console.log("STATUS:", response.status);

    console.log(
      "FULL GEMINI RESPONSE:",
      JSON.stringify(data, null, 2)
    );

    const raw =
      data?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!raw) {
      console.log("NO AI TEXT RESPONSE");
      return {
        allowed: true,
        petRelated: true,
        category: "general",
        reason: "No Gemini response"
      };
    }

    return safeParseAI(raw);


  } catch (err) {
    console.log("GEMINI ERROR:", err.message);

    return {
      allowed: true,
      petRelated: true,
      category: "general",
      reason: "API fallback error"
    };
  }
}

module.exports = { analyzePost };