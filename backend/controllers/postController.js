const Post = require("../models/Post");

const {
  moderatePetPost,
} = require("../services/ruleBasedModeration");


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

    const { userId, name, text } = req.body;

    if (!userId || userId.trim() === "") {
      return res.status(400).json({
        success: false,
        code: "USER_ID_REQUIRED",
        message: "User ID is required",
      });
    }

    /*
     * Images are checked on the Flutter device with the existing local
     * MobileNet TensorFlow Lite breed classifier before this request is sent.
     * No OpenAI, Gemini, or OpenRouter API call is made by the backend.
     */
    if (req.files && req.files.length > 0) {
      console.log(
        "LOCAL PET IMAGE VALIDATION COMPLETED ON CLIENT =>",
        req.files.length
      );
    }

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

    const cleanText =
      text && text.trim() ? text.trim() : "";

    if (cleanText === "" && images.length === 0) {
      return res.status(400).json({
        success: false,
        code: "POST_CONTENT_REQUIRED",
        message:
          "Post must contain text or at least one image",
      });
    }

    console.log(
      "CHECKING POST WITH RULE-BASED MODERATION..."
    );

    const moderationResult = moderatePetPost({
      text: cleanText,
      images,
    });

    console.log(
      "MODERATION RESULT =>",
      moderationResult
    );

    if (!moderationResult.allowed) {
      return res.status(400).json({
        success: false,
        code: "TEXT_MODERATION_REJECTED",
        message: moderationResult.reason,
      });
    }

    const post = await Post.create({
      userId,
      name:
        name && name.trim()
          ? name.trim()
          : "Anonymous",
      text: cleanText,
      images,
      likes: [],
      comments: [],
    });

    console.log("=================================");
    console.log("POST CREATED SUCCESSFULLY");
    console.log("POST ID =>", post._id);
    console.log("IMAGE COUNT =>", post.images.length);
    console.log("TEXT =>", post.text);
    console.log("=================================");

    return res.status(201).json({
      success: true,
      message: "Post created successfully",
      post,
    });
  } catch (error) {
    console.error("=================================");
    console.error("CREATE POST ERROR");
    console.error(error);
    console.error("=================================");

    return res.status(500).json({
      success: false,
      code: "CREATE_POST_FAILED",
      message: "Failed to create post",
      error: error.message,
    });
  }
};

const getPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({
      createdAt: -1,
    });

    console.log("GET POSTS =>", posts.length);

    return res.status(200).json({
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

const toggleLike = async (req, res) => {
  try {
    const { postId, userId } = req.body;

    if (!postId || !userId) {
      return res.status(400).json({
        success: false,
        message: "postId and userId are required",
      });
    }

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

    return res.status(200).json({
      success: true,
      likes: post.likes.length,
      post,
    });
  } catch (error) {
    console.error("TOGGLE LIKE ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const addComment = async (req, res) => {
  try {
    const {
      postId,
      commentId,
      userId,
      userName,
      text,
    } = req.body;

    if (!postId) {
      return res.status(400).json({
        success: false,
        message: "postId is required",
      });
    }

    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: commentId
          ? "Reply text is required"
          : "Comment text is required",
      });
    }

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    const safeUserId =
      userId && String(userId).trim()
        ? String(userId).trim()
        : "guest";

    const safeUserName =
      userName && String(userName).trim()
        ? String(userName).trim()
        : "Anonymous";

    const safeText = String(text).trim();

    // Existing /comment route can also create a reply when commentId is sent.
    // This keeps reply support working without requiring a new route.
    if (commentId) {
      const comment = post.comments.id(commentId);

      if (!comment) {
        return res.status(404).json({
          success: false,
          message: "Comment not found",
        });
      }

      if (!Array.isArray(comment.replies)) {
        comment.replies = [];
      }

      comment.replies.push({
        userId: safeUserId,
        userName: safeUserName,
        text: safeText,
        createdAt: new Date(),
      });

      const reply =
        comment.replies[comment.replies.length - 1];

      await post.save();

      return res.status(200).json({
        success: true,
        message: "Reply added successfully",
        reply,
        comment,
        comments: post.comments,
      });
    }

    post.comments.push({
      userId: safeUserId,
      userName: safeUserName,
      text: safeText,
      createdAt: new Date(),
      replies: [],
    });

    const comment =
      post.comments[post.comments.length - 1];

    await post.save();

    return res.status(200).json({
      success: true,
      message: "Comment added successfully",
      comment,
      comments: post.comments,
    });
  } catch (error) {
    console.error("ADD COMMENT/REPLY ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Optional dedicated /reply route can point to the same handler.
// The existing /comment route already works when commentId is included.
const addReply = addComment;


module.exports = {
  createPost,
  getPosts,
  toggleLike,
  addComment,
  addReply
};
