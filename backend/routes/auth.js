const express = require('express');
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


// ============================================================
// REGISTER
// ============================================================

 // ============================================================
 // REGISTER
 // ============================================================

 router.post('/register', async (req, res) => {
   console.log('=================================');
   console.log('REGISTER HIT');
   console.log('=================================');

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
     // Example:
     // sandar@gmail.com       ✅
     // sandar.oo@gmail.com    ✅
     // sandar_oo@gmail.com    ✅
     // sandar123@gmail.com    ✅
     //
     // Must be a valid Gmail-style address
     // ========================================================

     const cleanEmail = email.trim().toLowerCase();

     const gmailRegex =
         /^[a-zA-Z0-9._%+-]+@gmail\.com$/;

     if (!gmailRegex.test(cleanEmail)) {
       return res.status(400).json({
         success: false,
         code: 'INVALID_EMAIL',
         message: 'Please enter a valid Gmail address.',
       });
     }

     // ========================================================
     // STRONG PASSWORD
     // ========================================================
     // Minimum 8 characters
     // 1 uppercase
     // 1 lowercase
     // 1 number
     // 1 special character
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
     // ADMIN REGISTER BLOCK
     // ========================================================

     if (role === 'admin') {
       return res.status(403).json({
         success: false,
         code: 'ADMIN_REGISTER_NOT_ALLOWED',
         message: 'Cannot register as admin',
       });
     }

     // ========================================================
     // CHECK EXISTING USER
     // ========================================================

     const existingUser = await User.findOne({
       email: cleanEmail,
     });

     if (existingUser) {
       return res.status(400).json({
         success: false,
         code: 'EMAIL_EXISTS',
         message: 'Email already exists',
       });
     }

     // ========================================================
     // GENERATE OTP
     // ========================================================

     const otp =
       Math.floor(
         100000 + Math.random() * 900000
       ).toString();

     console.log('=================================');
     console.log('GENERATED OTP:', otp);
     console.log('EMAIL:', cleanEmail);
     console.log('=================================');

     // ========================================================
     // CREATE USER
     // ========================================================

     const user = await User.create({

       name: name.trim(),

       email: cleanEmail,

       password,

       phone: phone?.trim() || '',

       role: role || 'user',

       businessProfile:
         role === 'business_owner'
           ? {
               businessName:
                 businessProfile?.businessName?.trim() || '',

               businessType:
                 businessProfile?.businessType || '',

               address:
                 businessProfile?.address?.trim() || '',

               latitude:
                 businessProfile?.latitude ?? null,

               longitude:
                 businessProfile?.longitude ?? null,

               description:
                 businessProfile?.description?.trim() || '',

               agreementAccepted: false,

               verificationStatus: 'draft',

               rejectReason: '',
             }
           : {},

       // ======================================================
       // OTP SAVED TO DATABASE
       // ======================================================

       otp: otp,

       otpExpiresAt:
         Date.now() + 5 * 60 * 1000,

       lastOtpSentAt:
         Date.now(),

       isVerified: false,
     });

     console.log(
       '✅ USER CREATED:',
       user._id
     );

     // ========================================================
     // NO EMAIL SENDING
     // ========================================================
     // OTP is returned directly to Flutter.
     // Flutter can display it on Verify Email page.
     // ========================================================

     return res.status(201).json({

       success: true,

       message:
         'Registration successful. Please verify your account.',

       userId:
         user._id,

       email:
         user.email,

       // DEMO / PROJECT OTP
       otp:
         otp,

     });

   } catch (err) {

     console.error(
       '❌ REGISTER ERROR:',
       err
     );

     return res.status(500).json({

       success: false,

       message:
         err.message ||
         'Registration failed',

     });
   }
 });


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