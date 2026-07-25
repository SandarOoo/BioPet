require("dotenv").config();

const API_KEY = process.env.GEMINI_API_KEY;

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
      "🔥 RAW GEMINI AI:",
      text
    );

    let cleaned = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    const start =
      cleaned.indexOf("{");

    const end =
      cleaned.lastIndexOf("}");

    if (
      start === -1 ||
      end === -1
    ) {
      throw new Error(
        "No JSON found in Gemini response"
      );
    }

    const jsonString =
      cleaned.substring(
        start,
        end + 1
      );

    const result =
      JSON.parse(jsonString);

    return result;

  } catch (err) {

    console.error(
      "❌ AI PARSE ERROR:",
      err.message
    );

    // Safe fallback
    return {

      allowed: true,

      petRelated: true,

      category: "general",

      reason:
        "AI response could not be parsed"

    };

  }

}


// =====================================================
// ANALYZE POST
// =====================================================

async function analyzePost(text) {

  try {

    if (!API_KEY) {

      throw new Error(
        "GEMINI_API_KEY is missing"
      );

    }

    console.log(
      "🤖 Sending post to Gemini..."
    );

    const response =
      await fetch(

        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}`,

        {

          method: "POST",

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

You are a strict AI moderator for a pet social media application.

Your job is to check whether the user's post is appropriate.

RULES:

1. Allow pet-related content.
2. Allow posts about dogs, cats, birds, animals, pets, veterinary care, pet health, pet food, pet adoption, pet grooming and pet products.
3. Block spam.
4. Block scams.
5. Block hate speech.
6. Block unrelated content.
7. Block advertisements that are not related to pets.
8. If the post is related to pets, allowed should be true.

Return ONLY valid JSON.

Do not use markdown.
Do not use ```.

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
    // CHECK API ERROR
    // =================================================

    if (!response.ok) {

      console.error(
        "❌ GEMINI API ERROR:",
        data
      );

      throw new Error(
        data?.error?.message ||
        `Gemini API error: ${response.status}`
      );

    }


    // =================================================
    // GET GEMINI TEXT
    // =================================================

    const raw =
      data
        ?.candidates?.[0]
        ?.content?.parts?.[0]
        ?.text;


    if (!raw) {

      throw new Error(
        "Gemini returned no text"
      );

    }


    // =================================================
    // PARSE JSON
    // =================================================

    return safeParseAI(
      raw
    );


  } catch (err) {

    console.error(
      "❌ GEMINI ERROR:",
      err.message
    );


    // Safe fallback
    return {

      allowed: true,

      petRelated: true,

      category: "general",

      reason:
        "AI service temporarily unavailable"

    };

  }

}


module.exports = {
  analyzePost,
};