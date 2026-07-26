const express = require("express");
const multer = require("multer");
const mongoose = require("mongoose");

const {
  analyzePost,
} = require("../services/geminiService");

const router =
  express.Router();

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

        if (
          allowed.test(
            file.mimetype
          )
        ) {

          cb(
            null,
            true
          );

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
// COMMENT SCHEMA
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

// =====================================================
// POST SCHEMA
// =====================================================

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

      String,

    ],

    comments: [

      commentSchema,

    ],

    createdAt: {

      type:
        Date,

      default:
        Date.now,

    },

  });

// =====================================================
// MODEL
// =====================================================

const Post =
  mongoose.models.Post ||
  mongoose.model(
    "Post",
    postSchema
  );

// =====================================================
// CREATE POST + GEMINI AI
// =====================================================

router.post(
  "/create",

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

      console.log(
        "================================="
      );

      console.log(
        "📝 CREATE POST REQUEST"
      );

      console.log(
        "USER ID:",
        userId
      );

      console.log(
        "NAME:",
        name
      );

      console.log(
        "TEXT:",
        text
      );

      console.log(
        "FILES:",
        req.files?.length || 0
      );

      console.log(
        "================================="
      );

      // =================================================
      // VALIDATE TEXT
      // =================================================

      if (
        !text ||
        text.trim().length === 0
      ) {

        return res.status(400).json({

          success:
            false,

          message:
            "Post text is required",

        });

      }

      // =================================================
      // GEMINI AI MODERATION
      // =================================================

      console.log(
        "🤖 START AI MODERATION"
      );

      const aiResult =
        await analyzePost(
          text.trim()
        );

      console.log(
        "🤖 AI RESULT:",
        aiResult
      );

      // =================================================
      // BLOCK POST
      // =================================================

      if (
        aiResult.allowed === false
      ) {

        console.log(
          "🚫 POST BLOCKED BY AI"
        );

        return res.status(400).json({

          success:
            false,

          message:
            aiResult.reason ||
            "Post blocked by AI moderation",

          ai:
            aiResult,

        });

      }

      // =================================================
      // IMAGE PROCESSING
      // =================================================

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
              `data:${file.mimetype};base64,` +
              file.buffer.toString(
                "base64"
              ),

            contentType:
              file.mimetype,

            filename:
              file.originalname,

          });

        }

      }

      // =================================================
      // CREATE POST
      // =================================================

      const post =
        new Post({

          userId:
            userId ||
            "guest",

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

      // =================================================
      // SAVE
      // =================================================

      const saved =
        await post.save();

      console.log(
        "✅ POST SAVED:",
        saved._id
      );

      // =================================================
      // RESPONSE
      // =================================================

      return res.status(201).json({

        success:
          true,

        message:
          "Post created successfully",

        post:
          saved,

        ai:
          aiResult,

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

// =====================================================
// GET POSTS
// =====================================================

router.get(
  "/",

  async (
    req,
    res
  ) => {

    try {

      console.log(
        "📥 GET POSTS"
      );

      const posts =
        await Post

          .find()

          .sort({

            createdAt:
              -1,

          });

      console.log(
        "POST COUNT:",
        posts.length
      );

      return res.json({

        success:
          true,

        posts:
          posts,

      });

    } catch (err) {

      console.error(
        "❌ GET POSTS ERROR:",
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

// =====================================================
// LIKE POST
// =====================================================

router.post(
  "/like",

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

        return res.status(404).json({

          success:
            false,

          message:
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

      console.error(
        "LIKE ERROR:",
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

// =====================================================
// COMMENT
// =====================================================

router.post(
  "/comment",

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

      if (
        !text ||
        text.trim().length === 0
      ) {

        return res.status(400).json({

          success:
            false,

          message:
            "Comment text is required",

        });

      }

      const post =
        await Post.findById(
          postId
        );

      if (!post) {

        return res.status(404).json({

          success:
            false,

          message:
            "Post not found",

        });

      }

      post.comments.push({

        userId:

          userId ||
          "guest",

        text:

          text.trim(),

      });

      await post.save();

      return res.json({

        success:
          true,

        comments:
          post.comments,

      });

    } catch (err) {

      console.error(
        "COMMENT ERROR:",
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

// =====================================================
// EXPORT
// =====================================================

module.exports =
  router;