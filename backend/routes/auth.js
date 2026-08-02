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

```
// =================================================
// VALIDATION
// =================================================

if (!name || !name.trim()) {
  return res.status(400).json({
    success: false,
    message: "Name is required",
  });
}

if (!email || !email.trim()) {
  return res.status(400).json({
    success: false,
    message: "Email is required",
  });
}

if (!password || password.length < 6) {
  return res.status(400).json({
    success: false,
    message:
      "Password must be at least 6 characters",
  });
}

// =================================================
// PREVENT ADMIN REGISTER
// =================================================

if (role === "admin") {
  return res.status(403).json({
    success: false,
    message: "Cannot register as admin",
  });
}

// =================================================
// CHECK MONGODB USER
// =================================================

const existingUser =
  await User.findOne({
    email: email.trim().toLowerCase(),
  });

if (existingUser) {

  return res.status(400).json({
    success: false,
    message: "Email already exists",
  });

}

// =================================================
// CREATE SUPABASE AUTH USER
// =================================================

console.log(
  "CREATING SUPABASE AUTH USER..."
);

const {
  data: supabaseData,
  error: supabaseError,
} =
  await supabase.auth.signUp({

    email:
      email.trim().toLowerCase(),

    password:
      password,

    options: {

      emailRedirectTo:
        process.env.SUPABASE_REDIRECT_URL,

      data: {

        name:
          name.trim(),

        phone:
          phone || "",

        role:
          role || "user",

      },

    },

  });

// =================================================
// SUPABASE ERROR
// =================================================

if (supabaseError) {

  console.error(
    "SUPABASE SIGNUP ERROR =>",
    supabaseError
  );

  return res.status(400).json({

    success: false,

    message:
      supabaseError.message,

  });

}

// =================================================
// CHECK SUPABASE USER
// =================================================

const supabaseUser =
  supabaseData?.user;

if (!supabaseUser) {

  return res.status(400).json({

    success: false,

    message:
      "Failed to create Supabase user",

  });

}

console.log(
  "SUPABASE USER CREATED =>",
  supabaseUser.id
);

// =================================================
// CREATE MONGODB USER
// =================================================

const user =
  await User.create({

    name:
      name.trim(),

    email:
      email.trim().toLowerCase(),

    password,

    phone,

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
              businessProfile?.latitude ??
              null,

            longitude:
              businessProfile?.longitude ??
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

    // =================================================
    // EMAIL NOT VERIFIED YET
    // =================================================

    isVerified:
      false,

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
    supabaseUser.id,

});
```

} catch (err) {

```
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
```

}

});

// =====================================================
// VERIFY EMAIL
// GET /api/auth/verify-email
//
// This endpoint is called after the user returns
// from Supabase verification.
// =====================================================

router.get(
"/verify-email",
async (req, res) => {

```
try {

  const {
    email,
  } = req.query;

  if (!email) {

    return res.status(400).send(`
      <h2>Email verification failed</h2>
      <p>Email is missing.</p>
    `);

  }

  // =================================================
  // FIND MONGODB USER
  // =================================================

  const user =
    await User.findOne({
      email:
        email.trim().toLowerCase(),
    });

  if (!user) {

    return res.status(404).send(`
      <h2>User not found</h2>
      <p>No BioPet account was found for this email.</p>
    `);

  }

  // =================================================
  // ALREADY VERIFIED
  // =================================================

  if (user.isVerified) {

    return res.send(`
      <h2>Email already verified</h2>
      <p>Your BioPet account is already verified.</p>
      <p>You can now open the BioPet app and login.</p>
    `);

  }

  // =================================================
  // UPDATE MONGODB
  // =================================================

  user.isVerified =
    true;

  await user.save();

  console.log(
    "EMAIL VERIFIED =>",
    user.email
  );

  // =================================================
  // SUCCESS
  // =================================================

  return res.send(`
    <!DOCTYPE html>
    <html>

    <head>

      <title>BioPet Email Verification</title>

      <meta
        name="viewport"
        content="width=device-width, initial-scale=1"
      />

    </head>

    <body
      style="
        font-family: Arial;
        text-align: center;
        padding: 50px;
      "
    >

      <h1>
        ✅ Email Verified Successfully
      </h1>

      <p>
        Your BioPet account has been verified.
      </p>

      <p>
        You can now open the BioPet app and login.
      </p>

    </body>

    </html>
  `);

} catch (err) {

  console.error(
    "VERIFY EMAIL ERROR =>",
    err
  );

  return res.status(500).send(`
    <h2>Verification failed</h2>
    <p>${err.message}</p>
  `);

}
```

}
);

// =====================================================
// LOGIN
// POST /api/auth/login
// =====================================================

router.post(
"/login",
async (req, res) => {

```
const {
  email,
  password,
} = req.body;

try {

  // =================================================
  // FIND USER
  // =================================================

  const user =
    await User.findOne({
      email:
        email.trim().toLowerCase(),
    });

  // =================================================
  // CHECK PASSWORD
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
    "LOGIN ERROR =>",
    err
  );

  return res.status(500).json({

    success: false,

    message:
      err.message,

  });

}
```

}
);

// =====================================================
// CHECK EMAIL VERIFICATION
// POST /api/auth/check-verification
//
// This can be called by Flutter after user clicks
// the Supabase verification link.
// =====================================================

router.post(
"/check-verification",
async (req, res) => {

```
try {

  const {
    email,
  } = req.body;

  if (!email) {

    return res.status(400).json({

      success: false,

      message:
        "Email is required",

    });

  }

  // =================================================
  // GET SUPABASE USER
  // =================================================

  const {
    data,
    error,
  } =
    await supabase.auth.admin
      .listUsers();

  if (error) {

    return res.status(500).json({

      success: false,

      message:
        error.message,

    });

  }

  // =================================================
  // FIND SUPABASE USER
  // =================================================

  const supabaseUser =
    data.users.find(
      (u) =>
        u.email?.toLowerCase() ===
        email.trim().toLowerCase()
    );

  if (!supabaseUser) {

    return res.status(404).json({

      success: false,

      message:
        "Supabase user not found",

    });

  }

  // =================================================
  // CHECK CONFIRMATION
  // =================================================

  if (
    !supabaseUser.email_confirmed_at
  ) {

    return res.json({

      success: false,

      verified: false,

      message:
        "Email is not verified yet",

    });

  }

  // =================================================
  // FIND MONGODB USER
  // =================================================

  const user =
    await User.findOne({
      email:
        email.trim().toLowerCase(),
    });

  if (!user) {

    return res.status(404).json({

      success: false,

      message:
        "MongoDB user not found",

    });

  }

  // =================================================
  // UPDATE MONGODB
  // =================================================

  user.isVerified =
    true;

  await user.save();

  // =================================================
  // SUCCESS
  // =================================================

  return res.json({

    success: true,

    verified: true,

    message:
      "Email verified successfully",

  });

} catch (err) {

  console.error(
    "CHECK VERIFICATION ERROR =>",
    err
  );

  return res.status(500).json({

    success: false,

    message:
      err.message,

  });

}
```

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

```
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
```

}
);

module.exports = router;
