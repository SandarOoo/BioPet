const {
  ASK_ANIMAL_REPLY,
  EMERGENCY_RULES,
  GREETING_REPLY,
  GREETING_TERMS,
  HELP_REPLY,
  HELP_TERMS,
  KNOWLEDGE_ITEMS,
  REJECTION_REPLY,
  UNRELATED_TERMS,
  UNKNOWN_PET_REPLY,
} = require("../data/petKnowledge");

const ANIMAL_ALIASES = {
  cat: ["ကြောင်", "ကြောင်လေး", "cat", "cats", "kitten", "kitty"],
  dog: ["ခွေး", "ခွေးလေး", "dog", "dogs", "puppy", "puppies"],
};

const GENERIC_PET_TERMS = [
  "အိမ်မွေးတိရစ္ဆာန်",
  "တိရစ္ဆာန်လေး",
  "တိရစ္ဆာန်",
  "pet",
  "pets",
];

function normalizeText(value) {
  return String(value || "")
    .normalize("NFKC")
    .toLowerCase()
    .replace(/[\u200B-\u200D\uFEFF]/g, "")
    .replace(/[“”‘’]/g, '"')
    .replace(/[၊။!?.,;:()[\]{}<>/\\|@#$%^&*_+=~`-]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function includesAny(text, terms) {
  return terms.some((term) => text.includes(normalizeText(term)));
}

function isGreeting(text) {
  return GREETING_TERMS.some((term) => {
    const normalizedTerm = normalizeText(term);
    return text === normalizedTerm || text.startsWith(`${normalizedTerm} `);
  });
}

function detectAnimal(text) {
  const hasCat = includesAny(text, ANIMAL_ALIASES.cat);
  const hasDog = includesAny(text, ANIMAL_ALIASES.dog);

  if (hasCat && hasDog) return "both";
  if (hasCat) return "cat";
  if (hasDog) return "dog";
  if (includesAny(text, GENERIC_PET_TERMS)) return "pet";
  return null;
}

function findEmergency(text) {
  return EMERGENCY_RULES.find((rule) => includesAny(text, rule.phrases)) || null;
}

function scoreKnowledgeItem(text, item, animal) {
  if (
    animal &&
    animal !== "pet" &&
    animal !== "both" &&
    Array.isArray(item.animals) &&
    !item.animals.includes(animal)
  ) {
    return -1;
  }

  let score = 0;

  for (const phrase of item.phrases || []) {
    if (text.includes(normalizeText(phrase))) {
      score += 6;
    }
  }

  for (const keyword of item.keywords || []) {
    if (text.includes(normalizeText(keyword))) {
      score += 2;
    }
  }

  return score;
}

function selectReply(item, animal) {
  if (item.replies) {
    if (animal === "cat" && item.replies.cat) return item.replies.cat;
    if (animal === "dog" && item.replies.dog) return item.replies.dog;
    return item.replies.cat || item.replies.dog || item.reply;
  }

  return item.reply;
}

function buildPetReply(rawMessage) {
  const message = normalizeText(rawMessage);

  if (!message) {
    return {
      reply: "မေးခွန်းတစ်ခု ရေးပေးပါ။",
      intent: "empty_message",
      animal: null,
      emergency: false,
    };
  }

  if (message.length > 800) {
    return {
      reply: "မေးခွန်းက ရှည်လွန်းပါတယ်။ အဓိကလက္ခဏာနဲ့ ဖြစ်နေတဲ့အချိန်ကို အတိုချုံးရေးပေးပါ။",
      intent: "message_too_long",
      animal: null,
      emergency: false,
    };
  }

  if (isGreeting(message)) {
    return {
      reply: GREETING_REPLY,
      intent: "greeting",
      animal: null,
      emergency: false,
    };
  }

  if (includesAny(message, HELP_TERMS)) {
    return {
      reply: HELP_REPLY,
      intent: "help",
      animal: null,
      emergency: false,
    };
  }

  if (includesAny(message, UNRELATED_TERMS)) {
    return {
      reply: REJECTION_REPLY,
      intent: "unrelated",
      animal: null,
      emergency: false,
    };
  }

  const emergencyRule = findEmergency(message);
  if (emergencyRule) {
    return {
      reply: emergencyRule.reply,
      intent: emergencyRule.intent,
      animal: detectAnimal(message),
      emergency: true,
    };
  }

  const animal = detectAnimal(message);

  let bestItem = null;
  let bestScore = 0;

  for (const item of KNOWLEDGE_ITEMS) {
    const score = scoreKnowledgeItem(message, item, animal);
    if (score > bestScore) {
      bestScore = score;
      bestItem = item;
    }
  }

  // A recognizable pet-care symptom was mentioned, but the animal was omitted.
  if (bestItem && !animal) {
    return {
      reply: ASK_ANIMAL_REPLY,
      intent: "animal_required",
      animal: null,
      emergency: false,
    };
  }

  if (bestItem) {
    return {
      reply: selectReply(bestItem, animal),
      intent: bestItem.intent,
      animal,
      emergency: false,
    };
  }

  if (animal) {
    return {
      reply: UNKNOWN_PET_REPLY,
      intent: "unknown_pet_question",
      animal,
      emergency: false,
    };
  }

  return {
    reply: REJECTION_REPLY,
    intent: "unrelated",
    animal: null,
    emergency: false,
  };
}

module.exports = {
  buildPetReply,
  detectAnimal,
  normalizeText,
};
