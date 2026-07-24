const mongoose = require("mongoose");
const dotenv = require("dotenv");

const Product = require("../models/Product");
const User = require("../models/User");

dotenv.load();


mongoose.connect(process.env.MONGO_URI)
.then(async()=>{


console.log("Mongo Connected");


// find business owner

const owner =
await User.findOne({
    role:"business_owner"
});


if(!owner){

console.log("No business owner found");
process.exit();

}



await Product.deleteMany({
    owner:owner._id
});



const products=[


{
owner:owner._id,

name:"Royal Canin Dog Food",

category:"Food",

price:25000,

stock:50,

description:"Premium dog food",

image:"https://example.com/dogfood.png"

},



{
owner:owner._id,

name:"Cat Toy",

category:"Toy",

price:8000,

stock:30,

description:"Colorful cat toy",

image:"https://example.com/cattoy.png"

},



{
owner:owner._id,

name:"Pet Leash",

category:"Accessory",

price:6000,

stock:25,

description:"Strong pet leash",

image:"https://example.com/leash.png"

},



{
owner:owner._id,

name:"Pet Shampoo",

category:"Grooming",

price:12000,

stock:40,

description:"Healthy pet shampoo",

image:"https://example.com/shampoo.png"

},



{
owner:owner._id,

name:"Soft Pet Bed",

category:"Accessory",

price:35000,

stock:10,

description:"Comfortable pet bed",

image:"https://example.com/bed.png"

}


];



await Product.insertMany(products);



console.log("Products inserted");


process.exit();



})
.catch(err=>{

console.log(err);

});