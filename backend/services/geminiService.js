require("dotenv").config({
  path: "../.env",
});

const API_KEY =
  process.env.GEMINI_API_KEY;

console.log(
  "GEMINI KEY EXISTS:",
  !!API_KEY
);

// =====================================================
// SAFE JSON PARSER
// =====================================================

function safeParseAI(text) {

  try {

    console.log(
      "🔥 RAW GEMINI:",
      text
    );

    let cleaned =
      text

        .replace(
          /```json/gi,
          ""
        )

        .replace(
          /```/g,
          ""
        )

        .trim();

    const start =
      cleaned.indexOf(
        "{"
      );

    const end =
      cleaned.lastIndexOf(
        "}"
      );

    if (
      start === -1 ||
      end === -1
    ) {

      throw new Error(
        "No JSON found"
      );

    }

    const jsonString =
      cleaned.substring(
        start,
        end + 1
      );

    const parsed =
      JSON.parse(
        jsonString
      );

    return {

      allowed:
        parsed.allowed !== false,

      petRelated:
        parsed.petRelated === true,

      category:
        parsed.category ||
        "general",

      reason:
        parsed.reason ||
        "AI moderation completed",

    };

  } catch (err) {

    console.error(
      "❌ JSON PARSE ERROR:",
      err.message
    );

    // IMPORTANT:
    // Fallback means allow post
    // if Gemini response cannot be parsed.

    return {

      allowed:
        true,

      petRelated:
        true,

      category:
        "general",

      reason:
        "AI response could not be parsed",

    };

  }

}

// =====================================================
// GEMINI AI MODERATION
// =====================================================

async function analyzePost(
  text
) {

  try {

    if (!API_KEY) {

      console.error(
        "❌ GEMINI_API_KEY NOT FOUND"
      );

      return {

        allowed:
          true,

        petRelated:
          true,

        category:
          "general",

        reason:
          "Gemini API key not configured",

      };

    }

    console.log(
      "🤖 SENDING POST TO GEMINI"
    );

    const response =
      await fetch(

        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}`,

        {

          method:
            "POST",

          headers: {

            "Content-Type":
              "application/json",

          },

          body:
            JSON.stringify({

              contents: [

                {

                  parts: [

                    {

                      text: `

You are an AI moderator for a PET SOCIAL MEDIA APP.

Your job is to check whether a user's post is related to pets.

RULES:

1. Allow posts about:
- Dogs
- Cats
- Birds
- Rabbits
- Fish
- Other pets
- Pet health
- Pet food
- Pet adoption
- Pet care
- Pet training
- Veterinary topics
- Pet products

2. Block posts that are:
- Completely unrelated to pets
- Spam
- Scam
- Hate speech
- Dangerous content

Return ONLY valid JSON.

Do NOT use markdown.

Do NOT write explanations outside JSON.

JSON FORMAT:

{
  "allowed": true,
  "petRelated": true,
  "category": "health",
  "reason": "This post is about pet health."
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

    console.log(
      "GEMINI STATUS:",
      response.status
    );

    const data =
      await response.json();

    console.log(
      "GEMINI RESPONSE:",
      JSON.stringify(
        data,
        null,
        2
      )
    );

    // =================================================
    // API ERROR
    // =================================================

    if (
      !response.ok
    ) {

      console.error(
        "❌ GEMINI API ERROR:",
        data
      );

      return {

        allowed:
          true,

        petRelated:
          true,

        category:
          "general",

        reason:
          "Gemini API error",

      };

    }

    // =================================================
    // GET AI TEXT
    // =================================================

    const raw =
      data
        ?.candidates
        ?.[0]
        ?.content
        ?.parts
        ?.[0]
        ?.text;

    if (!raw) {

      console.error(
        "❌ NO GEMINI TEXT"
      );

      return {

        allowed:
          true,

        petRelated:
          true,

        category:
          "general",

        reason:
          "No Gemini response",

      };

    }

    // =================================================
    // PARSE AI
    // =================================================

    return safeParseAI(
      raw
    );

  } catch (err) {

    console.error(
      "❌ GEMINI ERROR:",
      err
    );

    return {

      allowed:
        true,

      petRelated:
        true,

      category:
        "general",

      reason:
        "Gemini connection error",

    };

  }

}

// =====================================================
// EXPORT
// =====================================================

module.exports = {

  analyzePost,

};