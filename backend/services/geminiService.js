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
          /```json/g,
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

    return JSON.parse(
      jsonString
    );

  } catch (error) {

    console.error(
      "❌ AI JSON PARSE ERROR:",
      error.message
    );

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
// GEMINI AI
// =====================================================

async function analyzePost(
  text
) {

  try {

    if (
      !API_KEY
    ) {

      console.error(
        "❌ GEMINI_API_KEY IS MISSING"
      );

      return {
        allowed:
          true,

        petRelated:
          true,

        category:
          "general",

        reason:
          "Gemini API key missing",
      };

    }


    console.log(
      "🤖 Sending post to Gemini..."
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

You are an AI content moderator for BioPet,
a social media application for pet lovers.

Your job is to check whether a post is related
to pets.

ALLOW:
- Dogs
- Cats
- Birds
- Fish
- Rabbits
- Pet health
- Pet food
- Pet adoption
- Pet care
- Veterinary topics
- Pet products

BLOCK:
- Spam
- Scam
- Hate speech
- Illegal content
- Completely unrelated posts
- Advertising unrelated to pets

Return ONLY valid JSON.

Do NOT use markdown.

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


    if (
      !response.ok
    ) {

      console.error(
        "❌ GEMINI API ERROR"
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


    const raw =
      data
        ?.candidates
        ?.[0]
        ?.content
        ?.parts
        ?.[0]
        ?.text;


    if (
      !raw
    ) {

      console.error(
        "❌ NO GEMINI RESPONSE"
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


    return safeParseAI(
      raw
    );

  } catch (error) {

    console.error(
      "❌ GEMINI ERROR:",
      error.message
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


module.exports = {
  analyzePost,
};