const express = require("express");
const multer = require("multer");

const {
  createPost,
  getPosts,
  toggleLike,
  addComment,
} = require("../controllers/postController");

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
// CREATE POST
// POST /api/posts/create
// =====================================================

router.post(
  "/create",
  upload.array(
    "images",
    10
  ),
  createPost
);

// =====================================================
// GET POSTS
// GET /api/posts
// =====================================================

router.get(
  "/",
  getPosts
);

// =====================================================
// LIKE
// POST /api/posts/like
// =====================================================

router.post(
  "/like",
  toggleLike
);

// =====================================================
// COMMENT
// POST /api/posts/comment
// =====================================================

router.post(
  "/comment",
  addComment
);

module.exports =
  router;