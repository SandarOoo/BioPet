const mongoose = require("mongoose");


const productSchema = new mongoose.Schema({

    owner:{
        type: mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true
    },


    name:{
        type:String,
        required:true,
        trim:true
    },


    category:{
        type:String,
        enum:[
            "food",
            "toy",
            "accessory",
            "medicine",
            "grooming",
            "other"
        ],
        default:"other"
    },


    image:{
        type:String,
        default:""
    },


    price:{
        type:Number,
        required:true
    },


    stock:{
        type:Number,
        default:0
    },


    description:{
        type:String,
        default:""
    },


    isActive:{
        type:Boolean,
        default:true
    }


},
{
    timestamps:true
});


module.exports =
mongoose.model(
    "Product",
    productSchema
);