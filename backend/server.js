const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");

require("dotenv").config({
  path: "E:/BioPet/.env",
});

const {
  analyzePost,
} = require("./services/geminiService");


// =====================================================
// APP
// =====================================================

const app = express();


// =====================================================
// ROUTES
// =====================================================

const authRoute =
  require("./routes/auth.js");

const businessRoutes =
  require("./routes/business");

const adminRoutes =
  require("./routes/admin");


const productRoutes = require("./routes/productRoutes");

app.use(
  "/api/business",
  productRoutes
);

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
// API ROUTES
// =====================================================

// Auth
app.use(
  "/api/auth",
  authRoute
);





// Product
app.use(
  "/api/business",
  productRoutes
);


// Admin
app.use(
  "/api/admin",
  adminRoutes
);


// =====================================================
// ENV CHECK
// =====================================================

console.log(
  "ENV CHECK:",
  process.env.MONGO_URI
);

console.log(
  "GEMINI KEY EXISTS:",
  !!process.env.GEMINI_API_KEY
);


// =====================================================
// MONGODB
// =====================================================

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

  })
  .catch((err) => {

    console.error(
      "❌ MongoDB Error:",
      err
    );

  });


// =====================================================
// POST MODEL
// =====================================================

const commentSchema =
  new mongoose.Schema({

    userId:
      String,

    text:
      String,

    createdAt: {
      type:
        Date,

      default:
        Date.now,
    },

  });


const postSchema =
  new mongoose.Schema({

    userId:
      String,

    name: {
      type:
        String,

      default:
        "Anonymous",
    },

    text:
      String,

    images: [
      {
        data:
          String,

        contentType:
          String,

        filename:
          String,
      },
    ],

    likes: [
      String
    ],

    comments: [
      commentSchema
    ],

    createdAt: {
      type:
        Date,

      default:
        Date.now,
    },

  });


const Post =
  mongoose.model(
    "Post",
    postSchema
  );


// =====================================================
// MULTER
// =====================================================

const upload =
  multer({

    storage:
      multer.memoryStorage(),

    limits: {

      fileSize:
        10 * 1024 * 1024,

      files:
        10,

    },

    fileFilter:
      (req, file, cb) => {

        const allowed =
          /jpeg|jpg|png|gif|webp/;

        cb(
          null,
          allowed.test(
            file.mimetype
          )
        );

      },

  });


// =====================================================
// IMAGE TO BASE64
// =====================================================

function bufferToBase64(
  buffer,
  mimetype
) {

  return `data:${mimetype};base64,${buffer.toString("base64")}`;

}


// =====================================================
// CREATE POST + AI
// =====================================================

app.post(
  "/api/posts/create",
  upload.array(
    "images",
    10
  ),

  async (
    req,
    res
  ) => {

    try {

      const {
        userId,
        name,
        text,
      } = req.body;


      // AI CHECK

      const aiResult =
        await analyzePost(
          text
        );


      if (
        !aiResult.allowed
      ) {

        return res
          .status(400)
          .json({

            success:
              false,

            message:
              "Post blocked by AI",

            ai:
              aiResult,

          });

      }


      // Images

      const images = [];


      if (
        req.files &&
        req.files.length > 0
      ) {

        for (
          const file
          of req.files
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


      // Create Post

      const post =
        new Post({

          userId,

          name:
            name ||
            "Anonymous",

          text,

          images,

          likes:
            [],

          comments:
            [],

        });


      const saved =
        await post.save();


      return res
        .status(201)
        .json({

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
        "Create Post Error:",
        err
      );

      return res
        .status(500)
        .json({

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
  async (
    req,
    res
  ) => {

    try {

      const posts =
        await Post
          .find()
          .sort({
            createdAt:
              -1,
          });

      return res.json(
        posts
      );

    } catch (err) {

      return res
        .status(500)
        .json({

          success:
            false,

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
  async (
    req,
    res
  ) => {

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

        return res
          .status(404)
          .json({

            success:
              false,

            error:
              "Post not found",

          });

      }


      if (
        post.likes.includes(
          userId
        )
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

        success:
          true,

        likes:
          post.likes.length,

      });


    } catch (err) {

      return res
        .status(500)
        .json({

          success:
            false,

          message:
            err.message,

        });

    }

  }
);


// =====================================================
// COMMENTS
// =====================================================

app.post(
  "/api/posts/comment",
  async (
    req,
    res
  ) => {

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

        return res
          .status(404)
          .json({

            success:
              false,

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

        success:
          true,

        comments:
          post.comments,

      });


    } catch (err) {

      return res
        .status(500)
        .json({

          success:
            false,

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
  (
    req,
    res
  ) => {

    res.json({

      message:
        "BioPet API Running",

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
  () => {

    console.log(
      `Server running on port ${PORT}`
    );

    console.log(
      "BREVO KEY:",
      !!process.env.BREVO_API_KEY
    );

  }
);