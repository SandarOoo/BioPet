const Post = require("../models/Post");
const { analyzePost } = require("../services/geminiService");

// =====================================================
// CREATE POST
// GEMINI AI MODERATION
// =====================================================

const createPost = async (req, res) => {
  try {
    const {
      userId,
      name,
      text,
    } = req.body;

    // =========================================
    // VALIDATE
    // =========================================

    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Post text is required",
      });
    }

    console.log("=================================");
    console.log("🤖 START AI MODERATION");
    console.log("POST TEXT:", text);
    console.log("=================================");

    // =========================================
    // GEMINI AI
    // =========================================

    const aiResult = await analyzePost(
      text.trim()
    );

    console.log(
      "🤖 AI RESULT:",
      aiResult
    );

    // =========================================
    // BLOCK POST
    // =========================================

    if (
      aiResult &&
      aiResult.allowed === false
    ) {
      console.log(
        "🚫 POST BLOCKED BY GEMINI"
      );

      return res.status(400).json({
        success: false,

        message:
          aiResult.reason ||
          "Post blocked by AI moderation",

        ai: aiResult,
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
            `data:${file.mimetype};base64,` +
            file.buffer.toString("base64"),

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

    const post = new Post({
      userId:
        userId || "guest",

      name:
        name || "Anonymous",

      text:
        text.trim(),

      images,

      likes: [],

      comments: [],
    });

    const savedPost =
      await post.save();

    console.log(
      "✅ POST SAVED"
    );

    // =========================================
    // RESPONSE
    // =========================================

    return res.status(201).json({
      success: true,

      message:
        "Post created successfully",

      post:
        savedPost,

      ai:
        aiResult,
    });

  } catch (error) {

    console.error(
      "❌ CREATE POST ERROR:",
      error
    );

    return res.status(500).json({
      success: false,

      message:
        error.message,
    });
  }
};


// =====================================================
// GET POSTS
// =====================================================

const getPosts = async (
  req,
  res
) => {
  try {

    const posts =
      await Post
        .find()
        .sort({
          createdAt: -1,
        });

    return res.json({
      success: true,

      posts,
    });

  } catch (error) {

    console.error(
      "GET POSTS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,

      message:
        error.message,
    });
  }
};


// =====================================================
// LIKE POST
// =====================================================

const toggleLike = async (
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
        success: false,
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
      success: true,

      likes:
        post.likes.length,

      post,
    });

  } catch (error) {

    return res.status(500).json({
      success: false,

      message:
        error.message,
    });
  }
};


// =====================================================
// COMMENT
// =====================================================

const addComment = async (
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
        success: false,
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
        success: false,
        message:
          "Post not found",
      });
    }

    post.comments.push({
      userId:
        userId || "guest",

      text:
        text.trim(),
    });

    await post.save();

    return res.json({
      success: true,

      comments:
        post.comments,
    });

  } catch (error) {

    return res.status(500).json({
      success: false,

      message:
        error.message,
    });
  }
};


module.exports = {
  createPost,
  getPosts,
  toggleLike,
  addComment,
};