
require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

// ===============================
// ROUTES
// ===============================
const authRoute = require("./routes/auth");
const classifyRoute = require("./routes/classifyRoute");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");
const postRoutes = require("./routes/postRoutes");

const app = express();

// Railway provides PORT automatically
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
// ENVIRONMENT CHECK
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
  process.env.JWT_EXPIRE || "7d"
);

console.log(
  "BREVO KEY EXISTS:",
  !!process.env.BREVO_API_KEY
);

console.log(
  "BREVO SENDER EXISTS:",
  !!process.env.BREVO_SENDER_EMAIL
);

console.log(
  "PORT:",
  PORT
);

console.log("=================================");

// ===============================
// HEALTH CHECK
// ===============================

app.get("/", (req, res) => {
  console.log("HEALTH CHECK HIT");

  return res.status(200).json({
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
// 404 HANDLER
// ===============================

app.use((req, res) => {
  console.log(
    "404 ROUTE NOT FOUND:",
    req.method,
    req.originalUrl
  );

  return res.status(404).json({
    success: false,
    message: "Route not found",
    path: req.originalUrl,
  });
});

// ===============================
// GLOBAL ERROR HANDLER
// ===============================

app.use(
  (err, req, res, next) => {
    console.error(
      "GLOBAL ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message:
        err.message ||
        "Server error",
    });
  }
);

// ===============================
// START SERVER
// ===============================

const startServer = async () => {
  try {
    // --------------------------------
    // CHECK REQUIRED ENV VARIABLES
    // --------------------------------

    if (!process.env.MONGO_URI) {
      throw new Error(
        "MONGO_URI is missing"
      );
    }

    if (!process.env.JWT_SECRET) {
      throw new Error(
        "JWT_SECRET is missing"
      );
    }

    // --------------------------------
    // CONNECT MONGODB
    // --------------------------------

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

    // --------------------------------
    // START EXPRESS SERVER
    // --------------------------------

    const server =
      app.listen(
        PORT,
        "0.0.0.0",
        () => {
          console.log(
            `🚀 Server running on port ${PORT}`
          );
        }
      );

    // --------------------------------
    // GRACEFUL SHUTDOWN
    // --------------------------------

    const shutdown = async (
      signal
    ) => {
      console.log(
        `\n⚠️ ${signal} received`
      );

      console.log(
        "Closing HTTP server..."
      );

      server.close(
        async () => {
          console.log(
            "HTTP server closed"
          );

          try {
            await mongoose.connection.close();

            console.log(
              "MongoDB connection closed"
            );

            process.exit(0);

          } catch (error) {

            console.error(
              "MongoDB shutdown error:",
              error
            );

            process.exit(1);
          }
        }
      );
    };

    process.on(
      "SIGTERM",
      () => shutdown("SIGTERM")
    );

    process.on(
      "SIGINT",
      () => shutdown("SIGINT")
    );

  } catch (error) {

    console.error(
      "❌ SERVER START ERROR:"
    );

    console.error(
      error
    );

    process.exit(1);
  }
};

// ===============================
// START APPLICATION
// ===============================

startServer();
