# Stage 1: Install dependencies
FROM python:3.13-slim AS builder

# RUN apt-get update && \
#     apt-get install -y build-essential

RUN apt-get update

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Copy compiled binaries and discard source code
FROM python:3.13-slim AS final

# add non-root user with disabled shell access
RUN groupadd --system appgroup && \
    useradd --system --uid 10001 --gid appgroup --shell /usr/sbin/nologin appuser

# set the working directory and copy the source code
WORKDIR /app

COPY . .

# Copy installed dependencies from builder stage
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
