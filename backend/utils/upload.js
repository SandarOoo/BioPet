const multer = require("multer");

const storage =
  multer.memoryStorage();

const allowedImageTypes =
  new Set([
    "image/jpeg",
    "image/png",
    "image/webp",
  ]);

const upload = multer({
  storage,

  limits: {
    fileSize:
      5 * 1024 * 1024,

    files: 10,
  },

  fileFilter: (
    req,
    file,
    callback
  ) => {
    if (
      !allowedImageTypes.has(
        file.mimetype
      )
    ) {
      const error =
        new multer.MulterError(
          "LIMIT_UNEXPECTED_FILE",
          file.fieldname
        );

      error.message =
        "Only JPG, JPEG, PNG and WEBP images are allowed.";

      return callback(error);
    }

    callback(null, true);
  },
});

module.exports = upload;