#!/bin/bash

# Swap App - Stop Script
# Kills both frontend and backend processes

echo "🛑 Stopping Swap App..."

# Kill backend (port 8000)
echo "Stopping backend (port 8000)..."
lsof -ti:8000 | xargs kill -9 2>/dev/null && echo "✓ Backend stopped" || echo "✓ No backend running"

# Kill frontend (port 3000)
echo "Stopping frontend (port 3000)..."
lsof -ti:3000 | xargs kill -9 2>/dev/null && echo "✓ Frontend stopped" || echo "✓ No frontend running"

echo "✅ All services stopped"
