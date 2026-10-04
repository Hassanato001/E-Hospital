// Vita auth service (Phase 1): BetterAuth email/password + JWTs for Flask.
// Flask validates the HS256 token with the shared AUTH_JWT_SECRET.
import { betterAuth } from "better-auth";
import { jwt } from "better-auth/plugins";
import pg from "pg";

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });

export const auth = betterAuth({
  secret: process.env.BETTER_AUTH_SECRET,
  baseURL: process.env.BETTER_AUTH_URL || "http://localhost:3001",
  database: pool,
  emailAndPassword: { enabled: true },
  plugins: [jwt({ jwt: { definePayload: ({ user }) => ({ sub: user.id }) } })],
});

console.log("auth service configured (start wiring to HTTP in Phase 3)");
