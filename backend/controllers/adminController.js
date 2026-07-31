const User = require("../models/User");
const Order = require("../models/Order");
const Product = require("../models/Product");

// =====================================================
// GET PENDING BUSINESSES
// =====================================================

exports.getPendingBusinesses = async (req, res) => {
    try {

        const businesses = await User.find({
            role: "business_owner",
            "businessProfile.verificationStatus": "pending",
        }).select("-password -otp");

        return res.status(200).json({
            success: true,
            businesses,
        });

    } catch (err) {

        console.error(
            "GET PENDING BUSINESSES ERROR:",
            err
        );

        return res.status(500).json({
            success: false,
            message: err.message,
        });
    }
};


// =====================================================
// APPROVE BUSINESS
// =====================================================

exports.approveBusiness = async (req, res) => {
    try {

        const { userId } = req.params;

        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "Business owner not found",
            });
        }

        // Update verification status
        user.businessProfile.verificationStatus =
            "approved";

        await user.save();

        return res.status(200).json({
            success: true,
            message: "Business approved successfully.",
        });

    } catch (err) {

        console.error(
            "APPROVE BUSINESS ERROR:",
            err
        );

        return res.status(500).json({
            success: false,
            message: err.message,
        });
    }
};


// =====================================================
// REJECT BUSINESS
// =====================================================

exports.rejectBusiness = async (req, res) => {
    try {

        const { userId } = req.params;

        const { reason } = req.body;

        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "Business owner not found",
            });
        }

        // Update verification status
        user.businessProfile.verificationStatus =
            "rejected";

        // Save rejection reason
        user.businessProfile.rejectReason =
            reason || "";

        await user.save();

        return res.status(200).json({
            success: true,
            message: "Business rejected successfully.",
        });

    } catch (err) {

        console.error(
            "REJECT BUSINESS ERROR:",
            err
        );

        return res.status(500).json({
            success: false,
            message: err.message,
        });
    }
};


// =====================================================
// GET ADMIN DASHBOARD STATS
// =====================================================

exports.getDashboardStats = async (req, res) => {
    try {

        // =================================================
        // TOTAL USERS
        // =================================================

        const totalUsers =
            await User.countDocuments({
                role: {
                    $ne: "admin",
                },
            });


        // =================================================
        // ACTIVE / APPROVED SHOPS
        // =================================================

        const activeShops =
            await User.countDocuments({
                role: "business_owner",
                "businessProfile.verificationStatus":
                    "approved",
            });


        // =================================================
        // TOTAL ORDERS
        // =================================================

        const totalOrders =
            await Order.countDocuments();


        // =================================================
        // CURRENT MONTH REVENUE
        // =================================================

        const now = new Date();

        const startOfMonth =
            new Date(
                now.getFullYear(),
                now.getMonth(),
                1
            );

        const startOfNextMonth =
            new Date(
                now.getFullYear(),
                now.getMonth() + 1,
                1
            );


        const revenueResult =
            await Order.aggregate([

                // Only current month
                // delivered orders
                {
                    $match: {
                        createdAt: {
                            $gte: startOfMonth,
                            $lt: startOfNextMonth,
                        },

                        status: "Delivered",
                    },
                },

                // Calculate total revenue
                {
                    $group: {
                        _id: null,

                        totalRevenue: {
                            $sum: "$totalAmount",
                        },
                    },
                },
            ]);


        const monthlyRevenue =
            revenueResult.length > 0
                ? revenueResult[0].totalRevenue
                : 0;


        // =================================================
        // RESPONSE
        // =================================================

        return res.status(200).json({
            success: true,

            stats: {
                totalUsers,
                activeShops,
                totalOrders,
                monthlyRevenue,
            },
        });

    } catch (err) {

        console.error(
            "GET DASHBOARD STATS ERROR:",
            err
        );

        return res.status(500).json({
            success: false,
            message: err.message,
        });
    }
};


// =====================================================
// GET ALL ORDERS - ADMIN
// =====================================================

exports.getAllOrders = async (req, res) => {
    try {

        // Get all orders
        const orders =
            await Order.find()

                // Customer information
                .populate(
                    "customer",
                    "name email phone"
                )

                // Product information
                .populate(
                    "items.product"
                )

                // Latest orders first
                .sort({
                    createdAt: -1,
                });


        // =================================================
        // RESPONSE
        // =================================================

        return res.status(200).json({
            success: true,
            orders,
        });

    } catch (err) {

        console.error(
            "GET ALL ORDERS ERROR:",
            err
        );

        return res.status(500).json({
            success: false,
            message: err.message,
        });
    }
};


// =====================================================
// GET ALL PRODUCTS - ADMIN
// =====================================================
exports.getAllProductsAdmin = async (req, res) => {
  try {
    const products = await Product.find()
      .populate(
        "owner",
        "name email businessProfile"
      )
      .sort({
        createdAt: -1,
      });

    return res.status(200).json({
      success: true,
      products,
    });
  } catch (err) {
    console.error(
      "GET ALL PRODUCTS ADMIN ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// =====================================================
// DELETE PRODUCT - ADMIN
// =====================================================
exports.deleteProductAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    const product =
      await Product.findByIdAndDelete(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Product deleted successfully.",
    });
  } catch (err) {
    console.error(
      "DELETE PRODUCT ADMIN ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// =====================================================
// GET ALL USERS - ADMIN
// =====================================================

exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find()
      .select("-password -otp -otpExpiresAt -lastOtpSentAt")
      .sort({
        createdAt: -1,
      });

    return res.status(200).json({
      success: true,
      users,
    });
  } catch (err) {
    console.error(
      "GET ALL USERS ADMIN ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// =====================================================
// CHANGE USER ROLE - ADMIN
// =====================================================

exports.changeUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    // Valid roles
    const allowedRoles = [
      "user",
      "business_owner",
      "admin",
    ];

    if (!role || !allowedRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid role. Allowed roles: user, business_owner, admin.",
      });
    }

    const user = await User.findById(id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    // Prevent admin from changing their own role
    if (user._id.toString() === req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message:
          "You cannot change your own admin role.",
      });
    }

    user.role = role;

    await user.save();

    return res.status(200).json({
      success: true,
      message:
        "User role updated successfully.",
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    console.error(
      "CHANGE USER ROLE ADMIN ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// =====================================================
// DELETE USER PERMANENTLY - ADMIN
// =====================================================

exports.deleteUserAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    // Prevent admin from deleting themselves
    if (user._id.toString() === req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message:
          "You cannot delete your own admin account.",
      });
    }

    await User.findByIdAndDelete(id);

    return res.status(200).json({
      success: true,
      message:
        "User permanently deleted successfully.",
    });
  } catch (err) {
    console.error(
      "DELETE USER ADMIN ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

exports.getPaymentOverview = async (req, res) => {
  try {
    const orders = await Order.find({});

    const paymentMap = {
      COD: {
        name: "Cash on Delivery",
        amount: 0,
        pending: 0,
        paid: 0,
        failed: 0,
      },
      KBZ_PAY: {
        name: "KBZPay",
        amount: 0,
        pending: 0,
        paid: 0,
        failed: 0,
      },
      WAVE_PAY: {
        name: "WavePay",
        amount: 0,
        pending: 0,
        paid: 0,
        failed: 0,
      },
      AYA_PAY: {
        name: "AYA Pay",
        amount: 0,
        pending: 0,
        paid: 0,
        failed: 0,
      },
      CARD: {
        name: "Card",
        amount: 0,
        pending: 0,
        paid: 0,
        failed: 0,
      },
    };

    for (const order of orders) {
      const method = order.paymentMethod;
      const status = order.paymentStatus;

      if (!paymentMap[method]) {
        continue;
      }

      const amount = Number(order.totalAmount) || 0;

      paymentMap[method].amount += amount;

      if (status === "Pending") {
        paymentMap[method].pending += 1;
      }

      if (status === "Paid") {
        paymentMap[method].paid += 1;
      }

      if (status === "Failed") {
        paymentMap[method].failed += 1;
      }
    }

    const payments = Object.values(paymentMap);

    const totalAmount = payments.reduce(
      (sum, payment) => sum + payment.amount,
      0
    );

    const result = payments.map((payment) => ({
      ...payment,
      percentage:
        totalAmount > 0
          ? payment.amount / totalAmount
          : 0,
    }));

    res.status(200).json({
      success: true,
      payments: result,
      totalAmount,
    });
  } catch (error) {
    console.error(
      "GET PAYMENT OVERVIEW ERROR:",
      error
    );

    res.status(500).json({
      success: false,
      message:
        "Failed to load payment overview",
      error: error.message,
    });
  }
};

