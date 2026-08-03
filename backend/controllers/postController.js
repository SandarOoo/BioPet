const Post = require("../models/Post");

const {
  moderatePetPost,
} = require("../services/ruleBasedModeration");

const {
  moderatePetImages,
} = require("../services/imagePetModeration");

const getImageModerationHttpStatus = (result) => {
  switch (result?.errorCode) {
    case "OPENAI_RATE_LIMITED":
      return 429;

    case "OPENAI_TIMEOUT":
      return 504;

    case "INVALID_IMAGE_FILE":
    case "UNSUPPORTED_IMAGE_TYPE":
    case "PET_IMAGE_REQUIRED":
      return 400;

    case "OPENAI_KEY_MISSING":
    case "OPENAI_AUTH_ERROR":
    case "OPENAI_PERMISSION_DENIED":
    case "OPENAI_QUOTA_EXCEEDED":
    case "OPENAI_MODEL_NOT_AVAILABLE":
    case "OPENAI_BAD_REQUEST":
    case "OPENAI_SERVICE_UNAVAILABLE":
    case "OPENAI_REQUEST_FAILED":
    case "OPENAI_NETWORK_ERROR":
    case "OPENAI_NON_JSON_RESPONSE":
    case "OPENAI_EMPTY_RESPONSE":
    case "OPENAI_INVALID_JSON_CONTENT":
    case "OPENAI_RESULT_COUNT_MISMATCH":
      return 503;

    default:
      return result?.status === "review_required"
        ? 503
        : 400;
  }
};

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

    if (req.files && req.files.length > 0) {
      console.log(
        "CHECKING IMAGES WITH AI PET MODERATION..."
      );

      const imageModerationResult =
        await moderatePetImages(req.files);

      console.log("IMAGE MODERATION RESULT =>", {
        allowed: imageModerationResult.allowed,
        status: imageModerationResult.status,
        category: imageModerationResult.category,
        errorCode: imageModerationResult.errorCode,
        providerStatus:
          imageModerationResult.providerStatus,
        retryable: imageModerationResult.retryable,
        reason: imageModerationResult.reason,
      });

      if (!imageModerationResult.allowed) {
        const httpStatus =
          getImageModerationHttpStatus(
            imageModerationResult
          );

        return res.status(httpStatus).json({
          success: false,
          code:
            imageModerationResult.errorCode ||
            (imageModerationResult.status ===
            "review_required"
              ? "IMAGE_MODERATION_UNAVAILABLE"
              : "PET_IMAGE_REQUIRED"),
          message:
            imageModerationResult.reason ||
            (imageModerationResult.status ===
            "review_required"
              ? "ပုံစစ်ဆေးမှု service ကို အသုံးပြု၍မရသေးပါ။"
              : "ခွေး သို့မဟုတ် ကြောင်နှင့် သက်ဆိုင်သောပုံကိုသာ တင်နိုင်ပါသည်။"),
          retryable:
            imageModerationResult.retryable === true,
          providerStatus:
            imageModerationResult.providerStatus ||
            null,
          imageModeration: {
            status: imageModerationResult.status,
            category: imageModerationResult.category,
            errorCode:
              imageModerationResult.errorCode || null,
            reason: imageModerationResult.reason,
            images: imageModerationResult.images || [],
          },
        });
      }
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
    const { postId, userId, text } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Comment text is required",
      });
    }

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    post.comments.push({
      userId: userId || "guest",
      text: text.trim(),
    });

    await post.save();

    return res.status(200).json({
      success: true,
      comments: post.comments,
    });
  } catch (error) {
    console.error("ADD COMMENT ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createPost,
  getPosts,
  toggleLike,
  addComment,
};
