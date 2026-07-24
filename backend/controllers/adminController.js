const User = require("../models/User");


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