const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const businessRoutes = require('./routes/business');
require('dotenv').config({ path: 'E:/BioPet/.env' });

const { analyzePost } = require("./services/geminiService");

const app = express();
const authRoute=require("./routes/auth.js");

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/api/auth",authRoute)
app.use("/api/business",businessRoutes);
const adminRoutes = require("./routes/admin");

//for products
const productRoutes = require("./routes/productRoutes");
app.use("/api/business",productRoutes);



app.use(
 "/api/admin",
 adminRoutes
);
console.log("ENV CHECK:", process.env.MONGO_URI);

//mongo connect

mongoose.connect(process.env.MONGO_URI)
  .then(() => {
  console.log('✅ MongoDB Connected');
  console.log("Database: ", mongoose.connection.name);})
  .catch(err => console.error('❌ MongoDB Error:', err));

//models
const commentSchema = new mongoose.Schema({
  userId: String,
  text: String,
  createdAt: { type: Date, default: Date.now }
});

const postSchema = new mongoose.Schema({
  userId: String,
  name: { type: String, default: 'Anonymous' },
  text: String,
  images: [
    {
      data: String,
      contentType: String,
      filename: String
    }
  ],
  likes: [String],
  comments: [commentSchema],
  createdAt: { type: Date, default: Date.now }
});

const Post = mongoose.model('Post', postSchema);

//multers
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 10
  },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|gif|webp/;
    cb(null, allowed.test(file.mimetype));
  }
});

function bufferToBase64(buffer, mimetype) {
  return `data:${mimetype};base64,${buffer.toString('base64')}`;
}

//create post + ai
app.post('/api/posts/create', upload.array('images', 10), async (req, res) => {
  try {
    const { userId, name, text } = req.body;

    // 🔥 AI CHECK
    const aiResult = await analyzePost(text);

    if (!aiResult.allowed) {
      return res.status(400).json({
        success: false,
        message: "Post blocked by AI",
        ai: aiResult
      });
    }

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

    const post = new Post({
      userId,
      name: name || "Anonymous",
      text,
      images,
      likes: [],
      comments: []
    });

    const saved = await post.save();

    res.status(201).json({
      success: true,
      post: saved,
      ai: aiResult,
      message: "Post created successfully"
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});

//get posts
app.get('/api/posts', async (req, res) => {
  const posts = await Post.find().sort({ createdAt: -1 });
  res.json(posts);
});

//like

app.post('/api/posts/like', async (req, res) => {
  const { postId, userId } = req.body;

  const post = await Post.findById(postId);

  if (!post) return res.status(404).json({ error: "Not found" });

  if (post.likes.includes(userId)) {
    post.likes = post.likes.filter(id => id !== userId);
  } else {
    post.likes.push(userId);
  }

  await post.save();

  res.json({ success: true, likes: post.likes.length });
});

//comments
app.post('/api/posts/comment', async (req, res) => {
  const { postId, userId, text } = req.body;

  const post = await Post.findById(postId);

  post.comments.push({ userId, text });

  await post.save();

  res.json({ success: true, comments: post.comments });
});

//health check
app.get('/', (req, res) => {
  res.json({ message: "BioPet API Running" });
});

//server start
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
console.log(
  "BREVO KEY:",
  process.env.BREVO_API_KEY
);

});

