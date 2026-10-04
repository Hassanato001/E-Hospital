"""Vita Flask API skeleton (Phase 1).

Proves the auth wiring: every /api/v1 route requires a JWT issued by
the BetterAuth service (HS256, shared AUTH_JWT_SECRET for V1).
Full endpoints arrive in Phase 3.
"""
import os

import jwt
from flask import Flask, jsonify, request

app = Flask(__name__)
JWT_SECRET = os.environ.get("AUTH_JWT_SECRET", "dev_jwt_change_me")


def current_user():
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return None
    try:
        payload = jwt.decode(header[7:], JWT_SECRET, algorithms=["HS256"])
    except jwt.PyJWTError:
        return None
    return payload.get("sub")


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/api/v1/me")
def me():
    user = current_user()
    if not user:
        return jsonify(error="unauthorized"), 401
    return jsonify(user_id=user)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
