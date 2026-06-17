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
      data: { type: String, required: true }, // Base64 string
      contentType: { type: String, required: true }, // image/jpeg, image/png etc
      filename: { type: String }
    }
  ],
  likes: [{ type: String }], // Array of user IDs
  comments: [commentSchema],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Post', postSchema);