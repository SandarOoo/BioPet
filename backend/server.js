require("dotenv").config({
  path: "../.env",
});

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const authRoute = require("./routes/auth");
const classifyRoute = require("./routes/classifyRoute");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");
const postRoutes = require("./routes/postRoutes");
const businessRoutes = require("./routes/businessRoutes");

const app = express();

const PORT = process.env.PORT || 3000;

// ===============================
// MIDDLEWARE
// ===============================

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

// ===============================
// ENV CHECK
// ===============================

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

// ===============================
// HEALTH CHECK
// ===============================

app.get("/", (req, res) => {
  console.log("HEALTH CHECK HIT");

  res.status(200).json({
    success: true,
    message: "🐶 BioPet API Running",
  });
});

// ===============================
// API ROUTES
// ===============================

app.use(
  "/api/auth",
  authRoute
);

app.use(
  "/api/classify",
  classifyRoute
);

app.use(
  "/api/business",
  productRoutes
);
app.use(
  "/api/business",
  businessRoutes
);

app.use(
  "/api/orders",
  orderRoutes
);

app.use(
  "/api/admin",
  adminRoutes
);

app.use(
  "/api/posts",
  postRoutes
);

// ===============================
// 404
// ===============================

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
    path: req.originalUrl,
  });
});

// ===============================
// GLOBAL ERROR
// ===============================

app.use((err, req, res, next) => {
  console.error("GLOBAL ERROR:", err);

  res.status(500).json({
    success: false,
    message:
      err.message ||
      "Server error",
  });
});

// ===============================
// START SERVER
// ===============================

const startServer = async () => {
  try {

    if (!process.env.MONGO_URI) {
      throw new Error(
        "MONGO_URI is missing"
      );
    }

    await mongoose.connect(
      process.env.MONGO_URI
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

      }
    );

  } catch (error) {

    console.error(
      "❌ SERVER START ERROR:",
      error
    );

    process.exit(1);
  }
};

startServer();