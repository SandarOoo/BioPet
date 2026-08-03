const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_APP_PASSWORD,
  },
});

const sendEmail = async (to, otp) => {

  console.log('=================================');
  console.log('EMAIL DEBUG');
  console.log('EMAIL_USER:', process.env.EMAIL_USER);
  console.log(
    'EMAIL_APP_PASSWORD EXISTS:',
    !!process.env.EMAIL_APP_PASSWORD
  );
  console.log('TO:', to);
  console.log('OTP:', otp);
  console.log('=================================');

  try {

    // Verify SMTP connection first
    await transporter.verify();

    console.log('✅ Gmail SMTP connection successful');

    const mailOptions = {
      from: `"BioPet" <${process.env.EMAIL_USER}>`,
      to: to,
      subject: 'BioPet Email Verification OTP',

      html: `
        <div style="
          font-family: Arial, sans-serif;
          max-width: 600px;
          margin: auto;
          padding: 30px;
          border: 1px solid #ddd;
          border-radius: 10px;
        ">

          <h2>🐾 BioPet Email Verification</h2>

          <p>Hello,</p>

          <p>
            Thank you for registering with BioPet.
          </p>

          <p>
            Your verification code is:
          </p>

          <h1 style="
            letter-spacing: 10px;
            text-align: center;
          ">
            ${otp}
          </h1>

          <p>
            This OTP will expire in
            <strong>5 minutes</strong>.
          </p>

          <p>
            If you did not create this account,
            please ignore this email.
          </p>

          <br>

          <p>
            Best regards,<br>
            <strong>BioPet Team</strong>
          </p>

        </div>
      `,
    };

    const info =
      await transporter.sendMail(
        mailOptions
      );

    console.log(
      '✅ EMAIL SENT SUCCESSFULLY'
    );

    console.log(
      'Message ID:',
      info.messageId
    );

    return info;

  } catch (error) {

    console.error(
      '❌ GMAIL SMTP ERROR'
    );

    console.error(
      'Error Code:',
      error.code
    );

    console.error(
      'Error Command:',
      error.command
    );

    console.error(
      'Error Response:',
      error.response
    );

    console.error(
      'Error Message:',
      error.message
    );

    throw error;
  }
};

module.exports = sendEmail;