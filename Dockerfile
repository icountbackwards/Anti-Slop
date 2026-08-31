FROM python:3.11-slim

WORKDIR /app

COPY server.py .
COPY prompts ./prompts

RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    google-genai \
    pydantic

CMD exec uvicorn server:app \
    --host 0.0.0.0 \
    --port ${PORT:-8080}