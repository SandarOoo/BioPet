const axios = require("axios");

const sendEmail = async (to, otp) => {
  const senderEmail = process.env.BREVO_SENDER_EMAIL;

  console.log("=================================");
  console.log("SENDING OTP EMAIL");
  console.log("TO =>", to);
  console.log("FROM =>", senderEmail);
  console.log(
    "BREVO KEY EXISTS =>",
    !!process.env.BREVO_API_KEY
  );

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
          <div style="font-family: Arial, sans-serif;">
            <h2>BioPet Email Verification</h2>

            <p>Your verification code is:</p>

            <h1>${otp}</h1>

            <p>
              This OTP will expire in 5 minutes.
            </p>
          </div>
        `,
      },
      {
        headers: {
          "api-key": process.env.BREVO_API_KEY,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      }
    );

    console.log(
      "✅ BREVO EMAIL SENT"
    );

    console.log(
      "BREVO RESPONSE =>",
      response.data
    );

    return {
      success: true,
      messageId: response.data.messageId,
    };

  } catch (error) {
    console.error("=================================");
    console.error("❌ BREVO EMAIL FAILED");
    console.error("STATUS =>", error.response?.status);
    console.error("DATA =>", error.response?.data);
    console.error("MESSAGE =>", error.message);
    console.error("=================================");

    throw error;
  }
};

module.exports = sendEmail;