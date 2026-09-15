#!/bin/bash
# Setup script for $wap backend

set -e

echo "🚀 Setting up $wap backend..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << 'EOF'
# Azure OpenAI (for embeddings)
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_KEY=your-key-here
AZURE_OPENAI_API_VERSION=2024-02-01
AZURE_EMBEDDING_DEPLOYMENT=text-embedding-3-small

# Azure AI Search (for vector storage)
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_API_KEY=your-key-here
AZURE_SEARCH_INDEX=swap-users

# App
APP_NAME=$wap
DEBUG=false
EOF
    echo "✅ .env file created"
else
    echo "ℹ️  .env file already exists"
fi

# Start services
echo "🐳 Starting Docker services..."
docker-compose up -d redis

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "📋 Service URLs:"
    echo "   - API: http://localhost:8000"
    echo "   - API Docs: http://localhost:8000/docs"
    echo "   - Redis: localhost:6379"
    echo ""
    echo "🎉 Setup complete! You can now use the API."
    echo ""
    echo "⚠️  Note: Make sure to configure Azure OpenAI and Azure AI Search in your .env file"
    echo ""
    echo "To stop services: docker-compose down"
    echo "To view logs: docker-compose logs -f"
else
    echo "❌ Some services failed to start. Check logs with: docker-compose logs"
    exit 1
fi

