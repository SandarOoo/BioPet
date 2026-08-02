
const express = require("express");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const { protect } = require("../middleware/auth");
const sendEmail = require("../utils/sendEmail");

const router = express.Router();

// ==================================================
// JWT TOKEN
// ==================================================
const generateToken = (id) => {
  return jwt.sign(
    { id },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE || "7d",
    }
  );
};

// ==================================================
// REGISTER
// ==================================================
router.post("/register", async (req, res) => {
  console.log("=================================");
  console.log("REGISTER HIT");
  console.log("=================================");

  const {
    name,
    email,
    password,
    phone,
    role,
    businessProfile,
  } = req.body;

  try {
    // ----------------------------------------------
    // VALIDATION
    // ----------------------------------------------
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email and password are required",
      });
    }

    // ----------------------------------------------
    // CHECK EMAIL
    // ----------------------------------------------
    const existingUser = await User.findOne({
      email: email.toLowerCase().trim(),
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Email already exists",
      });
    }

    // ----------------------------------------------
    // ADMIN REGISTRATION NOT ALLOWED
    // ----------------------------------------------
    if (role === "admin") {
      return res.status(403).json({
        success: false,
        message: "Cannot register as admin",
      });
    }

    // ----------------------------------------------
    // GENERATE OTP
    // ----------------------------------------------
    const otp = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    // ----------------------------------------------
    // CREATE USER
    // ----------------------------------------------
    const user = await User.create({
      name: name.trim(),

      email: email.toLowerCase().trim(),

      password,

      phone: phone || "",

      role: role || "user",

      // --------------------------------------------
      // BUSINESS PROFILE
      // --------------------------------------------
      businessProfile:
        role === "business_owner"
          ? {
              businessName:
                businessProfile?.businessName || "",

              businessType:
                businessProfile?.businessType || "",

              address:
                businessProfile?.address || "",

              latitude:
                businessProfile?.latitude ?? null,

              longitude:
                businessProfile?.longitude ?? null,

              description:
                businessProfile?.description || "",

              agreementAccepted: false,

              verificationStatus: "draft",

              rejectReason: "",
            }
          : {},

      // --------------------------------------------
      // EMAIL VERIFICATION
      // --------------------------------------------
      otp,

      otpExpiresAt:
        Date.now() + 5 * 60 * 1000,

      lastOtpSentAt: Date.now(),

      isVerified: false,
    });

    console.log(
      "USER CREATED:",
      user._id.toString()
    );

    // ----------------------------------------------
    // SEND OTP EMAIL
    // ----------------------------------------------
    try {
      await sendEmail(
        user.email,
        otp
      );

      console.log(
        "✅ OTP EMAIL SENT:",
        user.email
      );

    } catch (emailError) {

      console.error(
        "❌ OTP EMAIL FAILED:",
        emailError.message
      );

      // --------------------------------------------
      // DELETE USER IF EMAIL FAILED
      // --------------------------------------------
      await User.findByIdAndDelete(
        user._id
      );

      return res.status(500).json({
        success: false,
        message:
          "Unable to send verification email. Please try again.",
      });
    }

    // ----------------------------------------------
    // SUCCESS
    // ----------------------------------------------
    return res.status(201).json({
      success: true,

      message:
        "OTP sent to email. Please verify your account.",

      userId: user._id,
    });

  } catch (err) {

    console.error(
      "❌ REGISTER ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message:
        err.message ||
        "Registration failed",
    });
  }
});

// ==================================================
// VERIFY EMAIL OTP
// ==================================================
router.post(
  "/verify-email",
  async (req, res) => {

    try {

      const {
        email,
        otp,
      } = req.body;

      // --------------------------------------------
      // VALIDATION
      // --------------------------------------------
      if (!email || !otp) {
        return res.status(400).json({
          success: false,
          message:
            "Email and OTP are required",
        });
      }

      // --------------------------------------------
      // FIND USER
      // --------------------------------------------
      const user = await User.findOne({
        email: email.toLowerCase().trim(),
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      // --------------------------------------------
      // ALREADY VERIFIED
      // --------------------------------------------
      if (user.isVerified) {
        return res.status(400).json({
          success: false,
          message:
            "Email is already verified",
        });
      }

      // --------------------------------------------
      // OTP EXISTS
      // --------------------------------------------
      if (
        !user.otp ||
        !user.otpExpiresAt
      ) {
        return res.status(400).json({
          success: false,
          message:
            "No OTP found. Please request a new OTP.",
        });
      }

      // --------------------------------------------
      // OTP EXPIRED
      // --------------------------------------------
      if (
        user.otpExpiresAt.getTime
          ? user.otpExpiresAt.getTime() < Date.now()
          : user.otpExpiresAt < Date.now()
      ) {
        return res.status(400).json({
          success: false,
          message:
            "OTP expired. Please request a new OTP.",
        });
      }

      // --------------------------------------------
      // INVALID OTP
      // --------------------------------------------
      if (
        String(user.otp).trim() !==
        String(otp).trim()
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid OTP",
        });
      }

      // --------------------------------------------
      // VERIFY USER
      // --------------------------------------------
      user.isVerified = true;

      // Clear OTP
      user.otp = null;

      user.otpExpiresAt = null;

      user.lastOtpSentAt = null;

      await user.save();

      console.log(
        "✅ EMAIL VERIFIED:",
        user.email
      );

      // --------------------------------------------
      // SUCCESS
      // --------------------------------------------
      return res.json({
        success: true,

        message:
          "Email verified successfully",

        userId: user._id,
      });

    } catch (err) {

      console.error(
        "❌ VERIFY EMAIL ERROR:",
        err
      );

      return res.status(500).json({
        success: false,
        message:
          err.message ||
          "Email verification failed",
      });
    }
  }
);

// ==================================================
// LOGIN
// ==================================================
router.post(
  "/login",
  async (req, res) => {

    const {
      email,
      password,
    } = req.body;

    try {

      // --------------------------------------------
      // VALIDATION
      // --------------------------------------------
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message:
            "Email and password are required",
        });
      }

      // --------------------------------------------
      // FIND USER
      // --------------------------------------------
      const user =
        await User.findOne({
          email:
            email.toLowerCase().trim(),
        });

      // --------------------------------------------
      // CHECK PASSWORD
      // --------------------------------------------
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

      // --------------------------------------------
      // BLOCKED ACCOUNT
      // --------------------------------------------
      if (user.isBlocked) {
        return res.status(403).json({
          success: false,
          message:
            "Account blocked",
        });
      }

      // --------------------------------------------
      // EMAIL VERIFICATION
      // --------------------------------------------
      if (!user.isVerified) {
        return res.status(403).json({
          success: false,

          code:
            "NOT_VERIFIED",

          message:
            "Please verify your email first",
        });
      }

      // --------------------------------------------
      // GENERATE JWT
      // --------------------------------------------
      const token =
        generateToken(user._id);

      // --------------------------------------------
      // LOGIN SUCCESS
      // --------------------------------------------
      return res.json({
        success: true,

        token,

        user: {
          id: user._id,

          name: user.name,

          email: user.email,

          role: user.role,

          avatar: user.avatar,

          phone: user.phone,

          businessProfile:
            user.businessProfile,
        },
      });

    } catch (err) {

      console.error(
        "❌ LOGIN ERROR:",
        err
      );

      return res.status(500).json({
        success: false,
        message:
          err.message ||
          "Login failed",
      });
    }
  }
);

// ==================================================
// RESEND OTP
// ==================================================
router.post(
  "/resend-otp",
  async (req, res) => {

    try {

      const {
        email,
      } = req.body;

      // --------------------------------------------
      // VALIDATION
      // --------------------------------------------
      if (!email) {
        return res.status(400).json({
          success: false,
          message:
            "Email is required",
        });
      }

      // --------------------------------------------
      // FIND USER
      // --------------------------------------------
      const user =
        await User.findOne({
          email:
            email.toLowerCase().trim(),
        });

      if (!user) {
        return res.status(404).json({
          success: false,
          message:
            "User not found",
        });
      }

      // --------------------------------------------
      // ALREADY VERIFIED
      // --------------------------------------------
      if (user.isVerified) {
        return res.status(400).json({
          success: false,
          message:
            "Email is already verified",
        });
      }

      // --------------------------------------------
      // OTP COOLDOWN
      // 60 SECONDS
      // --------------------------------------------
      const cooldown =
        60 * 1000;

      if (
        user.lastOtpSentAt &&
        Date.now() -
          new Date(
            user.lastOtpSentAt
          ).getTime() <
          cooldown
      ) {

        const remainingSeconds =
          Math.ceil(
            (
              cooldown -
              (
                Date.now() -
                new Date(
                  user.lastOtpSentAt
                ).getTime()
              )
            ) / 1000
          );

        return res.status(429).json({
          success: false,

          message:
            `Please wait ${remainingSeconds} seconds before requesting another OTP`,
        });
      }

      // --------------------------------------------
      // GENERATE NEW OTP
      // --------------------------------------------
      const otp =
        Math.floor(
          100000 +
          Math.random() *
            900000
        ).toString();

      // --------------------------------------------
      // UPDATE OTP
      // --------------------------------------------
      user.otp = otp;

      user.otpExpiresAt =
        Date.now() +
        5 * 60 * 1000;

      user.lastOtpSentAt =
        Date.now();

      await user.save();

      // --------------------------------------------
      // SEND EMAIL
      // --------------------------------------------
      try {

        await sendEmail(
          user.email,
          otp
        );

        console.log(
          "✅ OTP RESENT:",
          user.email
        );

      } catch (emailError) {

        console.error(
          "❌ RESEND EMAIL ERROR:",
          emailError.message
        );

        // Do not delete user.
        // Restore old OTP is optional.
        return res.status(500).json({
          success: false,

          message:
            "Unable to resend OTP. Please try again.",
        });
      }

      // --------------------------------------------
      // SUCCESS
      // --------------------------------------------
      return res.json({
        success: true,

        message:
          "OTP resent successfully",
      });

    } catch (err) {

      console.error(
        "❌ RESEND OTP ERROR:",
        err
      );

      return res.status(500).json({
        success: false,

        message:
          err.message ||
          "Failed to resend OTP",
      });
    }
  }
);

// ==================================================
// GET CURRENT USER
// ==================================================
router.get(
  "/me",
  protect,
  async (req, res) => {

    try {

      return res.json({
        success: true,

        user: req.user,
      });

    } catch (err) {

      console.error(
        "❌ GET ME ERROR:",
        err
      );

      return res.status(500).json({
        success: false,

        message:
          err.message ||
          "Failed to get current user",
      });
    }
  }
);

// ==================================================
// EXPORT ROUTER
// ==================================================
module.exports = router;
