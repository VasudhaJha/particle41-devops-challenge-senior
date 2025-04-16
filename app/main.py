from fastapi import FastAPI, Request
from pydantic import BaseModel
from datetime import datetime, timezone

app = FastAPI(
    title="SimpleTimeService",
    description="A tiny service that returns the current UTC time and your IP address.",
    version="1.0.0"
)

class TimeResponse(BaseModel):
    timestamp: str
    ip: str

@app.get("/", response_model=TimeResponse)
async def get_time(request: Request):
    print("Client Info:", request)
    return TimeResponse(
        timestamp=datetime.now(timezone.utc).isoformat(),
        ip=request.client.host if request.client and request.client.host else "unknown"
    )