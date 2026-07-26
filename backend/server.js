require("dotenv").config({
  path: "../.env",
});

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

console.log(
  "GEMINI KEY EXISTS:",
  !!process.env.GEMINI_API_KEY
);

const { analyzePost } = require("./services/geminiService");

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
// TEST GEMINI ROUTE
// =====================================================

app.get(
  "/api/test-gemini",
  async (req, res) => {

    try {

      const result =
        await analyzePost(
          "My dog is sick and needs veterinary care."
        );

      return res.json({
        success: true,
        ai: result,
      });

    } catch (err) {

      return res.status(500).json({
        success: false,
        error: err.message,
      });

    }

  }
);

// =====================================================
// ROUTES
// =====================================================

const authRoute = require("./routes/auth");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");
const postRoutes = require("./routes/postRoutes");

// =====================================================
// API ROUTES
// =====================================================

// AUTH
app.use("/api/auth", authRoute);

// BUSINESS / PRODUCTS
app.use("/api/business", productRoutes);

// ORDERS
app.use("/api/orders", orderRoutes);

// ADMIN
app.use("/api/admin", adminRoutes);

// POSTS (feed, create post, like, comment)
app.use("/api/posts", postRoutes);

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
// MONGODB
// =====================================================

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB Connected");
    console.log(
      "Database:",
      mongoose.connection.name
    );
  })
  .catch((err) => {
    console.error(
      "❌ MongoDB Error:",
      err.message
    );
  });

// =====================================================
// HEALTH CHECK
// =====================================================

app.get(
  "/",
  (req, res) => {
    res.json({
      success: true,
      message: "BioPet API Running",
    });
  }
);

// =====================================================
// ERROR HANDLER
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
// SERVER
// =====================================================

const PORT =
  process.env.PORT ||
  3000;

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `🚀 Server running on port ${PORT}`
    );
  }
);