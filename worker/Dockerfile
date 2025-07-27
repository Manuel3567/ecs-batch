# Use a minimal base image
FROM public.ecr.aws/docker/library/python:3.13-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

# Create a non-root user
RUN adduser --disabled-password --gecos '' appuser

# Set work directory
WORKDIR /app

# Install dependencies separately to leverage Docker caching
COPY requirements.txt .
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && apt-get purge -y build-essential \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy source code
COPY . .

# Switch to non-root user
USER appuser

# Use exec form for CMD
CMD ["python", "main.py"]