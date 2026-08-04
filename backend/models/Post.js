const mongoose = require("mongoose");

// =====================================================
// COMMENT SCHEMA
// =====================================================

// =====================================================
// REPLY SCHEMA
// =====================================================

const replySchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },

    userName: {
      type: String,
      default: "Anonymous",
    },

    text: {
      type: String,
      required: true,
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    _id: true,
  }
);

// =====================================================
// COMMENT SCHEMA
// =====================================================

const commentSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },

    userName: {
      type: String,
      default: "Anonymous",
    },

    text: {
      type: String,
      required: true,
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },

    replies: {
      type: [replySchema],
      default: [],
    },
  },
  {
    _id: true,
  }
);
// =====================================================
// AI REVIEW SCHEMA
// =====================================================

const aiReviewSchema =
  new mongoose.Schema(
    {
      allowed: {
        type: Boolean,
        default: true,
      },

      petRelated: {
        type: Boolean,
        default: true,
      },

      reason: {
        type: String,
        default: "",
      },
    },
    {
      _id: false,
    }
  );

// =====================================================
// POST SCHEMA
// =====================================================

const postSchema =
  new mongoose.Schema(
    {
      // =================================================
      // USER
      // =================================================

      userId: {
        type: String,
        required: true,
      },

      // =================================================
      // NAME
      // =================================================

      name: {
        type: String,
        default: "Anonymous",
      },

      // =================================================
      // TEXT
      // =================================================

      text: {
        type: String,
        default: "",
      },

      // =================================================
      // IMAGES
      // =================================================

      images: [
        {
          data: {
            type: String,
            default: "",
          },

          contentType: {
            type: String,
            default: "",
          },

          filename: {
            type: String,
            default: "",
          },
        },
      ],

      // =================================================
      // AI REVIEW
      // =================================================

      aiReview: {
        type: aiReviewSchema,
        default: () => ({
          allowed: true,
          petRelated: true,
          reason: "",
        }),
      },

      // =================================================
      // LIKES
      // =================================================

      likes: [
        {
          type: String,
        },
      ],

      // =================================================
      // COMMENTS
      // =================================================

      comments: [
        commentSchema,
      ],
    },

    {
      timestamps: true,
    }
  );

// =====================================================
// PREVENT OVERWRITE MODEL ERROR
// =====================================================

module.exports =
  mongoose.models.Post ||
  mongoose.model(
    "Post",
    postSchema
  );