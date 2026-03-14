from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.api.routes import auth, reports, heatmap, analysis, journey, admin, news

settings = get_settings()

app = FastAPI(title="Guardia AI Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(reports.router)
app.include_router(heatmap.router)
app.include_router(analysis.router)
app.include_router(journey.router)
app.include_router(admin.router)
app.include_router(news.router)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "guardia-ai"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0", port=8000, reload=True)