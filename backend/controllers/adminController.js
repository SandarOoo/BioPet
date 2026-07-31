const User = require("../models/User");
const Order = require("../models/Order");

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