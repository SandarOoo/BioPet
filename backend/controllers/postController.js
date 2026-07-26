const Post = require("../models/Post");
const { analyzePost } = require("../services/geminiService.js");

// =====================================================
// GET POSTS
// =====================================================

exports.getPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 });
    res.json({ success: true, posts });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// =====================================================
// CREATE POST + GEMINI MODERATION (TEXT + IMAGES)
// =====================================================

exports.createPost = async (req, res) => {
  try {
    const { userId, name, text } = req.body;

    if (!text) {
      return res.status(400).json({ message: "text required" });
    }

    // Build images array from uploaded files first,
    // so we can send them to Gemini for moderation too
    const images = (req.files || []).map((file) => ({
      data: `data:${file.mimetype};base64,${file.buffer.toString("base64")}`,
      contentType: file.mimetype,
      filename: file.originalname,
    }));

    console.log("🖼️ Uploaded images:", images.length);

    // Gemini moderation - now checks TEXT + IMAGES
    const aiResult = await analyzePost(text, images);

    console.log("AI RESULT:", aiResult);

    if (!aiResult.allowed || !aiResult.petRelated) {
      return res.status(403).json({
        message: aiResult.reason || "Post blocked by AI",
        ai: aiResult,
      });
    }

    const newPost = new Post({
      userId,
      name,
      text,
      images,
      category: aiResult.category,
      aiReview: aiResult,
    });

    await newPost.save();

    res.status(201).json({
      success: true,
      post: newPost,
      ai: aiResult,
    });
  } catch (error) {
    console.error("❌ CREATE POST ERROR:", error);
    res.status(500).json({ message: error.message });
  }
};

// =====================================================
// TOGGLE LIKE
// =====================================================

exports.toggleLike = async (req, res) => {
  try {
    const { postId, userId } = req.body;

    const post = await Post.findById(postId);

    if (!post) return res.status(404).json({ message: "Not found" });

    if (post.likes.includes(userId)) {
      post.likes = post.likes.filter((id) => id !== userId);
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// =====================================================
// ADD COMMENT
// =====================================================

exports.addComment = async (req, res) => {
  try {
    const { postId, userId, text } = req.body;

    const post = await Post.findById(postId);

    if (!post) return res.status(404).json({ message: "Not found" });

    post.comments.push({ userId, text });

    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};