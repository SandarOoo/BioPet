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

// Gmail address must end with @gmail.com.
// The part before @gmail.com must contain at least one letter and one number.
const gmailRegex =
  /^(?=[A-Za-z0-9._%+-]*[A-Za-z])(?=[A-Za-z0-9._%+-]*\d)[A-Za-z0-9._%+-]+@gmail\.com$/i;

// Password must contain at least 8 characters, including uppercase,
// lowercase, number and special character, with no spaces.
const strongPasswordRegex =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])(?!.*\s).{8,}$/;

// ==========================
// REGISTER
// ==========================
router.post('/register', async (req, res) => {
  console.log('REGISTER HIT');

  const {
    name,
    email,
    password,
    phone,
    role,
    businessProfile,
  } = req.body;

  try {
    const normalizedName = String(name || '').trim();
    const normalizedEmail = String(email || '')
      .trim()
      .toLowerCase();

    const selectedRole = role || 'user';

    if (!normalizedName  !normalizedEmail  !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email and password are required',
      });
    }

    if (!gmailRegex.test(normalizedEmail)) {
      return res.status(400).json({
        success: false,
        message:
          'Email must end with @gmail.com and contain at least one letter and one number',
      });
    }

    if (!strongPasswordRegex.test(String(password))) {
      return res.status(400).json({
        success: false,
        message:
          'Password must be at least 8 characters and include uppercase, lowercase, number and special character with no spaces',
      });
    }

    const existingUser = await User.findOne({
      email: normalizedEmail,
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    if (selectedRole === 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot register as admin',
      });
    }

    const otp = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    const user = await User.create({
      name: normalizedName,
      email: normalizedEmail,
      password,
      phone,
      role: selectedRole,

      businessProfile:
        selectedRole === 'business_owner'
          ? {
              businessName:
                businessProfile?.businessName || '',

              businessType:
                businessProfile?.businessType || '',

              address:
                businessProfile?.address || '',

              latitude:
                businessProfile?.latitude ?? null,

              longitude:
                businessProfile?.longitude ?? null,

              description:
                businessProfile?.description || '',

              agreementAccepted: false,
              verificationStatus: 'draft',
              rejectReason: '',
            }
          : {},

      otp,
      otpExpiresAt: Date.now() + 5 * 60 * 1000,
      lastOtpSentAt: Date.now(),
      isVerified: false,
    });

    sendEmail(normalizedEmail, otp).catch((err) => {
      console.log('Email error:', err.message);
    });

    return res.status(201).json({
      success: true,
      message: 'OTP sent to email. Please verify account.',
      userId: user._id,
    });
  } catch (err) {
    console.error('REGISTER ERROR:', err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// ==========================
// VERIFY EMAIL
// ==========================
router.post('/verify-email', async (req, res) => {
  try {
    const { email, otp } = req.body;

    const user = await User.findOne({ email });

        if (!user) {
          return res.json({
            success: false,
            message: 'User not found',
          });
        }

        if (user.isVerified) {
          return res.json({
            success: false,
            message: 'Already verified',
          });
        }

        if (!user.otp || !user.otpExpiresAt) {
          return res.json({
            success: false,
            message: 'No OTP found',
          });
        }

        if (user.otp !== otp) {
          return res.json({
            success: false,
            message: 'Invalid OTP',
          });
        }

        if (user.otpExpiresAt < Date.now()) {
          return res.json({
            success: false,
            message: 'OTP expired',
          });
        }

        user.isVerified = true;
        user.otp = null;
        user.otpExpiresAt = null;

        await user.save();

        return res.json({
          success: true,
          message: 'Email verified successfully',
        });
      } catch (err) {
        return res.status(500).json({
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

        // Blocked account
        if (user.isBlocked) {
          return res.status(403).json({
            success: false,
            message: 'Account blocked',
          });
        }

        // Email verification
        if (!user.isVerified) {
          return res.status(403).json({
            success: false,
            code: 'NOT_VERIFIED',
            message: 'Please verify your email first',
          });
        }

        return res.json({
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
        return res.status(500).json({
          success: false,
          message: err.message,
        });
      }
    });

    // ==========================
    // RESEND OTP
    // ==========================
    router.post('/resend-otp', async (req, res) => {
      try {
        const { email } = req.body;

        const user = await User.findOne({ email });

        if (!user) {
          return res.json({
            success: false,
            message: 'User not found',
          });
        }

        const cooldown = 60 * 1000;

        if (
          user.lastOtpSentAt &&
          Date.now() - user.lastOtpSentAt < cooldown
        ) {
          return res.status(429).json({
            success: false,
            message:
              'Please wait before requesting another OTP',
          });
        }

        const otp = Math.floor(
          100000 + Math.random() * 900000
        ).toString();

        user.otp = otp;
        user.otpExpiresAt = Date.now() + 5 * 60 * 1000;
        user.lastOtpSentAt = Date.now();

        await user.save();

        await sendEmail(user.email, otp);

        return res.json({
          success: true,
          message: 'OTP resent successfully',
        });
      } catch (err) {
        return res.status(500).json({
          success: false,
          message: err.message,
        });
      }
    });

    // ==========================
    // GET CURRENT USER
    // ==========================
    router.get('/me', protect, async (req, res) => {
      try {
        return res.json({
          success: true,
          user: req.user,
        });
      } catch (err) {
        console.error('GET ME ERROR:', err);

        return res.status(500).json({
          success: false,
          message: err.message,
        });
      }
    });

    module.exports = router;