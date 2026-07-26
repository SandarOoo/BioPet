// =====================================================
// ENV
// =====================================================

require("dotenv").config({
  path: "../.env",
});

console.log(
  "GEMINI KEY EXISTS:",
  !!process.env.GEMINI_API_KEY
);


// =====================================================
// IMPORTS
// =====================================================

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

// =====================================================
// ROUTES
// =====================================================

const geminiRoute = require("./routes/geminiRoute");
const testGeminiRoute = require("./routes/testGeminiRoute");

const authRoute = require("./routes/auth");
const classifyRoute = require("./routes/classifyRoute");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");
const postRoutes = require("./routes/postRoutes");

// =====================================================
// GEMINI SERVICE
// =====================================================

const {
  analyzePost,
} = require("./services/geminiService");


// =====================================================
// APP
// =====================================================

const app = express();


// =====================================================
// MIDDLEWARE
// =====================================================

app.use(cors());

app.use(
  express.json({
    limit: "20mb",
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "20mb",
  })
);


// =====================================================
// ENV CHECK
// =====================================================

console.log("=================================");
console.log("ENVIRONMENT CHECK");
console.log("=================================");

console.log(
  "MONGO_URI EXISTS:",
  !!process.env.MONGO_URI
);

console.log(
  "JWT_SECRET EXISTS:",
  !!process.env.JWT_SECRET
);

console.log(
  "JWT_EXPIRE:",
  process.env.JWT_EXPIRE
);

console.log(
  "GEMINI KEY EXISTS:",
  !!process.env.GEMINI_API_KEY
);

console.log(
  "BREVO KEY EXISTS:",
  !!process.env.BREVO_API_KEY
);


// =====================================================
// REGISTER ROUTES
// =====================================================

// GEMINI
app.use(
  "/api/gemini",
  geminiRoute
);

// TEST GEMINI
app.use(
  "/api",
  testGeminiRoute
);

// AUTH
app.use(
  "/api/auth",
  authRoute
);

// CLASSIFICATION / HISTORY
app.use(
  "/api/classify",
  classifyRoute
);

// BUSINESS / PRODUCTS
app.use(
  "/api/business",
  productRoutes
);

// ORDERS
app.use(
  "/api/orders",
  orderRoutes
);

// ADMIN
app.use(
  "/api/admin",
  adminRoutes
);

// NEWS FEED
app.use(
  "/api/posts",
  postRoutes
);


// =====================================================
// TEST GEMINI
// =====================================================

app.get(
  "/api/test-gemini",
  async (req, res) => {

    try {

      console.log(
        "🤖 TESTING GEMINI..."
      );

      const result =
        await analyzePost(
          "My dog is sick and needs veterinary care."
        );

      console.log(
        "🤖 GEMINI RESULT:",
        result
      );

      return res.json({
        success: true,
        ai: result,
      });

    } catch (error) {

      console.error(
        "❌ GEMINI ERROR:",
        error
      );

      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
);


// =====================================================
// HEALTH CHECK
// =====================================================

app.get(
  "/",
  (req, res) => {

    res.json({
      success: true,
      message: "🐶 BioPet API Running",
    });

  }
);


// =====================================================
// GLOBAL ERROR
// =====================================================

app.use(
  (err, req, res, next) => {

    console.error(
      "GLOBAL ERROR:",
      err
    );

    res.status(500).json({
      success: false,
      message:
        err.message ||
        "Server error",
    });

  }
);


// =====================================================
// MONGODB + SERVER
// =====================================================

const PORT =
  process.env.PORT ||
  3000;

mongoose
  .connect(
    process.env.MONGO_URI
  )
  .then(() => {

    console.log(
      "✅ MongoDB Connected"
    );

    console.log(
      "Database:",
      mongoose.connection.name
    );

    app.listen(
      PORT,
      "0.0.0.0",
      () => {

        console.log(
          `🚀 Server running on port ${PORT}`
        );

      }
    );

  })
  .catch(
    (error) => {

      console.error(
        "❌ MongoDB Error:",
        error.message
      );

    }
  );