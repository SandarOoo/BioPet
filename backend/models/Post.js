const mongoose = require("mongoose");

// ==========================================
// COMMENT SCHEMA
// ==========================================

const commentSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },

  text: {
    type: String,
    required: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// ==========================================
// POST SCHEMA
// ==========================================

const postSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },

    name: {
      type: String,
      default: "Anonymous",
    },

    text: {
      type: String,
      required: true,
    },

    images: [
      {
        data: String,
        contentType: String,
        filename: String,
      },
    ],

    likes: [
      {
        type: String,
      },
    ],

    comments: [
      commentSchema,
    ],
  },
  {
    timestamps: true,
  }
);

// ==========================================
// IMPORTANT
// Prevent OverwriteModelError
// ==========================================

module.exports =
  mongoose.models.Post ||
  mongoose.model("Post", postSchema);