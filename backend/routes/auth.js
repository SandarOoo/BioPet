const express = require('express');
const multer = require('multer');

const upload = multer({
  storage: multer.memoryStorage(),
});
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const sendEmail = require('../utils/sendEmail');

const router = express.Router();

// ============================================================
// JWT TOKEN
// ============================================================

const generateToken = (id) =>
  jwt.sign(
    { id },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE,
    }
  );

router.post(
  '/register',
  upload.single('nrcCardPhoto'),
  async (req, res) => {

    console.log('=================================');
    console.log('REGISTER HIT');
    console.log('=================================');

    console.log('BODY =>', req.body);
    console.log('FILE =>', req.file ? req.file.originalname : 'NO FILE');

    const {
      name,
      email,
      password,
      phone,
      role,
      businessProfile,
    } = req.body;

    try {

      // ========================================================
      // PARSE BUSINESS PROFILE
      // ========================================================

      let parsedBusinessProfile = {};

      if (businessProfile) {
        try {
          parsedBusinessProfile =
            typeof businessProfile === 'string'
              ? JSON.parse(businessProfile)
              : businessProfile;
        } catch (error) {
          return res.status(400).json({
            success: false,
            code: 'INVALID_BUSINESS_PROFILE',
            message: 'Invalid business profile data',
          });
        }
      }

      // ========================================================
      // BASIC VALIDATION
      // ========================================================

      if (!name || !name.trim()) {
        return res.status(400).json({
          success: false,
          code: 'INVALID_NAME',
          message: 'Name is required',
        });
      }

      if (!email || !email.trim()) {
        return res.status(400).json({
          success: false,
          code: 'INVALID_EMAIL',
          message: 'Email is required',
        });
      }

      if (!password) {
        return res.status(400).json({
          success: false,
          code: 'INVALID_PASSWORD',
          message: 'Password is required',
        });
      }

      // ========================================================
      // EMAIL FORMAT
      // ========================================================

      const cleanEmail =
        email.trim().toLowerCase();

      const gmailRegex =
        /^(?=.*[a-z])(?=.*\d)[a-z0-9._%+-]+@gmail\.com$/;

      if (!gmailRegex.test(cleanEmail)) {
        return res.status(400).json({
          success: false,
          code: 'INVALID_EMAIL',
          message:
            'Please enter a valid Gmail address.',
        });
      }

      // ========================================================
      // STRONG PASSWORD
      // ========================================================

      const strongPasswordRegex =
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{8,}$/;

      if (!strongPasswordRegex.test(password)) {
        return res.status(400).json({
          success: false,
          code: 'WEAK_PASSWORD',
          message:
            'Password must be at least 8 characters and contain uppercase, lowercase, number, and special character.',
        });
      }

      // ========================================================
      // SHOP OWNER VALIDATION
      // ========================================================

      if (role === 'business_owner') {

        // ======================================================
        // PHONE REQUIRED
        // ======================================================

        if (!phone || !phone.trim()) {
          return res.status(400).json({
            success: false,
            code: 'PHONE_REQUIRED',
            message:
              'Phone number is required for shop owner registration.',
          });
        }

        // ======================================================
        // MYANMAR PHONE FORMAT
        // ======================================================

        const cleanPhone =
          phone.trim();

        const phoneRegex =
          /^09\d{9}$/;

        if (!phoneRegex.test(cleanPhone)) {
          return res.status(400).json({
            success: false,
            code: 'INVALID_PHONE',
            message:
              'Please enter a valid Myanmar phone number starting with 09.',
          });
        }

        // ======================================================
        // NRC PHOTO REQUIRED
        // ======================================================

        if (!req.file) {
          return res.status(400).json({
            success: false,
            code: 'NRC_PHOTO_REQUIRED',
            message:
              'NRC card photo is required for shop owner registration.',
          });
        }
      }

      // ========================================================
      // ADMIN REGISTER BLOCK
      // ========================================================

      if (role === 'admin') {
        return res.status(403).json({
          success: false,
          code: 'ADMIN_REGISTER_NOT_ALLOWED',
          message:
            'Cannot register as admin',
        });
      }

      // ========================================================
      // CHECK EXISTING USER
      // ========================================================

      const existingUser =
        await User.findOne({
          email: cleanEmail,
        });

      if (existingUser) {
        return res.status(400).json({
          success: false,
          code: 'EMAIL_EXISTS',
          message:
            'Email already exists',
        });
      }

      // ========================================================
      // GENERATE OTP
      // ========================================================

      const otp =
        Math.floor(
          100000 +
          Math.random() * 900000
        ).toString();

      console.log('=================================');
      console.log('GENERATED OTP:', otp);
      console.log('EMAIL:', cleanEmail);
      console.log('=================================');

      // ========================================================
      // NRC PHOTO
      // ========================================================

      let nrcCardPhoto = '';

      if (req.file) {

        nrcCardPhoto =
          `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;

        console.log(
          'NRC PHOTO SAVED',
          req.file.originalname
        );
      }

      // ========================================================
      // CREATE USER
      // ========================================================

      const user =
        await User.create({

          name:
            name.trim(),

          email:
            cleanEmail,

          password,

          phone:
            phone?.trim() || '',

          role:
            role || 'user',

          businessProfile:
            role === 'business_owner'
              ? {

                  businessName:
                    parsedBusinessProfile
                      ?.businessName
                      ?.trim() || '',

                  businessType:
                    parsedBusinessProfile
                      ?.businessType || '',

                  address:
                    parsedBusinessProfile
                      ?.address
                      ?.trim() || '',

                  latitude:
                    parsedBusinessProfile
                      ?.latitude ?? null,

                  longitude:
                    parsedBusinessProfile
                      ?.longitude ?? null,

                  description:
                    parsedBusinessProfile
                      ?.description
                      ?.trim() || '',

                  nrcCardPhoto:
                    nrcCardPhoto,

                  agreementAccepted:
                    false,

                  verificationStatus:
                    'draft',

                  rejectReason:
                    '',
                }

              : {},

          // ======================================================
          // OTP
          // ======================================================

          otp:
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
        '✅ USER CREATED:',
        user._id
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      return res.status(201).json({

        success:
          true,

        message:
          'Registration successful. Please verify your account.',

        userId:
          user._id,

        email:
          user.email,

        otp:
          otp,
      });

    } catch (err) {

      console.error(
        '❌ REGISTER ERROR:',
        err
      );

      return res.status(500).json({

        success:
          false,

        message:
          err.message ||
          'Registration failed',

      });
    }
  }
);


// ============================================================
// VERIFY EMAIL
// ============================================================

router.post(
  '/verify-email',
  async (req, res) => {

    try {

      const {
        email,
        otp,
      } = req.body;


      // ======================================================
      // CLEAN EMAIL
      // ======================================================

      const cleanEmail =
        email?.trim().toLowerCase();


      // ======================================================
      // FIND USER
      // ======================================================

      const user =
        await User.findOne({
          email: cleanEmail,
        });


      if (!user) {

        return res.status(404).json({
          success: false,
          message:
            'User not found',
        });
      }


      // ======================================================
      // CHECK ALREADY VERIFIED
      // ======================================================

      if (user.isVerified) {

        return res.status(400).json({
          success: false,
          message:
            'Already verified',
        });
      }


      // ======================================================
      // CHECK OTP
      // ======================================================

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


      // ======================================================
      // CHECK OTP VALUE
      // ======================================================

      if (user.otp !== otp) {

        return res.status(400).json({
          success: false,
          message:
            'Invalid OTP',
        });
      }


      // ======================================================
      // CHECK OTP EXPIRY
      // ======================================================

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


      // ======================================================
      // VERIFY USER
      // ======================================================

      user.isVerified =
        true;

      user.otp =
        null;

      user.otpExpiresAt =
        null;

      user.lastOtpSentAt =
        null;


      await user.save();


      // ======================================================
      // SUCCESS
      // ======================================================

      return res.json({

        success: true,

        message:
          'Email verified successfully',

      });


    } catch (err) {

      console.error(
        '❌ VERIFY EMAIL ERROR:',
        err
      );

      return res.status(500).json({
        success: false,
        message:
          err.message ||
          'Email verification failed',
      });
    }
  }
);


// ============================================================
// LOGIN
// ============================================================

router.post(
  '/login',
  async (req, res) => {

    const {
      email,
      password,
    } = req.body;


    try {

      // ======================================================
      // CLEAN EMAIL
      // ======================================================

      const cleanEmail =
        email?.trim().toLowerCase();


      // ======================================================
      // FIND USER
      // ======================================================

      const user =
        await User.findOne({
          email: cleanEmail,
        });


      // ======================================================
      // CHECK LOGIN
      // ======================================================

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


      // ======================================================
      // CHECK BLOCKED
      // ======================================================

      if (user.isBlocked) {

        return res.status(403).json({
          success: false,
          message:
            'Account blocked',
        });
      }


      // ======================================================
      // CHECK EMAIL VERIFIED
      // ======================================================

      if (!user.isVerified) {

        return res.status(403).json({

          success: false,

          code:
            'NOT_VERIFIED',

          message:
            'Please verify your email first',

        });
      }


      // ======================================================
      // LOGIN SUCCESS
      // ======================================================

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
        '❌ LOGIN ERROR:',
        err
      );

      return res.status(500).json({
        success: false,
        message:
          err.message ||
          'Login failed',
      });
    }
  }
);


// ============================================================
// RESEND OTP
// ============================================================

router.post(
  '/resend-otp',
  async (req, res) => {

    try {

      const {
        email,
      } = req.body;


      // ======================================================
      // CLEAN EMAIL
      // ======================================================

      const cleanEmail =
        email?.trim().toLowerCase();


      // ======================================================
      // FIND USER
      // ======================================================

      const user =
        await User.findOne({
          email: cleanEmail,
        });


      if (!user) {

        return res.status(404).json({
          success: false,
          message:
            'User not found',
        });
      }


      // ======================================================
      // CHECK VERIFIED
      // ======================================================

      if (user.isVerified) {

        return res.status(400).json({
          success: false,
          message:
            'Email already verified',
        });
      }


      // ======================================================
      // OTP COOLDOWN
      // ======================================================

      const cooldown =
        60 * 1000;


      if (
        user.lastOtpSentAt &&
        Date.now() -
          user.lastOtpSentAt <
          cooldown
      ) {

        const remaining =
          Math.ceil(
            (
              cooldown -
              (
                Date.now() -
                user.lastOtpSentAt
              )
            ) / 1000
          );


        return res.status(429).json({

          success: false,

          message:
            `Please wait ${remaining} seconds before requesting another OTP`,

        });
      }


      // ======================================================
      // GENERATE NEW OTP
      // ======================================================

      const otp =
        Math.floor(
          100000 +
          Math.random() * 900000
        ).toString();


      // ======================================================
      // UPDATE OTP
      // ======================================================

      user.otp =
        otp;

      user.otpExpiresAt =
        Date.now() +
        5 * 60 * 1000;

      user.lastOtpSentAt =
        Date.now();


      await user.save();


      // ======================================================
      // SEND OTP
      // ======================================================

      await sendEmail(
        user.email,
        otp
      );


      console.log(
        '✅ OTP RESENT TO:',
        user.email
      );


      // ======================================================
      // SUCCESS
      // ======================================================

      return res.json({

        success: true,

        message:
          'OTP resent successfully',

      });


    } catch (err) {

      console.error(
        '❌ RESEND OTP ERROR:',
        err
      );

      return res.status(500).json({
        success: false,
        message:
          err.message ||
          'Unable to resend OTP',
      });
    }
  }
);


// ============================================================
// GET CURRENT USER
// ============================================================

router.get(
  '/me',
  protect,
  async (req, res) => {

    try {

      return res.json({

        success: true,

        user:
          req.user,

      });

    } catch (err) {

      console.error(
        '❌ GET ME ERROR:',
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message ||
          'Unable to get current user',

      });
    }
  }
);


module.exports = router;