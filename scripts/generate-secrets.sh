#!/bin/bash

echo "================================"
echo "Alesqui Intelligence"
echo "Secret Generator"
echo "================================"
echo ""

# Generate JWT Secret
echo "🔑 Generating JWT_SECRET..."
JWT_SECRET=$(openssl rand -base64 32)
echo "JWT_SECRET=$JWT_SECRET"
echo ""

# Generate MongoDB Password
echo "🔑 Generating MongoDB Password..."
MONGO_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-20)
echo "MONGODB_ROOT_PASSWORD=$MONGO_PASSWORD"
echo ""

echo "================================"
echo "✅ Secrets generated!"
echo "================================"
echo ""
echo "Copy these values to your .env file"
echo ""
