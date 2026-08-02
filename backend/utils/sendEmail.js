
const axios = require("axios");

const sendEmail = async (to, otp) => {
  const apiKey = process.env.BREVO_API_KEY;
  const senderEmail = process.env.BREVO_SENDER_EMAIL;

  console.log("=================================");
  console.log("📧 BREVO EMAIL DEBUG");
  console.log("=================================");
  console.log("API KEY EXISTS:", !!apiKey);
  console.log("API KEY LENGTH:", apiKey ? apiKey.length : 0);
  console.log("SENDER EMAIL:", senderEmail);
  console.log("RECIPIENT:", to);
  console.log("OTP EXISTS:", !!otp);
  console.log("=================================");

  // ==========================================
  // VALIDATION
  // ==========================================

  if (!apiKey) {
    throw new Error(
      "BREVO_API_KEY is missing"
    );
  }

  if (!senderEmail) {
    throw new Error(
      "BREVO_SENDER_EMAIL is missing"
    );
  }

  if (!to) {
    throw new Error(
      "Recipient email is missing"
    );
  }

  if (!otp) {
    throw new Error(
      "OTP is missing"
    );
  }

  try {
    console.log(
      "📤 Sending email to Brevo..."
    );

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

        subject:
          "BioPet Email Verification",

        htmlContent: `
          <!DOCTYPE html>

          <html>

          <head>
            <meta charset="UTF-8">
            <title>BioPet Email Verification</title>
          </head>

          <body>

            <h2>
              Welcome to BioPet 🐾
            </h2>

            <p>
              Thank you for registering
              with BioPet.
            </p>

            <p>
              Your email verification
              code is:
            </p>

            <h1
              style="
                letter-spacing: 5px;
                font-size: 32px;
              "
            >
              ${otp}
            </h1>

            <p>
              This OTP will expire in
              <strong>5 minutes</strong>.
            </p>

            <p>
              If you did not create
              a BioPet account,
              please ignore this email.
            </p>

            <br>

            <p>
              Thank you,
              <br>
              <strong>
                BioPet Team
              </strong>
            </p>

          </body>

          </html>
        `,
      },

      {
        headers: {
          "api-key": apiKey,
          "Content-Type":
            "application/json",
          Accept:
            "application/json",
        },

        timeout: 15000,
      }
    );

    // ==========================================
    // SUCCESS
    // ==========================================

    console.log("=================================");
    console.log("✅ BREVO EMAIL SENT SUCCESSFULLY");
    console.log("=================================");
    console.log(
      "STATUS:",
      response.status
    );
    console.log(
      "MESSAGE ID:",
      response.data?.messageId
    );
    console.log("=================================");

    return response.data;

  } catch (error) {

    // ==========================================
    // BREVO API ERROR
    // ==========================================

    console.error("=================================");
    console.error("❌ BREVO EMAIL FAILED");
    console.error("=================================");

    if (error.response) {

      console.error(
        "HTTP STATUS:",
        error.response.status
      );

      console.error(
        "BREVO RESPONSE:",
        JSON.stringify(
          error.response.data,
          null,
          2
        )
      );

      console.error(
        "BREVO HEADERS:",
        error.response.headers
      );

    } else if (error.request) {

      console.error(
        "❌ NO RESPONSE FROM BREVO"
      );

      console.error(
        "REQUEST ERROR:",
        error.message
      );

    } else {

      console.error(
        "❌ REQUEST SETUP ERROR"
      );

      console.error(
        "ERROR:",
        error.message
      );
    }

    console.error("=================================");

    // ==========================================
    // RETURN CLEAN ERROR
    // ==========================================

    const brevoMessage =
      error.response?.data?.message ||
      error.response?.data?.code ||
      error.message ||
      "Failed to send verification email";

    throw new Error(
      `Brevo email failed: ${brevoMessage}`
    );
  }
};

module.exports = sendEmail;
