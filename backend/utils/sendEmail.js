const axios = require("axios");

const sendEmail = async (to, otp) => {
  const apiKey = process.env.BREVO_API_KEY;
  const senderEmail =
    process.env.BREVO_SENDER_EMAIL || "biopet2026@gmail.com";

  console.log("=================================");
  console.log("BREVO DEBUG");
  console.log("API KEY EXISTS:", !!apiKey);
  console.log("API KEY LENGTH:", apiKey ? apiKey.length : 0);
  console.log("API KEY START:", apiKey ? apiKey.substring(0, 8) : "NONE");
  console.log("SENDER:", senderEmail);
  console.log("RECIPIENT:", to);
  console.log("=================================");

  if (!apiKey) {
    throw new Error("BREVO_API_KEY is missing");
  }

  try {
    const response = await axios.post(
      "https://api.brevo.com/v3/smtp/email",
      {
        sender: {
          name: "BioPet",
          email: senderEmail,
        },

        to: [
          {
            email: to,
          },
        ],

        subject: "BioPet OTP Verification",

        htmlContent: `
          <h2>BioPet Email Verification</h2>

          <p>Your verification code is:</p>

          <h1>${otp}</h1>

          <p>This OTP will expire in 5 minutes.</p>
        `,
      },
      {
        headers: {
          "api-key": apiKey,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      }
    );

    console.log("=================================");
    console.log("✅ BREVO SUCCESS");
    console.log("STATUS:", response.status);
    console.log("DATA:", response.data);
    console.log("=================================");

    return response.data;

  } catch (error) {

    console.error("=================================");
    console.error("❌ BREVO FAILED");
    console.error("STATUS:", error.response?.status);
    console.error("DATA:", error.response?.data);
    console.error("MESSAGE:", error.message);
    console.error("=================================");

    throw error;
  }
};

module.exports = sendEmail;