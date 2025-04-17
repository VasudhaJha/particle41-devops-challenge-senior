# Task 1 - Minimalist Application Development Using Docker

A minimalist FastAPI app called `SimpleTimeService` that returns the current UTC timestamp and the visitor's IP address.

## Project Structure

<pre> <code>
app/
├── main.py
├── requirements.txt
├── Dockerfile
└── README.md
</code> </pre>

## Prerequisites

Install Docker: https://docs.docker.com/get-docker/

## Build the Docker Image

```bash
cd app
docker build -t simple-time-service .
```

## Run the Container

```bash
docker run -p 8080:80 simple-time-service
```

Replace port `8080` with any other port on your host that you want to map to the container port.

## Test the Application

After running the container, open the following URLs in your browser:

- http://localhost:8080/
→ Returns a JSON response with:

    ```json
    {
    "timestamp": "2025-04-16T11:22:33.123456+00:00",
    "ip": "127.0.0.1"
    }
    ```

- http://localhost:8080/docs
→ Opens the Swagger UI, where you can try the API interactively and view its schema.

## Container Best Practices Followed

1. Small base image (`python:3.13-slim`)
1. Multi-stage build (no bloat)
1. Non-root user (useradd --system)
1. Clear CMD and EXPOSE set
