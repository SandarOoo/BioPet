const express =
  require("express");

const multer =
  require("multer");

const {

  createPost,

  getPosts,

  toggleLike,

  addComment,

} =
  require(
    "../controllers/postController"
  );


const router =
  express.Router();


// =====================================================
// MULTER MEMORY STORAGE
// =====================================================

const storage =
  multer.memoryStorage();


// =====================================================
// MULTER
// =====================================================

const upload =
  multer({

    storage:

      storage,

    limits: {

      fileSize:

        10 *
        1024 *
        1024,

      files:

        10,

    },


    fileFilter:

      (
        req,

        file,

        cb

      ) => {


        const allowedTypes = [

          "image/jpeg",

          "image/jpg",

          "image/png",

          "image/gif",

          "image/webp",

        ];


        if (

          allowedTypes.includes(

            file.mimetype

          )

        ) {

          cb(

            null,

            true

          );

        } else {

          cb(

            new Error(

              "Only image files are allowed"

            )

          );

        }

      },

  });


// =====================================================
// CREATE POST
// POST /api/posts/create
// =====================================================

router.post(

  "/create",

  upload.array(

    "images",

    10

  ),

  createPost

);


// =====================================================
// GET POSTS
// GET /api/posts
// =====================================================

router.get(

  "/",

  getPosts

);


// =====================================================
// LIKE
// POST /api/posts/like
// =====================================================

router.post(

  "/like",

  toggleLike

);


// =====================================================
// COMMENT
// POST /api/posts/comment
// =====================================================

router.post(

  "/comment",

  addComment

);


// =====================================================
// EXPORT
// =====================================================

module.exports =
  router;