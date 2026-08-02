const axios = require("axios");

const sendEmail = async (to, otp) => {
  const apiKey = process.env.BREVO_API_KEY;
  const senderEmail = process.env.BREVO_SENDER_EMAIL;

  console.log("=================================");
  console.log("BREVO EMAIL DEBUG");
  console.log("API KEY EXISTS:", !!apiKey);
  console.log("API KEY LENGTH:", apiKey ? apiKey.length : 0);
  console.log("SENDER EMAIL:", senderEmail);
  console.log("RECIPIENT:", to);
  console.log("=================================");

  if (!apiKey) {
    throw new Error("BREVO_API_KEY is missing");
  }

  if (!senderEmail) {
    throw new Error("BREVO_SENDER_EMAIL is missing");
  }

  if (!to) {
    throw new Error("Recipient email is missing");
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

        subject: "BioPet Email Verification",

        htmlContent: `
          <!DOCTYPE html>
          <html>
            <body>
              <h2>Welcome to BioPet 🐾</h2>

              <p>Thank you for registering with BioPet.</p>

              <p>Your email verification code is:</p>

              <h1 style="letter-spacing: 5px;">
                ${otp}
              </h1>

              <p>
                This OTP will expire in <strong>5 minutes</strong>.
              </p>

              <p>
                If you did not create a BioPet account,
                please ignore this email.
              </p>

              <br>

              <p>Thank you,<br>
              <strong>BioPet Team</strong></p>
            </body>
          </html>
        `,
      },
      {
        headers: {
          "api-key": apiKey,
          "Content-Type": "application/json",
          Accept: "application/json",
        },

        timeout: 15000,
      }
    );

    console.log("=================================");
    console.log("✅ BREVO EMAIL SENT");
    console.log("STATUS:", response.status);
    console.log("MESSAGE ID:", response.data?.messageId);
    console.log("=================================");

    return response.data;
  } catch (error) {
    console.error("=================================");
    console.error("❌ BREVO EMAIL FAILED");
    console.error("STATUS:", error.response?.status);
    console.error("BREVO ERROR:", error.response?.data);
    console.error("MESSAGE:", error.message);
    console.error("=================================");

    throw new Error(
      error.response?.data?.message ||
      error.message ||
      "Failed to send verification email"
    );
  }
};

module.exports = sendEmail;