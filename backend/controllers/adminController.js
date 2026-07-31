const User = require("../models/User");
const Order = require("../models/Order");

// =============================
// GET PENDING BUSINESSES
// =============================
exports.getPendingBusinesses = async (req, res) => {

    try {

        const businesses = await User.find({
            role: "business_owner",
            "businessProfile.verificationStatus": "pending"
        }).select("-password -otp");


        res.json({
            success:true,
            businesses
        });


    } catch(err){

        res.status(500).json({
            success:false,
            message:err.message
        });

    }

};



// =============================
// APPROVE BUSINESS
// =============================
exports.approveBusiness = async (req,res)=>{

    try {

        const { userId } = req.params;


        const user = await User.findById(userId);


        if(!user){
            return res.status(404).json({
                success:false,
                message:"Business owner not found"
            });
        }
        user.businessProfile.verificationStatus = "approved";
        await user.save();


        res.json({
            success:true,
            message:"Business approved successfully."
        });


    } catch(err){

        res.status(500).json({
            success:false,
            message:err.message
        });

    }

};



// =============================
// REJECT BUSINESS
// =============================
exports.rejectBusiness = async(req,res)=>{

    try {

        const { userId } = req.params;

        const { reason } = req.body;


        const user = await User.findById(userId);


        if(!user){
            return res.status(404).json({
                success:false,
                message:"Business owner not found"
            });
        }

user.businessProfile.verificationStatus = "rejected";
user.businessProfile.rejectReason = reason;
await user.save();


        res.json({
            success:true,
            message:"Business rejected successfully."
        });


    } catch(err){

        res.status(500).json({
            success:false,
            message:err.message
        });

    }

};

// =============================
// GET ADMIN DASHBOARD STATS
// =============================
exports.getDashboardStats = async (req, res) => {
    try {

        // ==========================================
        // TOTAL USERS
        // ==========================================

        const totalUsers = await User.countDocuments({
            role: {
                $ne: "admin"
            }
        });


        // ==========================================
        // ACTIVE / APPROVED SHOPS
        // ==========================================

        const activeShops = await User.countDocuments({
            role: "business_owner",
            "businessProfile.verificationStatus":
                "approved"
        });


        // ==========================================
        // TOTAL ORDERS
        // ==========================================

        const totalOrders =
            await Order.countDocuments();


        // ==========================================
        // CURRENT MONTH REVENUE
        // ==========================================

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

                {
                    $match: {
                        createdAt: {
                            $gte: startOfMonth,
                            $lt: startOfNextMonth
                        },

                        status: "Delivered"
                    }
                },

                {
                    $group: {
                        _id: null,

                        totalRevenue: {
                            $sum: "$totalAmount"
                        }
                    }
                }
            ]);


        const monthlyRevenue =
            revenueResult.length > 0
                ? revenueResult[0].totalRevenue
                : 0;


        // ==========================================
        // RESPONSE
        // ==========================================

        res.json({
            success: true,

            stats: {
                totalUsers,
                activeShops,
                totalOrders,
                monthlyRevenue
            }
        });

    } catch (err) {

        console.error(
            "GET DASHBOARD STATS ERROR:",
            err
        );

        res.status(500).json({
            success: false,
            message: err.message
        });
    }
};