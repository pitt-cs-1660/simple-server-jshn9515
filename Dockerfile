########################
# === Build Stage ===
########################
FROM python:3.12 AS builder

# Install uv (a fast Python package manager)
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency metadata
COPY pyproject.toml .
COPY README.md .

# Create and populate a virtual environment under /venv
RUN uv venv /venv && \
    uv pip install --python /venv/bin/python --no-cache-dir .

# Copy all source code for later stage
COPY . .

########################
# === Final Stage ===
########################
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy pre-built virtual environment from builder
COPY --from=builder /venv /venv

# Copy application source code
COPY . .

# Create a non-root user for security
# RUN useradd -m appuser
# USER appuser

# Ensure the venv’s Python binaries are used
ENV PATH="/venv/bin:$PATH"

# Expose port 8000
EXPOSE 8000

# Default command: run FastAPI via uvicorn
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]

ENV PYTHONPATH="/app"
