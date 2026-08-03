# AgriPilot System Architecture

## Overview
AgriPilot is an enterprise-grade Agricultural Intelligence Platform built on a Clean Architecture pattern using FastAPI (Backend) and Flutter (Frontend).

## Component Architecture
1. **API Gateway**: Nginx Reverse Proxy handles SSL, compression, and request routing.
2. **Backend Services**: FastAPI serves as the core synchronous/asynchronous handler.
3. **AI Orchestrator**: The central brain that delegates tasks to specialized intelligence modules (Weather, Market, Vision, Govt, Analytics) before calling the Google Gemini LLM.
4. **Caching Layer**: L1 (RAM) and L2 (Redis) caches prevent database and API stampedes.
5. **Background Workers**: Celery manages long-running tasks like nightly analytics and alert generation.
6. **Data Store**: PostgreSQL 15 stores all relational data (Users, Farms, Conversations, Alerts).

## Core Principles
- **Statelessness**: The API tier holds no session state. Everything is pushed to Redis or Postgres.
- **Determinism**: Intelligence modules fetch deterministic data (API responses) and provide them as context to the LLM. The LLM never hallucinates raw data.
- **Observability**: Every request is tagged with a `Trace ID` that flows through every function call.
