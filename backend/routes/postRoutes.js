const express = require("express");
const multer = require("multer");
const router = express.Router();

const {
  getPosts,
  createPost,
  toggleLike,
  addComment,
} = require("../controllers/postController");

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 10,
  },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|gif|webp/;
    if (allowed.test(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});

router.get("/", getPosts);
router.post("/create", upload.array("images", 10), createPost);
router.post("/like", toggleLike);
router.post("/comment", addComment);

module.exports = router;