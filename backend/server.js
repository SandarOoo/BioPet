require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");

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

app.get(
  "/api/test-gemini",
  async (req, res) => {

    try {

      const result =
        await analyzePost(
          "My dog is sick and needs veterinary care."
        );

      return res.json({

        success:
          true,

        ai:
          result,

      });

    } catch (err) {

      return res.status(500).json({

        success:
          false,

        error:
          err.message,

      });

    }

  }
);


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
// ROUTES
// =====================================================

const authRoute = require("./routes/auth");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/admin");

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
// POST MODEL
// =====================================================

const commentSchema = new mongoose.Schema({
  userId: String,

  text: String,

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const postSchema = new mongoose.Schema({
  userId: String,

  name: {
    type: String,
    default: "Anonymous",
  },

  text: String,

  images: [
    {
      data: String,

      contentType: String,

      filename: String,
    },
  ],

  likes: [
    String,
  ],

  comments: [
    commentSchema,
  ],

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const Post = mongoose.model(
  "Post",
  postSchema
);

// =====================================================
// MULTER
// =====================================================

const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 10,
  },

  fileFilter: (req, file, cb) => {
    const allowed =
      /jpeg|jpg|png|gif|webp/;

    if (
      allowed.test(file.mimetype)
    ) {
      cb(null, true);
    } else {
      cb(
        new Error(
          "Only image files are allowed"
        )
      );
    }
  },
});

// =====================================================
// IMAGE TO BASE64
// =====================================================

function bufferToBase64(
  buffer,
  mimetype
) {
  return `data:${mimetype};base64,${buffer.toString(
    "base64"
  )}`;
}

// =====================================================
// CREATE POST + GEMINI AI MODERATION
// =====================================================

app.post(
  "/api/posts/create",
  upload.array("images", 10),

  async (req, res) => {

    try {

      const {
        userId,
        name,
        text,
      } = req.body;


      // =========================================
      // VALIDATE POST
      // =========================================

      if (!text || text.trim().length === 0) {

        return res.status(400).json({
          success: false,
          message: "Post text is required",
        });

      }


      // =========================================
      // GEMINI AI MODERATION
      // =========================================

      console.log(
        "🤖 STARTING AI MODERATION"
      );

      const aiResult =
        await analyzePost(
          text.trim()
        );


      console.log(
        "🤖 AI RESULT:",
        aiResult
      );


      // =========================================
      // BLOCK POST
      // =========================================

      if (!aiResult.allowed) {

        return res.status(400).json({

          success: false,

          message:
            aiResult.reason ||
            "Post blocked by AI moderation",

          ai:
            aiResult,

        });

      }


      // =========================================
      // IMAGE PROCESSING
      // =========================================

      const images = [];


      if (
        req.files &&
        req.files.length > 0
      ) {

        for (
          const file of req.files
        ) {

          images.push({

            data:
              bufferToBase64(
                file.buffer,
                file.mimetype
              ),

            contentType:
              file.mimetype,

            filename:
              file.originalname,

          });

        }

      }


      // =========================================
      // CREATE POST
      // =========================================

      const post =
        new Post({

          userId:
            userId,

          name:
            name ||
            "Anonymous",

          text:
            text.trim(),

          images:
            images,

          likes:
            [],

          comments:
            [],

        });


      const saved =
        await post.save();


      // =========================================
      // SUCCESS
      // =========================================

      return res.status(201).json({

        success:
          true,

        post:
          saved,

        ai:
          aiResult,

        message:
          "Post created successfully",

      });


    } catch (err) {

      console.error(
        "❌ CREATE POST ERROR:",
        err
      );


      return res.status(500).json({

        success:
          false,

        message:
          err.message,

      });

    }

  }
);

    app.get(
      "/api/test-gemini",
      async (req, res) => {

        try {

          const result =
            await analyzePost(
              "My dog is sick and needs veterinary care."
            );

          return res.json({

            success:
              true,

            ai:
              result,

          });

        } catch (err) {

          return res.status(500).json({

            success:
              false,

            error:
              err.message,

          });

        }

      }
    );

// =====================================================
// GET POSTS
// =====================================================

app.get(
  "/api/posts",
  async (req, res) => {
    try {
      const posts =
        await Post.find()
          .sort({
            createdAt: -1,
          });

      return res.json({
        success: true,
        posts,
      });

    } catch (err) {
      return res.status(500).json({
        success: false,
        message:
          err.message,
      });
    }
  }
);

// =====================================================
// LIKE POST
// =====================================================

app.post(
  "/api/posts/like",
  async (req, res) => {
    try {
      const {
        postId,
        userId,
      } = req.body;

      const post =
        await Post.findById(
          postId
        );

      if (!post) {
        return res.status(404).json({
          success: false,
          message:
            "Post not found",
        });
      }

      if (
        post.likes.includes(userId)
      ) {
        post.likes =
          post.likes.filter(
            (id) =>
              id !== userId
          );
      } else {
        post.likes.push(
          userId
        );
      }

      await post.save();

      return res.json({
        success: true,

        likes:
          post.likes.length,
      });

    } catch (err) {
      return res.status(500).json({
        success: false,
        message:
          err.message,
      });
    }
  }
);

// =====================================================
// COMMENT
// =====================================================

app.post(
  "/api/posts/comment",
  async (req, res) => {
    try {
      const {
        postId,
        userId,
        text,
      } = req.body;

      const post =
        await Post.findById(
          postId
        );

      if (!post) {
        return res.status(404).json({
          success: false,
          message:
            "Post not found",
        });
      }

      post.comments.push({
        userId,
        text,
      });

      await post.save();

      return res.json({
        success: true,

        comments:
          post.comments,
      });

    } catch (err) {
      return res.status(500).json({
        success: false,
        message:
          err.message,
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
      message:
        "BioPet API Running",
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