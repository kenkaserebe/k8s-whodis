# k8s-whodis/Dockerfile

# Use dhi.io/python:3-alpine-sfw-dev
FROM dhi.io/python:3-alpine-sfw-dev

# Set working directory
WORKDIR /app

# Install curl
RUN apk add --no-cache curl

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .
COPY templates/ ./templates

# Expose port 5000
EXPOSE 5000

# Health check to verify server is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:5000/health || exit 1

# Run the application
ENTRYPOINT [ "python", "app.py" ]