# Antislop

Antislop is an adaptive AI study agent that generates learning roadmaps, finds resources, creates interactive study sessions, evaluates the learner, and adapts future sessions based on their progress.

Built for the **All Things Agentic Hackathon**.

## Architecture

![Antislop Architecture](docs/architecture.png)

```text
PySide6 / QML Desktop App
        │
        ├── SQLite
        │   └── Learner state & progress
        │
        │ HTTPS / JSON
        ▼
Google Cloud Run
        │
        └── FastAPI Agent Backend
                │
                ├── Subject Planner
                └── Adaptive Study Agent
                        │
                        ▼
                Google GenAI SDK
                        │
                        ▼
                    Gemini 3.5
```

Antislop uses **Gemini 3.5** through the **Google GenAI SDK**. The agent backend is designed to run on **Google Cloud Run**, while learner state is stored locally with SQLite.

The core learning loop is:

```text
Plan → Teach → Assess → Persist → Adapt
```

## How to build

```powershell
git clone https://github.com/icountbackwards/Antislop.git
cd Antislop

python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt

$env:GEMINI_API_KEY="YOUR_API_KEY"

uvicorn server:app --reload --port 8080

.venv\Scripts\activate
python main.py
```

### Run from Cloud

```powershell
gcloud.cmd auth login
gcloud.cmd config set project YOUR_PROJECT_ID
gcloud.cmd services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
$env:GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
gcloud.cmd run deploy antislop-agent --source . --region asia-east1 --allow-unauthenticated --set-env-vars "GEMINI_API_KEY=$env:GEMINI_API_KEY"
$env:ANTISLOP_API_URL="YOUR_CLOUD_RUN_URL"
.\.venv\Scripts\python.exe main.py
```
