import os
from pathlib import Path
from typing import Literal

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from google import genai


app = FastAPI(title="Antislop Agent API")

client = genai.Client(
    api_key=os.environ["GEMINI_API_KEY"]
)

PROMPT_DIR = Path(__file__).parent / "prompts"

study_agent_prompt = (
    PROMPT_DIR / "study_agent_prompt.txt"
).read_text(encoding="utf-8")

subject_planner_prompt = (
    PROMPT_DIR / "subject_planner_prompt.txt"
).read_text(encoding="utf-8")


# ============================================================
# RESPONSE SCHEMAS
# ============================================================

class StudyWidget(BaseModel):
    type: Literal[
        "text",
        "latex",
        "text_input",
        "code_input",
        "multiple_choice",
        "button",
    ]

    widgetId: str

    text: str | None = None
    latex: str | None = None
    placeholder: str | None = None
    question: str | None = None
    options: list[str] | None = None
    language: str | None = None
    starterCode: str | None = None


class StudyResponse(BaseModel):
    widgets: list[StudyWidget]
    evaluation: str | None = None
    topic_complete: bool = False


class AIResource(BaseModel):
    name: str
    url: str


class SubjectPlan(BaseModel):
    topics: list[str]
    resources: list[AIResource]


# ============================================================
# REQUEST SCHEMAS
# ============================================================

class SubjectPlanRequest(BaseModel):
    name: str
    description: str
    mode: str = "free"


class StudyAgentRequest(BaseModel):
    subject_name: str
    current_topic: str
    resources: object
    evaluation: str | None = None
    user_inputs: dict | None = None
    action: str | None = None
    mode: str = "free"


def get_model(mode: str) -> str:
    if mode == "paid":
        return "gemini-3.5-flash"

    if mode == "free":
        return "gemini-3.5-flash-lite"

    raise ValueError(f"Unknown AI mode: {mode}")


# ============================================================
# ROUTES
# ============================================================

@app.get("/")
def health():
    return {
        "service": "Antislop Agent API",
        "status": "ok",
    }


@app.post("/subject-plan", response_model=SubjectPlan)
def create_subject_plan(req: SubjectPlanRequest):

    prompt = subject_planner_prompt.format(
        subject_name=req.name,
        description=req.description,
    )

    try:
        response = client.models.generate_content(
            model=get_model(req.mode),
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": SubjectPlan,
            },
        )

        if response.parsed is None:
            raise RuntimeError(
                "Gemini returned no parsed SubjectPlan."
            )

        return response.parsed

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        )


@app.post("/study-agent", response_model=StudyResponse)
def run_study_agent(req: StudyAgentRequest):

    user_inputs = req.user_inputs or {}

    prompt = study_agent_prompt.format(
        subject_name=req.subject_name,
        current_topic=req.current_topic,
        resources=req.resources,
        evaluation=req.evaluation,
        user_inputs=user_inputs,
        action=req.action,
    )

    try:
        response = client.models.generate_content(
            model=get_model(req.mode),
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": StudyResponse,
            },
        )

        if response.parsed is None:
            raise RuntimeError(
                "Gemini returned no parsed StudyResponse."
            )

        return response.parsed

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        )