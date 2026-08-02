// =====================================================
// ENV
// =====================================================

require("dotenv").config({
  path: "../.env",
});

// =====================================================
// IMPORTS
// =====================================================

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

// =====================================================
// ROUTES
// =====================================================

const authRoute = require("./routes/auth");
const classifyRoute = require("./routes/classifyRoute");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");
const postRoutes = require("./routes/postRoutes");

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
// REQUEST LOGGER
// =====================================================

app.use((req, res, next) => {
  console.log(
    `${new Date().toISOString()} ${req.method} ${req.originalUrl}`
  );

  next();
});

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
  "BREVO KEY EXISTS:",
  !!process.env.BREVO_API_KEY
);

// =====================================================
// HEALTH CHECK
// =====================================================

app.get("/", (req, res) => {
  console.log("🏥 HEALTH CHECK");

  res.status(200).json({
    success: true,
    message: "🐶 BioPet API Running",
  });
});

// =====================================================
// API ROUTES
// =====================================================

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

// POSTS / NEWS FEED
app.use(
  "/api/posts",
  postRoutes
);

// =====================================================
// 404 HANDLER
// =====================================================

app.use((req, res) => {
  console.log(
    "❌ ROUTE NOT FOUND:",
    req.method,
    req.originalUrl
  );

  res.status(404).json({
    success: false,
    message: "Route not found",
    path: req.originalUrl,
  });
});

// =====================================================
// GLOBAL ERROR
// =====================================================

app.use((err, req, res, next) => {
  console.error("=================================");
  console.error("❌ GLOBAL ERROR");
  console.error(err);
  console.error("=================================");

  res.status(500).json({
    success: false,
    message:
      err.message ||
      "Server error",
  });
});

// =====================================================
// MONGODB + SERVER
// =====================================================

const PORT =
  process.env.PORT ||
  3000;

const startServer = async () => {
  try {

    console.log(
      "🔌 Connecting to MongoDB..."
    );

    await mongoose.connect(
      process.env.MONGO_URI,
      {
        serverSelectionTimeoutMS: 10000,
      }
    );

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

        console.log(
          `🌐 Port: ${PORT}`
        );

      }
    );

  } catch (error) {

    console.error(
      "❌ SERVER STARTUP ERROR:"
    );

    console.error(
      error
    );

    process.exit(1);
  }
};

startServer();