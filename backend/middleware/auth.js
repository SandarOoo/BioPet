const jwt = require("jsonwebtoken");
const User = require("../models/User");

const protect = async (
  req,
  res,
  next
) => {
  try {
    let token;

    const authHeader =
      req.headers.authorization;

    console.log(
      "AUTH HEADER:",
      authHeader
        ? "Bearer token received"
        : "No Authorization header"
    );

    if (
      authHeader &&
      authHeader.startsWith("Bearer ")
    ) {
      token =
        authHeader.split(" ")[1];
    }

    if (
      !token ||
      token.trim() === ""
    ) {
      return res.status(401).json({
        success: false,
        message:
          "No token provided",
      });
    }

    const decoded =
      jwt.verify(
        token,
        process.env.JWT_SECRET
      );

    console.log(
      "DECODED TOKEN:",
      decoded
    );

    const user =
      await User.findById(
        decoded.id
      ).select("-password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message:
          "User not found",
      });
    }

    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message:
          "Account blocked",
      });
    }

    req.user = user;

    next();

  } catch (error) {
    console.error(
      "AUTH ERROR:",
      error.message
    );

    return res.status(401).json({
      success: false,
      message:
        "Token invalid or expired",
    });
  }
};

const adminOnly = (
  req,
  res,
  next
) => {
  if (
    !req.user ||
    req.user.role !== "admin"
  ) {
    return res.status(403).json({
      success: false,
      message:
        "Admin only",
    });
  }

  next();
};

const businessOnly = (
  req,
  res,
  next
) => {
  if (
    !req.user ||
    ![
      "business_owner",
      "admin",
    ].includes(req.user.role)
  ) {
    return res.status(403).json({
      success: false,
      message:
        "Business owner only",
    });
  }

  next();
};

module.exports = {
  protect,
  adminOnly,
  businessOnly,
};