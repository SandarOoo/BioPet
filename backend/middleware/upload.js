const multer = require("multer");

// ============================================================
// MULTER MEMORY STORAGE
// ============================================================
//
// Image will stay in memory as Buffer.
// We can convert it to Base64 and save it to MongoDB.
//
// This matches your Flutter imageBytes upload.
// ============================================================

const storage = multer.memoryStorage();

// ============================================================
// FILE FILTER
// ============================================================

const fileFilter = (req, file, cb) => {
  if (
    file.mimetype &&
    file.mimetype.startsWith("image/")
  ) {
    cb(null, true);
  } else {
    cb(
      new Error(
        "Only image files are allowed."
      ),
      false
    );
  }
};

// ============================================================
// MULTER CONFIGURATION
// ============================================================

const upload = multer({
  storage: storage,

  fileFilter: fileFilter,

  limits: {
    // Maximum image size = 5 MB
    fileSize: 5 * 1024 * 1024,
  },
});

module.exports = upload;