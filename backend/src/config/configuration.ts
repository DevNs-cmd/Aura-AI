export default () => ({
  port: parseInt(process.env.NODE_PORT || '3000', 10),
  fastApiUrl: process.env.FASTAPI_URL || 'http://localhost:8000',
  jwtSecret: process.env.JWT_SECRET || 'aura-secret-key',
});
