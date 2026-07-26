const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  text: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const postSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  name: { type: String, default: 'Anonymous' },
  text: { type: String, default: '' },

  images: [
    {
      data: { type: String, required: true },
      contentType: { type: String, required: true },
      filename: { type: String }
    }
  ],

  likes: [{ type: String }],
  comments: [commentSchema],


  category: { type: String, default: "general" },
  tags: [{ type: String }],

  aiReview: {
    allowed: Boolean,
    petRelated: Boolean,
    spam: Boolean,
    offensive: Boolean,
    confidence: Number,
    reason: String
  },

  createdAt: { type: Date, default: Date.now }
});
