const { GoogleGenerativeAI } = require("@google/generative-ai");

// =====================================================
// GEMINI INITIALIZATION
// =====================================================

const genAI = new GoogleGenerativeAI(
  process.env.GEMINI_API_KEY
);

// =====================================================
// ANALYZE POST
// SUPPORT:
// 1. TEXT ONLY
// 2. IMAGE ONLY
// 3. TEXT + IMAGE
// =====================================================

const analyzePost = async (
  text = "",
  images = []
) => {

  try {

    console.log(
      "================================="
    );

    console.log(
      "🤖 GEMINI AI MODERATION START"
    );

    console.log(
      "📝 TEXT:",
      text
    );

    console.log(
      "🖼️ IMAGE COUNT:",
      images.length
    );

    console.log(
      "================================="
    );


    // =================================================
    // CHECK API KEY
    // =================================================

    if (
      !process.env.GEMINI_API_KEY
    ) {

      console.error(
        "❌ GEMINI_API_KEY NOT FOUND"
      );

      return {
        allowed: true,
        petRelated: true,
        reason:
          "AI service temporarily unavailable",
      };
    }


    // =================================================
    // GEMINI MODEL
    // =================================================

    const model =
      genAI.getGenerativeModel({

        model:
          "gemini-2.0-flash",

      });


    // =================================================
    // PROMPT
    // =================================================

    const prompt = `

You are an AI content moderator for a pet community application.

Analyze the user's post using BOTH text and images if available.

USER POST TEXT:
"${text}"

Your task:

1. Check whether the post contains harmful, abusive, sexual, violent, hateful, or inappropriate content.

2. Check whether the post is related to:
- pets
- dogs
- cats
- animals
- veterinary care
- pet health
- pet care
- grooming
- pet products
- pet food
- pet community

3. If an image is provided, analyze the image carefully.

4. If the post contains both text and image, analyze both together.

5. Do not reject a post just because the language is informal.

6. If the image contains inappropriate or harmful content, allowed must be false.

7. If the text contains inappropriate content, allowed must be false.

8. If the content is safe but not related to pets, allowed can still be true, but petRelated should be false.

Return ONLY valid JSON.

Do not use markdown.
Do not use code blocks.

The JSON format must be:

{
  "allowed": true,
  "petRelated": true,
  "reason": "Short explanation"
}

`;


    // =================================================
    // GEMINI CONTENT
    // =================================================

    const content = [

      {
        text: prompt,
      },

    ];


    // =================================================
    // ADD IMAGES
    // =================================================

    if (
      images &&
      images.length > 0
    ) {

      for (
        const image of images
      ) {

        if (
          !image ||
          !image.buffer ||
          !image.mimetype
        ) {

          continue;

        }


        console.log(
          "🖼️ Sending image to Gemini:",
          image.originalname
        );


        content.push({

          inlineData: {

            mimeType:
              image.mimetype,

            data:
              image.buffer.toString(
                "base64"
              ),

          },

        });

      }

    }


    // =================================================
    // SEND REQUEST TO GEMINI
    // =================================================

    console.log(
      "🚀 Sending request to Gemini..."
    );


    const result =
      await model.generateContent(
        content
      );


    // =================================================
    // GET RESPONSE
    // =================================================

    const response =
      result.response.text();


    console.log(
      "🤖 GEMINI RAW RESPONSE:"
    );

    console.log(
      response
    );


    // =================================================
    // CLEAN RESPONSE
    // =================================================

    let cleaned =
      response.trim();


    // Remove markdown code blocks
    cleaned =
      cleaned.replace(
        /^```json\s*/i,
        ""
      );

    cleaned =
      cleaned.replace(
        /^```\s*/i,
        ""
      );

    cleaned =
      cleaned.replace(
        /\s*```$/i,
        ""
      );

    cleaned =
      cleaned.trim();


    // =================================================
    // PARSE JSON
    // =================================================

    let parsed;

    try {

      parsed =
        JSON.parse(
          cleaned
        );

    } catch (
      parseError
    ) {

      console.error(
        "❌ GEMINI JSON PARSE ERROR:",
        parseError.message
      );

      console.error(
        "RAW RESPONSE:",
        response
      );


      // Try extracting JSON
      const match =
        cleaned.match(
          /\{[\s\S]*\}/
        );


      if (
        !match
      ) {

        throw new Error(
          "Gemini returned invalid JSON"
        );

      }


      parsed =
        JSON.parse(
          match[0]
        );

    }


    // =================================================
    // NORMALIZE RESULT
    // =================================================

    const aiResult = {

      allowed:
        parsed.allowed !== false,

      petRelated:
        parsed.petRelated === true,

      reason:
        parsed.reason ||
        "Content analyzed successfully",

    };


    console.log(
      "================================="
    );

    console.log(
      "✅ GEMINI AI RESULT"
    );

    console.log(
      aiResult
    );

    console.log(
      "================================="
    );


    return aiResult;


  } catch (
    error
  ) {

    console.error(
      "❌ GEMINI ANALYZE ERROR:"
    );

    console.error(
      error.message
    );


    // =================================================
    // FALLBACK
    // =================================================

    return {

      allowed: true,

      petRelated: true,

      reason:
        "AI service temporarily unavailable",

    };

  }

};


// =====================================================
// EXPORT
// =====================================================

module.exports = {
  analyzePost,
};