const redis = require("../config/redis");

function getCurrentMinute() {
  return Math.floor(Date.now() / 60000);
}

function rateLimit(options = {}) {
  const limit = options.limit || 60;
  const windowSeconds = options.windowSeconds || 60;

  return async function (req, res, next) {
    try {
      const userId = req.user?.id || req.ip;
      const route = req.originalUrl || req.url;
      const minute = getCurrentMinute();

      const key = `rate_limit:${userId}:${route}:${minute}`;

      const count = await redis.incr(key);

      if (count === 1) {
        await redis.expire(key, windowSeconds);
      }

      if (count > limit) {
        return res.status(429).json({
          success: false,
          message: "Too many requests. Please try again after some time.",
        });
      }

      next();
    } catch (error) {
      console.error("Rate limit error:", error);

      // Do not block app if Redis fails
      next();
    }
  };
}

module.exports = rateLimit;