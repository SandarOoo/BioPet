const Post = require("../models/Post");
const {
  moderatePetPost,
} = require("../services/ruleBasedModeration");
//const {
//  moderatePetPost,
//} = require("../services/openaiService");
const createPost = async (req, res) => {
  try {
    console.log("=================================");
    console.log("CREATE POST REQUEST");
    console.log("REQ.BODY =>", req.body);
    console.log(
      "REQ.FILES COUNT =>",
      req.files ? req.files.length : 0
    );

    if (req.files && req.files.length > 0) {
      req.files.forEach((file, index) => {
        console.log(`FILE ${index + 1} =>`, {
          fieldname: file.fieldname,
          originalname: file.originalname,
          mimetype: file.mimetype,
          size: file.size,
        });
      });
    }

    console.log("=================================");

    const {
      userId,
      name,
      text,
    } = req.body;

    // =====================================================
    // VALIDATE USER
    // =====================================================

    if (!userId || userId.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    // =====================================================
    // CONVERT UPLOADED IMAGES TO BASE64
    // =====================================================

    const images = [];

    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        images.push({
          data: file.buffer.toString("base64"),
          contentType: file.mimetype,
          filename: file.originalname,
        });
      }
    }

    console.log(
      "CONVERTED IMAGE COUNT =>",
      images.length
    );

    // =====================================================
    // VALIDATION
    // MUST HAVE TEXT OR IMAGE
    // =====================================================

    const cleanText =
      text && text.trim()
        ? text.trim()
        : "";

    if (
      cleanText === "" &&
      images.length === 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Post must contain text or at least one image",
      });
    }

    // =====================================================
    // RULE-BASED MODERATION
    // =====================================================

    console.log(
      "🔍 CHECKING POST WITH RULE-BASED MODERATION..."
    );

    const moderationResult = moderatePetPost({
      text: cleanText,
      images: images,
    });

    console.log(
      "MODERATION RESULT =>",
      moderationResult
    );

    if (!moderationResult.allowed) {
      return res.status(400).json({
        success: false,
        message: moderationResult.reason,
      });
    }

    // =====================================================
    // AI MODERATION - OPENAI
    // =====================================================

//    let aiResult = null;
//
//    // Only check text when text is available
//    if (cleanText !== "") {
//      console.log(
//        "🤖 CHECKING POST WITH OPENAI..."
//      );
//
//      aiResult =
//        await moderatePetPost(cleanText);
//
//      console.log(
//        "🤖 AI MODERATION RESULT =>",
//        aiResult
//      );
//
//      // Reject if post is not allowed
//      if (!aiResult.allowed) {
//        return res.status(400).json({
//          success: false,
//          message:
//            aiResult.reason ||
//            "This post cannot be published.",
//          aiModeration: aiResult,
//        });
//      }
//    }
//
//    // =====================================================
    // CREATE POST
    // =====================================================

    const post = await Post.create({
      userId: userId,
      name:
        name && name.trim()
          ? name.trim()
          : "Anonymous",

      text: cleanText,

      images: images,

      likes: [],

      comments: [],
    });



    // =====================================================
    // LOG CREATED POST
    // =====================================================

    console.log("=================================");
    console.log(
      "✅ POST CREATED SUCCESSFULLY"
    );
    console.log("POST ID =>", post._id);
    console.log(
      "IMAGE COUNT =>",
      post.images.length
    );
    console.log("TEXT =>", post.text);
    console.log("=================================");

    // =====================================================
    // RESPONSE
    // =====================================================

    return res.status(201).json({
      success: true,
      message:
        "Post created successfully",

      post: post,
    });

  } catch (error) {

    console.error("=================================");
    console.error(
      "❌ CREATE POST ERROR"
    );
    console.error(error);
    console.error("=================================");

    return res.status(500).json({
      success: false,
      message:
        "Failed to create post",

      error:
        error.message,
    });
  }
};

// =====================================================
// GET POSTS
// GET /api/posts
// =====================================================

const getPosts = async (req, res) => {
  try {

    const posts = await Post.find()
      .sort({
        createdAt: -1,
      });

    console.log(
      "GET POSTS =>",
      posts.length
    );

    return res.status(200).json({
      success: true,
      posts: posts,
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
// POST /api/posts/like
// =====================================================

const toggleLike = async (req, res) => {
  try {

    const {
      postId,
      userId,
    } = req.body;

    if (!postId || !userId) {
      return res.status(400).json({
        success: false,
        message:
          "postId and userId are required",
      });
    }

    // =====================================================
    // FIND POST
    // =====================================================

    const post =
      await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message:
          "Post not found",
      });
    }

    // =====================================================
    // TOGGLE LIKE
    // =====================================================

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

    // =====================================================
    // SAVE
    // =====================================================

    await post.save();

    // =====================================================
    // RESPONSE
    // =====================================================

    return res.status(200).json({
      success: true,

      likes:
        post.likes.length,

      post:
        post,
    });

  } catch (error) {

    console.error(
      "TOGGLE LIKE ERROR:",
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
// ADD COMMENT
// POST /api/posts/comment
// =====================================================

const addComment = async (req, res) => {
  try {

    const {
      postId,
      userId,
      text,
    } = req.body;

    // =====================================================
    // VALIDATE
    // =====================================================

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

    // =====================================================
    // FIND POST
    // =====================================================

    const post =
      await Post.findById(postId);

    if (!post) {

      return res.status(404).json({
        success: false,
        message:
          "Post not found",
      });
    }

    // =====================================================
    // ADD COMMENT
    // =====================================================

    post.comments.push({
      userId:
        userId || "guest",

      text:
        text.trim(),
    });

    // =====================================================
    // SAVE
    // =====================================================

    await post.save();

    // =====================================================
    // RESPONSE
    // =====================================================

    return res.status(200).json({
      success: true,

      comments:
        post.comments,
    });

  } catch (error) {

    console.error(
      "ADD COMMENT ERROR:",
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
// EXPORT
// =====================================================

module.exports = {
  createPost,
  getPosts,
  toggleLike,
  addComment,
};