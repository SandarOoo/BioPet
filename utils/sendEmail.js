const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
  tls: {
    rejectUnauthorized: false,
  },
});

const sendEmail = async (email, otp) => {
  await transporter.sendMail({
    from: `BioPet <${process.env.EMAIL_USER}>`,
    to: email,
    subject: "BioPet OTP Verification",
    text: `Your OTP code is: ${otp}`,
  });
};

module.exports = sendEmail;