const Post = require("../models/Post");

const {
  analyzePost,
} = require("../services/geminiService");

console.log(
  "ANALYZE POST TYPE =>",
  typeof analyzePost
);
// =====================================================
// CREATE POST
// TEXT ONLY
// IMAGE ONLY
// TEXT + IMAGE
// =====================================================

const createPost =
  async (
    req,
    res
  ) => {

    try {

      console.log(
        "================================="
      );

      console.log(
        "📥 CREATE POST REQUEST"
      );

      console.log(
        "================================="
      );


      // =================================================
      // GET BODY
      // =================================================

      const {

        userId,

        name,

        text,

      } =
        req.body;


      // =================================================
      // GET FILES
      // =================================================

      const files =
        req.files || [];


      // =================================================
      // CLEAN TEXT
      // =================================================

      const cleanText =
        text
          ? text.trim()
          : "";


      // =================================================
      // LOG REQUEST
      // =================================================

      console.log(
        "👤 USER ID:",
        userId
      );

      console.log(
        "👤 NAME:",
        name
      );

      console.log(
        "📝 TEXT:",
        cleanText
      );

      console.log(
        "🖼️ IMAGE COUNT:",
        files.length
      );


      // =================================================
      // VALIDATE USER ID
      // =================================================

      if (
        !userId ||
        userId.trim().length === 0
      ) {

        return res.status(
          400
        ).json({

          success: false,

          message:
            "User ID is required",

        });

      }


      // =================================================
      // VALIDATE
      // TEXT OR IMAGE REQUIRED
      // =================================================

      if (

        cleanText.length === 0 &&

        files.length === 0

      ) {

        return res.status(
          400
        ).json({

          success: false,

          message:
            "Post text or image is required",

        });

      }


      // =================================================
      // START GEMINI
      // =================================================

      console.log(
        "================================="
      );

      console.log(
        "🤖 START AI MODERATION"
      );

      console.log(
        "================================="
      );


      const aiResult =
        await analyzePost(

          cleanText,

          files

        );


      console.log(
        "🤖 AI RESULT:",
        aiResult
      );


      // =================================================
      // CHECK AI RESULT
      // =================================================

      if (

        aiResult &&

        aiResult.allowed === false

      ) {

        console.log(
          "🚫 POST BLOCKED BY AI"
        );


        return res.status(
          400
        ).json({

          success: false,

          message:

            aiResult.reason ||

            "Post blocked by AI moderation",

          ai:
            aiResult,

        });

      }


      // =================================================
      // PROCESS IMAGES
      // =================================================

      const images = [];


      if (
        files.length > 0
      ) {

        for (
          const file of files
        ) {

          console.log(
            "📸 PROCESSING IMAGE:",
            file.originalname
          );


          images.push({

            data:

              `data:${file.mimetype};base64,` +

              file.buffer.toString(
                "base64"
              ),

            contentType:

              file.mimetype,

            filename:

              file.originalname,

          });

        }

      }


      // =================================================
      // CREATE POST
      // =================================================

      const post =
        new Post({

          userId:

            userId,

          name:

            name ||
            "Anonymous",

          text:

            cleanText,

          images:

            images,

          aiReview:

            aiResult,

          likes: [],

          comments: [],

        });


      // =================================================
      // SAVE POST
      // =================================================

      const savedPost =
        await post.save();


      console.log(
        "================================="
      );

      console.log(
        "✅ POST SAVED SUCCESSFULLY"
      );

      console.log(
        "POST ID:",
        savedPost._id
      );

      console.log(
        "================================="
      );


      // =================================================
      // RESPONSE
      // =================================================

      return res.status(
        201
      ).json({

        success: true,

        message:
          "Post created successfully",

        post:
          savedPost,

        ai:
          aiResult,

      });


    } catch (
      error
    ) {


      console.error(
        "================================="
      );

      console.error(
        "❌ CREATE POST ERROR"
      );

      console.error(
        error
      );

      console.error(
        "================================="
      );


      return res.status(
        500
      ).json({

        success: false,

        message:
          error.message,

      });

    }

  };


// =====================================================
// GET POSTS
// =====================================================

const getPosts =
  async (
    req,
    res
  ) => {

    try {

      const posts =

        await Post

          .find()

          .sort({

            createdAt:
              -1,

          });


      return res.json({

        success: true,

        posts:

          posts,

      });


    } catch (
      error
    ) {

      console.error(

        "GET POSTS ERROR:",

        error

      );


      return res.status(
        500
      ).json({

        success: false,

        message:
          error.message,

      });

    }

  };


// =====================================================
// LIKE POST
// =====================================================

const toggleLike =
  async (
    req,
    res
  ) => {

    try {

      const {

        postId,

        userId,

      } =
        req.body;


      const post =

        await Post.findById(

          postId

        );


      if (
        !post
      ) {

        return res.status(
          404
        ).json({

          success: false,

          message:
            "Post not found",

        });

      }


      if (

        post.likes.includes(

          userId

        )

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


      await post.save();


      return res.json({

        success: true,

        likes:

          post.likes.length,

        post:

          post,

      });


    } catch (
      error
    ) {

      return res.status(
        500
      ).json({

        success: false,

        message:
          error.message,

      });

    }

  };


// =====================================================
// ADD COMMENT
// =====================================================

const addComment =
  async (
    req,
    res
  ) => {

    try {

      const {

        postId,

        userId,

        text,

      } =
        req.body;


      // =================================================
      // VALIDATE TEXT
      // =================================================

      if (

        !text ||

        text.trim().length === 0

      ) {

        return res.status(
          400
        ).json({

          success: false,

          message:
            "Comment text is required",

        });

      }


      // =================================================
      // FIND POST
      // =================================================

      const post =

        await Post.findById(

          postId

        );


      if (
        !post
      ) {

        return res.status(
          404
        ).json({

          success: false,

          message:
            "Post not found",

        });

      }


      // =================================================
      // ADD COMMENT
      // =================================================

      post.comments.push({

        userId:

          userId ||
          "guest",

        text:

          text.trim(),

      });


      await post.save();


      return res.json({

        success: true,

        comments:

          post.comments,

      });


    } catch (
      error
    ) {

      return res.status(
        500
      ).json({

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