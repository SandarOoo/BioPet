// services/ruleBasedModeration.js

// =====================================================
// ALLOWED DOG / CAT KEYWORDS
// =====================================================

const petKeywords = [
  // =========================
  // DOG - ENGLISH
  // =========================
  "dog",
  "dogs",
  "puppy",
  "puppies",

  // =========================
  // CAT - ENGLISH
  // =========================
  "cat",
  "cats",
  "kitten",
  "kittens",

  // =========================
  // DOG / CAT - MYANMAR
  // =========================
  "ခွေး",
  "ခွေးလေး",
  "ခွေးကလေး",
  "ခွေးတွေ",
  "ခွေးများ",

  "ကြောင်",
  "ကြောင်လေး",
  "ကြောင်ကလေး",
  "ကြောင်တွေ",
  "ကြောင်များ",

  // =========================
  // PET RELATED - ENGLISH
  // =========================
  "pet",
  "pets",
  "veterinary",
  "vet",
  "clinic",
  "vaccination",
  "vaccine",
  "grooming",
  "adoption",
  "adopt",

  // =========================
  // PET RELATED - MYANMAR
  // =========================
  "အိမ်မွေးတိရစ္ဆာန်",
  "အိမ်မွေးတိရစ္ဆာန်လေး",
  "တိရစ္ဆာန်ဆေးခန်း",
  "ဆေးခန်း",
  "ကာကွယ်ဆေး",
  "မွေးစား",
  "မွေးစားခြင်း",
  "အလှပြင်",
];

// =====================================================
// PROFANITY
// =====================================================

const profanityWords = [
  "fuck",
  "fucking",
  "shit",
  "bitch",
  "asshole",
];

// =====================================================
// ANIMAL ABUSE
// =====================================================

const animalAbusePhrases = [
  "kill animal",
  "kill animals",
  "kill dog",
  "kill cat",
  "hurt animal",
  "hurt animals",
  "hurt dog",
  "hurt cat",
  "animal abuse",
  "animal cruelty",
  "abuse animal",
  "abuse animals",
];

// =====================================================
// VIOLENCE
// =====================================================

const violenceWords = [
  "murder",
  "murdering",
  "torture",
  "torturing",
  "violence",
  "violent",
];

// =====================================================
// NORMALIZE
// =====================================================

const normalizeText = (text = "") => {
  return text
    .toLowerCase()
    .normalize("NFC")
    .replace(/\s+/g, " ")
    .trim();
};

// =====================================================
// MAIN MODERATION
// =====================================================

const moderatePetPost = ({
  text = "",
  images = [],
}) => {

  const normalizedText =
    normalizeText(text);

  // ===================================================
  // EMPTY POST
  // ===================================================

  if (
    normalizedText === "" &&
    images.length === 0
  ) {
    return {
      allowed: false,
      category: "empty_post",
      reason:
        "Post must contain text or at least one image.",
    };
  }

  // ===================================================
  // PROFANITY
  // ===================================================

  const hasProfanity =
    profanityWords.some((word) =>
      normalizedText.includes(word)
    );

  if (hasProfanity) {
    return {
      allowed: false,
      category: "profanity",
      reason:
        "Post contains inappropriate or abusive language.",
    };
  }

  // ===================================================
  // ANIMAL ABUSE
  // ===================================================

  const hasAnimalAbuse =
    animalAbusePhrases.some((phrase) =>
      normalizedText.includes(phrase)
    );

  if (hasAnimalAbuse) {
    return {
      allowed: false,
      category: "animal_abuse",
      reason:
        "Post contains content related to animal abuse or cruelty.",
    };
  }

  // ===================================================
  // VIOLENCE
  // ===================================================

  const hasViolence =
    violenceWords.some((word) =>
      normalizedText.includes(word)
    );

  if (hasViolence) {
    return {
      allowed: false,
      category: "violence",
      reason:
        "Post contains violent or harmful content.",
    };
  }

  // ===================================================
  // DOG / CAT CONTENT CHECK
  // ===================================================

  if (normalizedText !== "") {

    const isDogOrCatRelated =
      petKeywords.some((keyword) =>
        normalizedText.includes(keyword)
      );

    if (!isDogOrCatRelated) {
      return {
        allowed: false,
        category: "not_pet_related",
        reason:
          "Only dog and cat related content is allowed.",
      };
    }
  }

  // ===================================================
  // ALLOWED
  // ===================================================

  return {
    allowed: true,
    category: null,
    reason: null,
  };
};

module.exports = {
  moderatePetPost,
};