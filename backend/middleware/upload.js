const multer = require("multer");
const path = require("path");

// ============================================================
// STORAGE
// ============================================================

const storage = multer.memoryStorage();

// ============================================================
// FILE FILTER
// ============================================================

const fileFilter = (req, file, cb) => {
  console.log("======================================");
  console.log("UPLOAD FILE");
  console.log("Original Name:", file.originalname);
  console.log("Mimetype:", file.mimetype);
  console.log("Field Name:", file.fieldname);
  console.log("======================================");

  // Accept image MIME types
  if (file.mimetype && file.mimetype.startsWith("image/")) {
    cb(null, true);
    return;
  }

  // Fallback: check file extension
  const allowedExtensions = [
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
    ".gif",
  ];

  const extension = path
    .extname(file.originalname || "")
    .toLowerCase();

  if (allowedExtensions.includes(extension)) {
    cb(null, true);
    return;
  }

  cb(
    new Error(
      "Only image files are allowed."
    ),
    false
  );
};

// ============================================================
// MULTER
// ============================================================

const upload = multer({
  storage: storage,

  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB
  },

  fileFilter: fileFilter,
});

// ============================================================
// EXPORT
// ============================================================

module.exports = upload;