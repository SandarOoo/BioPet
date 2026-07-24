const express = require("express");
const router = express.Router();

const {
  getPosts,
  createPost,
  toggleLike,
  addComment,
} = require("../controllers/postController");

router.get("/", getPosts);
router.post("/create", createPost);
router.post("/like", toggleLike);
router.post("/comment", addComment);

module.exports = router;