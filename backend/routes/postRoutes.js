const express =
  require("express");

const multer =
  require("multer");

const upload =
  require("../utils/upload");

const {
  createPost,
  getPosts,
  toggleLike,
  addComment,
} = require(
  "../controllers/postController"
);

const router =
  express.Router();

const uploadPostImages = (
  req,
  res,
  next
) => {
  upload.array(
    "images",
    10
  )(
    req,
    res,
    (error) => {
      if (!error) {
        return next();
      }

      if (
        error instanceof
        multer.MulterError
      ) {
        let message =
          error.message;

        if (
          error.code ===
          "LIMIT_FILE_SIZE"
        ) {
          message =
            "Each image must be 5 MB or smaller.";
        } else if (
          error.code ===
          "LIMIT_FILE_COUNT"
        ) {
          message =
            "A maximum of 10 images can be uploaded.";
        }

        return res
          .status(400)
          .json({
            success: false,
            code: error.code,
            message,
          });
      }

      return res
        .status(400)
        .json({
          success: false,

          message:
            error.message ||
            "Image upload failed.",
        });
    }
  );
};

router.post(
  "/create",
  uploadPostImages,
  createPost
);

router.get(
  "/",
  getPosts
);

router.post(
  "/like",
  toggleLike
);

router.post(
  "/comment",
  addComment
);

router.post(
  "/reply",
  addReply
);

module.exports = router;