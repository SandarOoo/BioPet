const mongoose = require("mongoose");

// ==========================================
// COMMENT SCHEMA
// ==========================================

const commentSchema =
  new mongoose.Schema({

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
// AI REVIEW SCHEMA
// ==========================================

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


// ==========================================
// POST SCHEMA
// ==========================================

const postSchema =
  new mongoose.Schema(

    {

      // ========================================
      // USER
      // ========================================

      userId: {

        type: String,

        required: true,

      },


      // ========================================
      // NAME
      // ========================================

      name: {

        type: String,

        default:
          "Anonymous",

      },


      // ========================================
      // TEXT
      // TEXT IS OPTIONAL
      // BECAUSE IMAGE-ONLY POST IS ALLOWED
      // ========================================

      text: {

        type: String,

        default: "",

      },


      // ========================================
      // IMAGES
      // ========================================

      images: [

        {

          data: {

            type: String,

          },

          contentType: {

            type: String,

          },

          filename: {

            type: String,

          },

        },

      ],


      // ========================================
      // AI REVIEW
      // ========================================

      aiReview:
        aiReviewSchema,


      // ========================================
      // LIKES
      // ========================================

      likes: [

        {

          type: String,

        },

      ],


      // ========================================
      // COMMENTS
      // ========================================

      comments: [

        commentSchema,

      ],

    },

    {

      timestamps: true,

    }

  );


// ==========================================
// PREVENT OVERWRITE MODEL ERROR
// ==========================================

module.exports =

  mongoose.models.Post ||

  mongoose.model(
    "Post",
    postSchema
  );