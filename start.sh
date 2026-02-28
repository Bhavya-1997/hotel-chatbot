#!/bin/bash

echo "=== Starting Hotel Booking Chatbot ==="

# Step 1: Start Rasa Actions Server in background
echo "[1/3] Starting Rasa Actions Server on port 5055..."
cd /app && rasa run actions --port 5055 &

# Give actions server time to start
sleep 20

# Step 2: Start Rasa Server in background
echo "[2/3] Starting Rasa Server on port 5005..."
cd /app && rasa run --enable-api --cors "*" --port 5005 --endpoints /app/endpoints.yml --model /app/models &

# Wait until Rasa server is fully ready (loads TensorFlow model - takes 1-2 min)
echo "Waiting for Rasa to load model..."
until curl -s http://localhost:5005/status > /dev/null 2>&1; do
    echo "  Still loading Rasa model..."
    sleep 10
done
echo "Rasa server is ready!"

# Step 3: Start Flask web app on port 7860 (required by Hugging Face Spaces)
echo "[3/3] Starting Flask Web App on port 7860..."
cd /app && gunicorn --bind 0.0.0.0:7860 --timeout 300 --workers 1 app:app
