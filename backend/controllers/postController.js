const post = require("../models/post");
const {analyzePost} = require("../lib/services/geminiService.js");

//get posts

exports.getPosts = async (req, res) => {
try {
    const posts = async (req,res) => {
     res.json(posts);
    }
    } catch (err) {
              res.status(500).json({
                  message: err.message
              });
              }
}

exports.createPost = async (req,res) => {
    try{
        const {userId,name,test,images} = req.body;

        if(!text) {
            return res.status(400).json({
            message:"text required"});
        }

        const aiResult = await analyzePost(text);

        console.log("AI:" , aiResult);

        if(!aiResult.allowed || !aiResult.petRelated) {
            return res.status(403).json({
                message: "Post not allowed (not pet related)",
                ai: aiResult
            });
        }

        const post = new Post({
            userId,
            name,
            text,
            images: images || [],
            category: aiResult.category,
            tags:aiResult.tags,
            aiReview: aiResult
        });

        await post.save();

        res.status(201).json(post);
    } catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};

exports.toggleLike = async (req, res) => {
  try {
    const { postId, userId } = req.body;

    const post = await Post.findById(postId);

    if (!post) return res.status(404).json({ message: "Not found" });

    if (post.likes.includes(userId)) {
      post.likes = post.likes.filter(id => id !== userId);
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addComment = async (req, res) => {
  try {
    const { postId, userId, text } = req.body;

    const post = await Post.findById(postId);

    post.comments.push({ userId, text });

    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};