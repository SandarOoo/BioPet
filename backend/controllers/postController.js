const Post = require("../models/Post");

// =====================================================
// CREATE POST
// NO GEMINI AI CHECK
// TEXT ONLY
// IMAGE ONLY
// TEXT + IMAGE
// =====================================================

const createPost = async (req, res) => {
  try {
    const { userId, name, text } = req.body;

    // Get uploaded images
    const images = req.files
      ? req.files.map((file) => ({
          data: file.buffer.toString("base64"),
          contentType: file.mimetype,
          filename: file.originalname,
        }))
      : [];

    // Optional validation
    if ((!text || text.trim() === "") && images.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Post must contain text or at least one image",
      });
    }

    // Create post directly
    // NO GEMINI CHECK
    const post = await Post.create({
      userId,
      name: name || "Anonymous",
      text: text ? text.trim() : "",
      images,
      likes: [],
      comments: [],
    });

    console.log("=================================");
    console.log("✅ POST CREATED SUCCESSFULLY");
    console.log("POST ID:", post._id);
    console.log("=================================");

    return res.status(201).json({
      success: true,
      message: "Post created successfully",
      post,
    });
  } catch (error) {
    console.error("=================================");
    console.error("❌ CREATE POST ERROR");
    console.error(error);
    console.error("=================================");

    return res.status(500).json({
      success: false,
      message: "Failed to create post",
      error: error.message,
    });
  }
};

// =====================================================
// GET POSTS
// =====================================================

const getPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({
      createdAt: -1,
    });

    return res.json({
      success: true,
      posts,
    });
  } catch (error) {
    console.error("GET POSTS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// LIKE POST
// =====================================================

const toggleLike = async (req, res) => {
  try {
    const { postId, userId } = req.body;

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    if (post.likes.includes(userId)) {
      post.likes = post.likes.filter(
        (id) => id !== userId
      );
    } else {
      post.likes.push(userId);
    }

    await post.save();

    return res.json({
      success: true,
      likes: post.likes.length,
      post,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// ADD COMMENT
// =====================================================

const addComment = async (req, res) => {
  try {
    const {
      postId,
      userId,
      text,
    } = req.body;

    // Validate text
    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Comment text is required",
      });
    }

    // Find post
    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    // Add comment
    post.comments.push({
      userId: userId || "guest",
      text: text.trim(),
    });

    await post.save();

    return res.json({
      success: true,
      comments: post.comments,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// EXPORT
// =====================================================

module.exports = {
  createPost,
  getPosts,
  toggleLike,
  addComment,
};