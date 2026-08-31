
from enum import Enum

import os
import requests

from pydantic import BaseModel
from typing import Literal


# ============================================================
# STUDY SESSION SCHEMAS
# ============================================================

class StudyWidget(BaseModel):
    type: Literal[
        "text",
        "latex",
        "text_input",
        "code_input",
        "multiple_choice",
        "button"
    ]

    widgetId: str

    # Normal text / button text
    text: str | None = None

    # LaTeX output
    latex: str | None = None

    # Text input
    placeholder: str | None = None

    # Multiple choice
    question: str | None = None
    options: list[str] | None = None

    # Code input
    language: str | None = None
    starterCode: str | None = None


class StudyResponse(BaseModel):
    widgets: list[StudyWidget]

    evaluation: str | None = None

    topic_complete: bool = False


# ============================================================
# AI MODES
# ============================================================

class AIMode(Enum):
    FREE = "free"
    PAID = "paid"


# ============================================================
# SUBJECT CREATION SCHEMAS
# ============================================================

class AIResource(BaseModel):
    name: str
    url: str


class SubjectPlan(BaseModel):
    topics: list[str]
    resources: list[AIResource]


# ============================================================
# AI
# ============================================================

class AI:

    def __init__(
        self,
        mode=AIMode.FREE
    ):
        self.mode = mode

        # ====================================================
        # ANTISLOP AGENT API
        # ====================================================

        self.api_url = os.getenv(
            "ANTISLOP_API_URL",
            "http://localhost:8080"
        ).rstrip("/")


    # ========================================================
    # MODE
    # ========================================================

    def setMode(
        self,
        mode
    ):
        self.mode = mode


    def _getModeString(self):
        if self.mode == AIMode.PAID:
            return "paid"

        return "free"


    # ========================================================
    # SUBJECT PLAN GENERATION
    # ========================================================

    def createSubjectPlan(
        self,
        name,
        description
    ):
        response = requests.post(
            f"{self.api_url}/subject-plan",
            json={
                "name": name,
                "description": description,
                "mode": self._getModeString()
            },
            timeout=120
        )

        response.raise_for_status()

        return SubjectPlan.model_validate(
            response.json()
        )


    # ========================================================
    # STUDY AGENT
    # ========================================================

    def runStudyAgent(
        self,
        subject_name,
        current_topic,
        resources,
        evaluation,
        user_inputs=None,
        action=None
    ):
        if user_inputs is None:
            user_inputs = {}

        response = requests.post(
            f"{self.api_url}/study-agent",
            json={
                "subject_name": subject_name,
                "current_topic": current_topic,
                "resources": resources,
                "evaluation": evaluation,
                "user_inputs": user_inputs,
                "action": action,
                "mode": self._getModeString()
            },
            timeout=120
        )

        response.raise_for_status()

        return StudyResponse.model_validate(
            response.json()
        )

