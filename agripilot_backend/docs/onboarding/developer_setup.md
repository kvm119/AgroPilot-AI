# Developer Setup Guide

## Prerequisites
- Docker & Docker Compose
- Python 3.11+
- Git

## Initial Setup
1. **Clone the Repository**
   ```bash
   git clone https://github.com/agripilot/agripilot_backend.git
   cd agripilot_backend
   ```

2. **Configure Environments**
   ```bash
   cp .env.example .env
   # Add your Google Gemini API Key and OpenWeather API Key to the .env file
   ```

3. **Start the Infrastructure**
   ```bash
   docker-compose up -d
   ```
   This spins up FastAPI, Postgres, Redis, Celery, and Nginx.

4. **Seed the Database (Optional)**
   If you want to view a pre-populated dashboard:
   ```bash
   docker-compose exec api python scripts/seed_demo_data.py
   ```

## Development Workflow
- The API is available at `http://localhost:8000`.
- The auto-generated Swagger UI is at `http://localhost:8000/docs`.
- Run tests via `docker-compose exec api pytest`.
