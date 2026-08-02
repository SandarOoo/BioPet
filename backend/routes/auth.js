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
  jwt.sign(
    { id },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE,
    }
  );

// ==========================
// REGISTER
// ==========================
router.post('/register', async (req, res) => {

  console.log("=================================");
  console.log("REGISTER HIT");

  const {
    name,
    email,
    password,
    phone,
    role,
    businessProfile,
  } = req.body;

  try {

    // ==========================
    // CHECK EXISTING USER
    // ==========================

    const existingUser =
      await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    // ==========================
    // PREVENT ADMIN REGISTER
    // ==========================

    if (role === 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot register as admin',
      });
    }

    // ==========================
    // GENERATE OTP
    // ==========================

    const otp =
      Math.floor(
        100000 +
        Math.random() * 900000
      ).toString();

    console.log(
      "GENERATED OTP =>",
      otp
    );

    // ==========================
    // CREATE USER
    // ==========================

    const user = await User.create({

      name,

      email,

      password,

      phone,

      role:
        role || 'user',

      businessProfile:
        role === 'business_owner'
          ? {
              businessName:
                businessProfile?.businessName || '',

              businessType:
                businessProfile?.businessType || '',

              address:
                businessProfile?.address || '',

              latitude:
                businessProfile?.latitude || null,

              longitude:
                businessProfile?.longitude || null,

              description:
                businessProfile?.description || '',

              agreementAccepted:
                false,

              verificationStatus:
                'draft',

              rejectReason:
                '',
            }
          : {},

      otp,

      otpExpiresAt:
        Date.now() +
        5 * 60 * 1000,

      lastOtpSentAt:
        Date.now(),

      isVerified:
        false,
    });

    console.log(
      "USER CREATED =>",
      user._id
    );

    // ==========================
    // SEND OTP EMAIL
    // ==========================

    console.log(
      "SENDING OTP EMAIL..."
    );

    await sendEmail(
      email,
      otp
    );

    console.log(
      "✅ OTP EMAIL SENT"
    );

    // ==========================
    // SUCCESS
    // ==========================

    return res.status(201).json({

      success: true,

      message:
        'OTP sent to email. Please verify account.',

      userId:
        user._id,

    });

  } catch (err) {

    console.error(
      "❌ REGISTER ERROR =>",
      err
    );

    return res.status(500).json({

      success: false,

      message:
        'Registration failed. Unable to send verification email.',

      error:
        err.message,

    });
  }
});

// ==========================
// VERIFY EMAIL
// ==========================
router.post(
  '/verify-email',
  async (req, res) => {

    try {

      const {
        email,
        otp,
      } = req.body;

      // ==========================
      // FIND USER
      // ==========================

      const user =
        await User.findOne({
          email,
        });

      if (!user) {
        return res.status(404).json({

          success: false,

          message:
            'User not found',

        });
      }

      // ==========================
      // ALREADY VERIFIED
      // ==========================

      if (user.isVerified) {
        return res.status(400).json({

          success: false,

          message:
            'Already verified',

        });
      }

      // ==========================
      // CHECK OTP
      // ==========================

      if (
        !user.otp ||
        !user.otpExpiresAt
      ) {
        return res.status(400).json({

          success: false,

          message:
            'No OTP found',

        });
      }

      // ==========================
      // CHECK OTP VALUE
      // ==========================

      if (
        user.otp !== otp
      ) {
        return res.status(400).json({

          success: false,

          message:
            'Invalid OTP',

        });
      }

      // ==========================
      // CHECK OTP EXPIRATION
      // ==========================

      if (
        user.otpExpiresAt <
        Date.now()
      ) {
        return res.status(400).json({

          success: false,

          message:
            'OTP expired',

        });
      }

      // ==========================
      // VERIFY USER
      // ==========================

      user.isVerified =
        true;

      user.otp =
        null;

      user.otpExpiresAt =
        null;

      await user.save();

      // ==========================
      // SUCCESS
      // ==========================

      return res.json({

        success: true,

        message:
          'Email verified successfully',

      });

    } catch (err) {

      console.error(
        "VERIFY EMAIL ERROR =>",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message,

      });
    }
  }
);

// ==========================
// LOGIN
// ==========================
router.post(
  '/login',
  async (req, res) => {

    const {
      email,
      password,
    } = req.body;

    try {

      const user =
        await User.findOne({
          email,
        });

      // ==========================
      // CHECK CREDENTIALS
      // ==========================

      if (
        !user ||
        !(await user.matchPassword(password))
      ) {
        return res.status(401).json({

          success: false,

          message:
            'Invalid credentials',

        });
      }

      // ==========================
      // CHECK BLOCKED
      // ==========================

      if (
        user.isBlocked
      ) {
        return res.status(403).json({

          success: false,

          message:
            'Account blocked',

        });
      }

      // ==========================
      // CHECK EMAIL VERIFIED
      // ==========================

      if (
        !user.isVerified
      ) {
        return res.status(403).json({

          success: false,

          code:
            'NOT_VERIFIED',

          message:
            'Please verify your email first',

        });
      }

      // ==========================
      // LOGIN SUCCESS
      // ==========================

      return res.json({

        success: true,

        token:
          generateToken(
            user._id
          ),

        user: {

          id:
            user._id,

          name:
            user.name,

          email:
            user.email,

          role:
            user.role,

          avatar:
            user.avatar,

          businessProfile:
            user.businessProfile,

        },

      });

    } catch (err) {

      console.error(
        "LOGIN ERROR =>",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message,

      });
    }
  }
);

// ==========================
// RESEND OTP
// ==========================
router.post(
  '/resend-otp',
  async (req, res) => {

    try {

      const {
        email,
      } = req.body;

      // ==========================
      // FIND USER
      // ==========================

      const user =
        await User.findOne({
          email,
        });

      if (!user) {
        return res.status(404).json({

          success: false,

          message:
            'User not found',

        });
      }

      // ==========================
      // CHECK VERIFIED
      // ==========================

      if (
        user.isVerified
      ) {
        return res.status(400).json({

          success: false,

          message:
            'Email already verified',

        });
      }

      // ==========================
      // COOLDOWN
      // ==========================

      const cooldown =
        60 * 1000;

      if (
        user.lastOtpSentAt &&
        Date.now() -
          user.lastOtpSentAt <
          cooldown
      ) {

        return res.status(429).json({

          success: false,

          message:
            'Please wait before requesting another OTP',

        });
      }

      // ==========================
      // GENERATE NEW OTP
      // ==========================

      const otp =
        Math.floor(
          100000 +
          Math.random() * 900000
        ).toString();

      // ==========================
      // UPDATE OTP
      // ==========================

      user.otp =
        otp;

      user.otpExpiresAt =
        Date.now() +
        5 * 60 * 1000;

      user.lastOtpSentAt =
        Date.now();

      await user.save();

      // ==========================
      // SEND EMAIL
      // ==========================

      await sendEmail(
        user.email,
        otp
      );

      // ==========================
      // SUCCESS
      // ==========================

      return res.json({

        success: true,

        message:
          'OTP resent successfully',

      });

    } catch (err) {

      console.error(
        "RESEND OTP ERROR =>",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          'Failed to resend OTP',

        error:
          err.message,

      });
    }
  }
);

// ==========================
// GET CURRENT USER
// ==========================
router.get(
  "/me",
  protect,
  async (req, res) => {

    try {

      res.json({

        success: true,

        user:
          req.user,

      });

    } catch (err) {

      console.error(
        "GET ME ERROR:",
        err
      );

      res.status(500).json({

        success: false,

        message:
          err.message,

      });
    }
  }
);

module.exports = router;