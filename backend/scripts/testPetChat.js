const { buildPetReply } = require("../services/petChatService");

const cases = [
  "ကြောင်လေးက အစာမစားဘူး ဘာလုပ်ရမလဲ",
  "ခွေးလေး ဝမ်းလျှောနေတယ်",
  "ကြောင် ဆီးသွားမရဘူး",
  "ခွေးလေးကို ဘယ်နှစ်ကြိမ် ရေချိုးပေးရမလဲ",
  "Python code ရေးပေးပါ",
];

for (const message of cases) {
  const result = buildPetReply(message);
  console.log("\nUSER:", message);
  console.log("INTENT:", result.intent);
  console.log("ANIMAL:", result.animal);
  console.log("EMERGENCY:", result.emergency);
  console.log("REPLY:", result.reply);
}
