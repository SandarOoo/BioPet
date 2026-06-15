const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();
const Otp = require('../models/otp');
const nodemailer = require('nodemailer');

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false,

    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },

    tls: {
      rejectUnauthorized: false,
    },
  });


// Register
router.post('/register', async (req, res) => {
  const {
    name,
    email,
    password,
    phone,
    role,
    businessProfile,
  } = req.body;

  try {
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    if (role === 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot register as admin',
      });
    }

    await User.create({
      name,
      email,
      password,
      phone,
      role: role || 'user',
      isVerified: false,
      businessProfile:
        role === 'business_owner'
          ? businessProfile
          : {},
    });

    const otpCode = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    await Otp.deleteMany({ email });

    await Otp.create({
      email,
      otp: otpCode,
      expiresAt: new Date(
        Date.now() + 5 * 60 * 1000
      ),
    });

    console.log(process.env.EMAIL_USER);
    console.log(process.env.EMAIL_PASS);

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Verify Your Email',
      html: `
        <h2>Welcome to BioPet</h2>
        <p>Your verification code is:</p>
        <h1>${otpCode}</h1>
        <p>This code expires in 5 minutes.</p>
      `,
    });

    res.status(201).json({
      success: true,
      message:
        'Registration successful. Please verify your email.',
      email,
    });

  } catch (err) {
    console.error('REGISTER ERROR:', err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

transporter.verify(function (error, success) {
  if (error) {
    console.log(error);
  } else {
    console.log("SMTP Ready");
  }
});

//email verification

router.post('/verify-email', async (req, res) => {
  const { email, otp } = req.body;

  try {
    console.log("EMAIL =", email);
    console.log("OTP =", otp);

    const otpRecord = await Otp.findOne({ email });

    console.log("OTP RECORD =", otpRecord);

    if (!otpRecord) {
      return res.status(400).json({
        success: false,
        message: 'OTP not found',
      });
    }

    if (otpRecord.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP',
      });
    }

    if (otpRecord.expiresAt < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'OTP expired',
      });
    }

    const user = await User.findOneAndUpdate(
      { email },
      { isVerified: true },
      { new: true }
    );

    console.log("USER UPDATED =", user);

    await Otp.deleteOne({ email });

    res.json({
      success: true,
      message: 'Email verified successfully',
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        businessProfile: user.businessProfile,
      },
    });
  } catch (err) {
    console.error("VERIFY ERROR =", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

router.post('/resend-otp', async (req,res) => {
     const {email} = req.body;

     try {
        const otpCode = Math.floor(
        100000 + Math.random() * 900000).toString();

        await Otp.findOneAndUpdate(
            { email },
            {
                otp: otpCode,
                expiresAt: new Date(
                    Date.now() + 5 *60* 1000
                ),
            }, {
            upsert: true
            });

            await transporter.sendMail({
                  from: process.env.EMAIL_USER,
                  to: email,
                  subject: 'New Verification Code',
                  html: `
                    <h2>BioPet Verification</h2>
                    <p>Your new OTP is:</p>
                    <h1>${otpCode}</h1>
                  `,
                });

                res.json({
                  success: true,
                  message: 'OTP resent successfully',
                });

              } catch (err) {
                res.status(500).json({
                  success: false,
                  message: err.message,
                });
              }
            });

//Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    if (!user.isVerified) {
      return res.status(403).json({
        success: false,
        message: 'Please verify your email first',
      });
    }
    if (user.isBlocked) {
      return res.status(403).json({ success: false, message: 'Account blocked' });
    }
    res.json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        businessProfile: user.businessProfile,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get Me
router.get('/me', protect, (req, res) => {
  res.json({ success: true, user: req.user });
});

module.exports = router;