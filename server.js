const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ============================================
// MONGODB CONNECTION
// ============================================
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.error('❌ MongoDB Error:', err));

// ============================================
// POST SCHEMA 
// ============================================
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
      contentType: { type: String, required: true },
      filename: { type: String }
    }
  ],
  likes: [{ type: String }],
  comments: [commentSchema],
  createdAt: { type: Date, default: Date.now }
});

const Post = mongoose.model('Post', postSchema);

// ============================================
// MULTER CONFIGURATION
// ============================================
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'));
  }
};

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB per file
    files: 10
  },
  fileFilter: fileFilter
});

// Helper: Buffer to Base64
function bufferToBase64(buffer, mimetype) {
  return `data:${mimetype};base64,${buffer.toString('base64')}`;
}

// ============================================
// POST API ROUTES
// ============================================

// 1. Post အသစ်ဖန်တီးခြင်း (ပုံမျိုးစုံပါ)
app.post('/api/posts/create', upload.array('images', 10), async (req, res) => {
  try {
    const { userId, name, text } = req.body;

    
    const images = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        images.push({
          data: bufferToBase64(file.buffer, file.mimetype),
          contentType: file.mimetype,
          filename: file.originalname
        });
      }
    }

    const newPost = new Post({
      userId: userId,
      name: name || 'Anonymous',
      text: text || '',
      images: images,
      likes: [],
      comments: []
    });

    const savedPost = await newPost.save();

    res.status(201).json({
      success: true,
      post: savedPost,
      message: `Post created with ${images.length} image(s)!`
    });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 2. Posts တွေယူဖို့
app.get('/api/posts', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.status(200).json(posts);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
// 3. Like toggle 
app.post('/api/posts/like', async (req, res) => {
  try {
    const { postId, userId } = req.body;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const hasLiked = post.likes.includes(userId);

    if (hasLiked) {
      post.likes = post.likes.filter(id => id !== userId);
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.status(200).json({
      success: true,
      likes: post.likes.length,
      liked: !hasLiked
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 4. Comment ထည့်ဖို့
app.post('/api/posts/comment', async (req, res) => {
  try {
    const { postId, userId, text } = req.body;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    post.comments.push({
      userId: userId,
      text: text,
      createdAt: new Date()
    });

    await post.save();

    res.status(200).json({
      success: true,
      comments: post.comments
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// EXISTING ROUTES
// ============================================
app.use('/api/auth', require('./routes/auth'));

// Health Check
app.get('/', (req, res) => {
  res.json({ message: '🐾 BioPet API Running!' });
});

// ============================================
// ERROR HANDLING
// ============================================
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'FILE_TOO_LARGE') {
      return res.status(400).json({ error: 'File too large. Max size is 10MB.' });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files. Max 10 images per post.' });
    }
    return res.status(400).json({ error: error.message });
  }

  if (error.message && error.message.includes('image files')) {
    return res.status(400).json({ error: error.message });
  }

  res.status(500).json({ error: error.message });
});

// ============================================
// START SERVER
// ============================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});