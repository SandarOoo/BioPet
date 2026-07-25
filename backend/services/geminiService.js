const API_KEY = process.env.GEMINI_API_KEY;

console.log(
  "GEMINI KEY EXISTS:",
  !!API_KEY
);


// =====================================================
// JSON PARSER
// =====================================================

function safeParseAI(text) {

  try {

    console.log(
      "🔥 RAW GEMINI TEXT:",
      text
    );

    let cleaned =
      text
        .replace(/```json/gi, "")
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
        "No JSON found"
      );

    }

    const jsonString =
      cleaned.substring(
        start,
        end + 1
      );

    const result =
      JSON.parse(
        jsonString
      );

    console.log(
      "✅ AI RESULT:",
      result
    );

    return result;

  } catch (err) {

    console.log(
      "❌ PARSE ERROR:",
      err.message
    );

    return {

      allowed: false,

      petRelated: false,

      category: "error",

      reason:
        "AI moderation failed. Please try again."

    };

  }

}


// =====================================================
// GEMINI ANALYZE POST
// =====================================================

async function analyzePost(text) {

  try {

    // API KEY မရှိရင် error
    if (!API_KEY) {

      throw new Error(
        "GEMINI_API_KEY is missing"
      );

    }


    console.log(
      "🤖 Gemini analyzing post..."
    );

    console.log(
      "POST TEXT:",
      text
    );


    // Gemini API
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

You are an AI moderator for a PET social media application.

RULES:

1. Only allow pet-related posts.

2. Allow:
- Dogs
- Cats
- Pet health
- Pet food
- Pet care
- Pet adoption
- Animal rescue
- Pet training
- Veterinary topics

3. Block:
- Spam
- Scam
- Hate speech
- Illegal content
- Advertising
- Unrelated content

Return ONLY valid JSON.

Do not use markdown.

Return exactly:

{
  "allowed": true,
  "petRelated": true,
  "category": "health",
  "reason": "Short reason"
}

Possible categories:

health
adoption
food
care
training
spam
scam
hate
general
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


    // Gemini Error
    if (!response.ok) {

      throw new Error(
        data?.error?.message ||
        `Gemini API error: ${response.status}`
      );

    }


    // AI Text
    const raw =
      data
        ?.candidates?.[0]
        ?.content?.parts?.[0]
        ?.text;


    if (!raw) {

      throw new Error(
        "Gemini returned empty response"
      );

    }


    // JSON Parse
    return safeParseAI(
      raw
    );


  } catch (err) {

    console.error(
      "❌ GEMINI ERROR:",
      err.message
    );

    return {

      allowed: false,

      petRelated: false,

      category: "error",

      reason:
        "AI moderation service is unavailable. Please try again."

    };

  }

}


module.exports = {
  analyzePost
};