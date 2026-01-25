#!/bin/bash

echo "🏥 Alesqui Intelligence - Health Check"
echo "======================================"
echo ""

# Check Docker
echo "📦 Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi
echo "✅ Docker is installed: $(docker --version)"
echo ""

# Check Docker Compose
echo "📦 Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi
echo "✅ Docker Compose is installed: $(docker-compose --version)"
echo ""

# Check .env file
echo "📄 Checking .env file..."
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    echo "   Run: cp .env.example .env"
    exit 1
fi
echo "✅ .env file exists"
echo ""

# Check containers
echo "🐳 Checking containers..."
docker-compose ps
echo ""

# Check backend health
echo "🔍 Checking Backend health..."
BACKEND_HEALTH=$(curl -s http://localhost:8080/actuator/health || echo "ERROR")
if [[ $BACKEND_HEALTH == *"UP"* ]]; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend is not responding"
    echo "   Response: $BACKEND_HEALTH"
fi
echo ""

# Check frontend health
echo "🔍 Checking Frontend health..."
FRONTEND_HEALTH=$(curl -s http://localhost/health || echo "ERROR")
if [[ $FRONTEND_HEALTH == *"healthy"* ]]; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend is not responding"
    echo "   Response: $FRONTEND_HEALTH"
fi
echo ""

echo "======================================"
echo "✅ Health check complete!"
echo "======================================"
