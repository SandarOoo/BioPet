
const express = require("express");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { protect } = require("../middleware/auth");
const supabase = require("../utils/supabase");

const router = express.Router();

// =====================================================
// JWT TOKEN
// =====================================================

const generateToken = (id) =>
  jwt.sign(
    { id },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE,
    }
  );

// =====================================================
// REGISTER
// POST /api/auth/register
// =====================================================

router.post("/register", async (req, res) => {

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

    // =================================================
    // VALIDATE INPUT
    // =================================================

    if (
      !name ||
      !email ||
      !password
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Name, email and password are required",
      });
    }

    const cleanEmail =
      email.trim().toLowerCase();

    // =================================================
    // PREVENT ADMIN REGISTER
    // =================================================

    if (role === "admin") {
      return res.status(403).json({
        success: false,
        message:
          "Cannot register as admin",
      });
    }

    // =================================================
    // CHECK MONGODB USER
    // =================================================

    const existingUser =
      await User.findOne({
        email: cleanEmail,
      });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message:
          "Email already exists",
      });
    }

    // =================================================
    // CREATE SUPABASE AUTH USER
    // =================================================

    console.log(
      "CREATING SUPABASE USER..."
    );

    const {
      data: supabaseData,
      error: supabaseError,
    } =
      await supabase.auth.admin.createUser({

        email: cleanEmail,

        password: password,

        email_confirm: false,

        user_metadata: {
          name: name,
          phone: phone || "",
          role: role || "user",
        },

      });

    if (supabaseError) {

      console.error(
        "SUPABASE CREATE USER ERROR =>",
        supabaseError
      );

      return res.status(400).json({
        success: false,
        message:
          "Supabase registration failed",
        error:
          supabaseError.message,
      });

    }

    console.log(
      "SUPABASE USER CREATED =>",
      supabaseData.user.id
    );

    // =================================================
    // SEND SUPABASE VERIFICATION EMAIL
    // =================================================

    console.log(
      "SENDING SUPABASE VERIFICATION EMAIL..."
    );

    const {
      error: emailError,
    } =
      await supabase.auth.resend({
        type: "signup",
        email: cleanEmail,
        options: {
          emailRedirectTo:
            process.env.SUPABASE_REDIRECT_URL,
        },
      });

    if (emailError) {

      console.error(
        "SUPABASE EMAIL ERROR =>",
        emailError
      );

      // Delete Supabase account
      // if email sending fails

      await supabase.auth.admin.deleteUser(
        supabaseData.user.id
      );

      return res.status(500).json({
        success: false,
        message:
          "Unable to send verification email",
        error:
          emailError.message,
      });

    }

    console.log(
      "✅ SUPABASE VERIFICATION EMAIL SENT"
    );

    // =================================================
    // CREATE MONGODB USER
    // =================================================

    const user =
      await User.create({

        name: name,

        email: cleanEmail,

        password: password,

        phone: phone,

        role:
          role || "user",

        businessProfile:
          role === "business_owner"
            ? {

                businessName:
                  businessProfile?.businessName ||
                  "",

                businessType:
                  businessProfile?.businessType ||
                  "",

                address:
                  businessProfile?.address ||
                  "",

                latitude:
                  businessProfile?.latitude ||
                  null,

                longitude:
                  businessProfile?.longitude ||
                  null,

                description:
                  businessProfile?.description ||
                  "",

                agreementAccepted:
                  false,

                verificationStatus:
                  "draft",

                rejectReason:
                  "",

              }
            : {},

        // Email verification status
        isVerified: false,

        // Supabase User ID
        supabaseUserId:
          supabaseData.user.id,

      });

    console.log(
      "MONGODB USER CREATED =>",
      user._id
    );

    // =================================================
    // SUCCESS
    // =================================================

    return res.status(201).json({

      success: true,

      message:
        "Registration successful. Please check your email and click the verification link.",

      userId:
        user._id,

      supabaseUserId:
        supabaseData.user.id,

    });

  } catch (err) {

    console.error(
      "❌ REGISTER ERROR =>",
      err
    );

    return res.status(500).json({

      success: false,

      message:
        "Registration failed",

      error:
        err.message,

    });

  }

});

// =====================================================
// VERIFY EMAIL
// GET /api/auth/verify-email
// =====================================================

router.get(
  "/verify-email",
  async (req, res) => {

    try {

      const {
        email,
      } = req.query;

      console.log(
        "================================="
      );

      console.log(
        "VERIFY EMAIL REQUEST"
      );

      console.log(
        "EMAIL =>",
        email
      );

      // =================================================
      // VALIDATE EMAIL
      // =================================================

      if (!email) {

        return res.status(400).json({

          success: false,

          message:
            "Email is missing",

        });

      }

      const cleanEmail =
        email.trim().toLowerCase();

      // =================================================
      // FIND USER
      // =================================================

      const user =
        await User.findOne({

          email:
            cleanEmail,

        });

      if (!user) {

        return res.status(404).json({

          success: false,

          message:
            "User not found",

        });

      }

      // =================================================
      // ALREADY VERIFIED
      // =================================================

      if (user.isVerified) {

        return res.json({

          success: true,

          message:
            "Email is already verified",

        });

      }

      // =================================================
      // UPDATE MONGODB
      // =================================================

      user.isVerified =
        true;

      await user.save();

      console.log(
        "✅ EMAIL VERIFIED"
      );

      console.log(
        "USER =>",
        user.email
      );

      // =================================================
      // SUCCESS
      // =================================================

      return res.json({

        success: true,

        message:
          "Email verified successfully. You can now login.",

      });

    } catch (err) {

      console.error(
        "❌ VERIFY EMAIL ERROR =>",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          "Email verification failed",

        error:
          err.message,

      });

    }

  }
);

// =====================================================
// LOGIN
// POST /api/auth/login
// =====================================================

router.post(
  "/login",
  async (req, res) => {

    const {
      email,
      password,
    } = req.body;

    try {

      const cleanEmail =
        email.trim().toLowerCase();

      // =================================================
      // FIND USER
      // =================================================

      const user =
        await User.findOne({

          email:
            cleanEmail,

        });

      // =================================================
      // CHECK CREDENTIALS
      // =================================================

      if (
        !user ||
        !(await user.matchPassword(password))
      ) {

        return res.status(401).json({

          success: false,

          message:
            "Invalid credentials",

        });

      }

      // =================================================
      // CHECK BLOCKED
      // =================================================

      if (
        user.isBlocked
      ) {

        return res.status(403).json({

          success: false,

          message:
            "Account blocked",

        });

      }

      // =================================================
      // CHECK EMAIL VERIFICATION
      // =================================================

      if (
        !user.isVerified
      ) {

        return res.status(403).json({

          success: false,

          code:
            "NOT_VERIFIED",

          message:
            "Please verify your email first",

        });

      }

      // =================================================
      // LOGIN SUCCESS
      // =================================================

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
        "❌ LOGIN ERROR =>",
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

// =====================================================
// RESEND VERIFICATION EMAIL
// POST /api/auth/resend-otp
// =====================================================
//
// NOTE:
// This route name is kept as /resend-otp so your existing
// Flutter code does not need to change immediately.
// It now resends a Supabase verification email instead
// of sending an OTP.
// =====================================================

router.post(
  "/resend-otp",
  async (req, res) => {

    try {

      const {
        email,
      } = req.body;

      // =================================================
      // VALIDATE EMAIL
      // =================================================

      if (!email) {

        return res.status(400).json({

          success: false,

          message:
            "Email is required",

        });

      }

      const cleanEmail =
        email.trim().toLowerCase();

      // =================================================
      // FIND MONGODB USER
      // =================================================

      const user =
        await User.findOne({

          email:
            cleanEmail,

        });

      if (!user) {

        return res.status(404).json({

          success: false,

          message:
            "User not found",

        });

      }

      // =================================================
      // CHECK VERIFIED
      // =================================================

      if (
        user.isVerified
      ) {

        return res.status(400).json({

          success: false,

          message:
            "Email already verified",

        });

      }

      // =================================================
      // RESEND SUPABASE EMAIL
      // =================================================

      console.log(
        "RESENDING SUPABASE VERIFICATION EMAIL..."
      );

      const {
        error,
      } =
        await supabase.auth.resend({

          type:
            "signup",

          email:
            cleanEmail,

          options: {

            emailRedirectTo:
              process.env.SUPABASE_REDIRECT_URL,

          },

        });

      if (error) {

        console.error(
          "RESEND EMAIL ERROR =>",
          error
        );

        return res.status(500).json({

          success: false,

          message:
            "Failed to resend verification email",

          error:
            error.message,

        });

      }

      console.log(
        "✅ VERIFICATION EMAIL RESENT"
      );

      // =================================================
      // SUCCESS
      // =================================================

      return res.json({

        success: true,

        message:
          "Verification email resent successfully",

      });

    } catch (err) {

      console.error(
        "❌ RESEND VERIFICATION ERROR =>",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          "Failed to resend verification email",

        error:
          err.message,

      });

    }

  }
);

// =====================================================
// GET CURRENT USER
// GET /api/auth/me
// =====================================================

router.get(
  "/me",
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
        "GET ME ERROR =>",
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

// =====================================================
// EXPORT
// =====================================================

module.exports = router;
