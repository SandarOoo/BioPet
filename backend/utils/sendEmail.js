const axios = require("axios");

const sendEmail = async (to, otp) => {

  const senderEmail = "biopet2026@gmail.com";

  console.log("SENDER BEFORE SEND =>", senderEmail);

  try {

    const response = await axios.post(
      "https://api.brevo.com/v3/smtp/email",
      {
        sender: {
          name: "BioPet",
          email: senderEmail
        },

        to: [
          {
            email: to
          }
        ],

        subject: "BioPet OTP Verification",

        htmlContent: `
          <h2>BioPet Verification</h2>
          <h1>${otp}</h1>
        `
      },
      {
        headers: {
          "api-key": process.env.BREVO_API_KEY,
          "content-type": "application/json"
        }
      }
    );

    console.log("Brevo response =>", response.data);

  } catch(error){
    console.log(
      "Brevo error =>",
      error.response?.data || error.message
    );
  }

};

module.exports = sendEmail;