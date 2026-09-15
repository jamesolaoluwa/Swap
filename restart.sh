#!/bin/bash

# Swap App - Restart Script
# Kills existing processes and restarts both frontend and backend

echo "🔄 Restarting Swap App..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kill processes on port 8000 (backend)
echo -e "${YELLOW}Stopping backend (port 8000)...${NC}"
lsof -ti:8000 | xargs kill -9 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend stopped${NC}"
else
    echo -e "${GREEN}✓ No backend process running${NC}"
fi

# Kill processes on port 3000 (frontend)
echo -e "${YELLOW}Stopping frontend (port 3000)...${NC}"
lsof -ti:3000 | xargs kill -9 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend stopped${NC}"
else
    echo -e "${GREEN}✓ No frontend process running${NC}"
fi

# Wait a moment for ports to be released
sleep 2

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Start backend
echo -e "${YELLOW}Starting backend...${NC}"
cd "$SCRIPT_DIR/wap-backend"
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend starting (PID: $BACKEND_PID)${NC}"

# Wait for backend to initialize
sleep 3

# Start frontend
echo -e "${YELLOW}Starting frontend...${NC}"
cd "$SCRIPT_DIR/swap_frontend"
flutter run -d chrome --web-port=3000 &
FRONTEND_PID=$!
echo -e "${GREEN}✓ Frontend starting (PID: $FRONTEND_PID)${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Swap App is starting!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "  Backend:  ${YELLOW}http://localhost:8000${NC}"
echo -e "  Frontend: ${YELLOW}http://localhost:3000${NC}"
echo ""
echo -e "Press ${RED}Ctrl+C${NC} to stop both services"

# Wait for both processes
wait
