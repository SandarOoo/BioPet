const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendEmail = async (to, otp) => {
  try {
    console.log('Sending OTP to:', to);
    console.log('EMAIL_USER:', process.env.EMAIL_USER);
    console.log(
      'APP PASSWORD EXISTS:',
      !!process.env.EMAIL_PASS
    );

    const info = await transporter.sendMail({
      from: `"BioPet" <${process.env.EMAIL_USER}>`,
      to: to,
      subject: 'BioPet Email Verification OTP',

      html: `
        <div style="font-family: Arial; padding: 20px;">
          <h2>🐾 BioPet Email Verification</h2>

          <p>Your verification OTP is:</p>

          <h1 style="letter-spacing: 8px;">
            ${otp}
          </h1>

          <p>This OTP will expire in 5 minutes.</p>

          <p>Thank you for using BioPet.</p>
        </div>
      `,
    });

    console.log('✅ EMAIL SENT');
    console.log('Message ID:', info.messageId);

    return info;

  } catch (error) {

    console.error('❌ EMAIL SEND ERROR');
    console.error('Code:', error.code);
    console.error('Message:', error.message);
    console.error('Response:', error.response);

    throw error;
  }
};

module.exports = sendEmail;