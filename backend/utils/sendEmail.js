const axios = require("axios");

const sendEmail = async (to, otp) => {
  const senderEmail = process.env.BREVO_SENDER_EMAIL;

  console.log("SENDER BEFORE SEND =>", senderEmail);
  console.log("RECIPIENT =>", to);

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

            <h1 style="letter-spacing: 5px;">
              ${otp}
            </h1>

            <p>
              This OTP will expire in 5 minutes.
            </p>

            <p>
              If you did not request this code,
              please ignore this email.
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
      "✅ Brevo email sent successfully"
    );

    console.log(
      "Brevo response =>",
      response.data
    );

    return {
      success: true,
      messageId: response.data.messageId,
    };

  } catch (error) {

    console.error(
      "❌ Brevo email error =>",
      error.response?.status
    );

    console.error(
      "Brevo error data =>",
      error.response?.data
    );

    console.error(
      "Brevo error message =>",
      error.message
    );

    throw new Error(
      "Failed to send verification email"
    );
  }
};

module.exports = sendEmail;