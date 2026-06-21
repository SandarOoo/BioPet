const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const sendEmail = require('../utils/sendEmail');

const router = express.Router();

// ==========================
// JWT TOKEN
// ==========================
const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });

// ==========================
// REGISTER (SEND OTP)
// ==========================
router.post('/register', async (req, res) => {
  const { name, email, password, phone, role, businessProfile } = req.body;

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

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const user = await User.create({
      name,
      email,
      password,
      phone,
      role: role || 'user',
      businessProfile: role === 'business_owner' ? businessProfile : {},
      otp,
      otpExpiresAt: Date.now() + 5 * 60 * 1000,
      lastOtpSentAt: Date.now(),
      isVerified: false,
    });

    // SEND OTP EMAIL
    await sendEmail(email, otp);

    res.status(201).json({
      success: true,
      message: 'OTP sent to email. Please verify account.',
      userId: user._id,
    });
  } catch (err) {
    console.error('REGISTER ERROR:', err);
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// ==========================
// VERIFY EMAIL (OTP CHECK)
// ==========================
router.post('/verify-email', async (req, res) => {
  try {
    const { email, otp } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    if (user.isVerified) {
      return res.json({ success: false, message: 'Already verified' });
    }

    if (!user.otp || !user.otpExpiresAt) {
      return res.json({
        success: false,
        message: 'No OTP found. Please request again.',
      });
    }

    if (user.otp !== otp) {
      return res.json({ success: false, message: 'Invalid OTP' });
    }

    if (user.otpExpiresAt < Date.now()) {
      return res.json({ success: false, message: 'OTP expired' });
    }

    user.isVerified = true;
    user.otp = null;
    user.otpExpiresAt = null;

    await user.save();

    res.json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// ==========================
// LOGIN
// ==========================
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'Account blocked',
      });
    }

    if (!user.isVerified) {
      return res.status(403).json({
        success: false,
        code: 'NOT_VERIFIED',
        message: 'Please verify your email first',
      });
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
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// ==========================
// RESEND OTP (WITH COOLDOWN)
// ==========================
router.post('/resend-otp', async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    // COOLDOWN (1 minute)
    const cooldown = 60 * 1000;

    if (
      user.lastOtpSentAt &&
      Date.now() - user.lastOtpSentAt < cooldown
    ) {
      return res.status(429).json({
        success: false,
        message: 'Please wait before requesting another OTP',
      });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    user.otp = otp;
    user.otpExpiresAt = Date.now() + 5 * 60 * 1000;
    user.lastOtpSentAt = Date.now();

    await user.save();

    // SEND EMAIL
    await sendEmail(email, otp);

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

// ==========================
// GET ME
// ==========================
router.get('/me', protect, (req, res) => {
  res.json({ success: true, user: req.user });
});

module.exports = router;