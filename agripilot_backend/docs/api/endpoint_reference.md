# Endpoint Reference

For interactive testing, please navigate to `http://localhost:8000/docs` while the backend is running.

## 1. Copilot API
- `POST /api/v1/copilot/chat`
- Accepts a natural language query and context from the Flutter app.
- Orchestrates tools and streams back an intelligent AI response.

## 2. Vision API
- `POST /api/v1/vision/scan`
- Accepts a `multipart/form-data` image upload.
- Returns bounding boxes, disease classification, and confidence scores.

## 3. Alerts & Notifications
- `GET /api/v1/alerts`
- Returns a paginated list of active weather, market, and farm alerts for the user.
