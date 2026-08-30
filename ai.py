from enum import Enum

import os

from google import genai

from pydantic import BaseModel

from typing import Literal

from pathlib import Path

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

        # Load prompts
        prompt_dir = Path(__file__).parent / "prompts"

        self.study_agent_prompt = (
            prompt_dir / "study_agent_prompt.txt"
        ).read_text(encoding="utf-8")

        self.subject_planner_prompt = (
            prompt_dir / "subject_planner_prompt.txt"
        ).read_text(encoding="utf-8")


        # ====================================================
        # FREE CLIENT
        # ====================================================

        free_key = os.getenv(
            "GEMINI_FREE_API_KEY"
        )

        if not free_key:

            raise RuntimeError(
                "GEMINI_FREE_API_KEY is not set."
            )


        self.free_client = genai.Client(
            api_key=free_key
        )


        # ====================================================
        # PAID CLIENT
        # ====================================================

        paid_key = os.getenv(
            "GEMINI_PAID_API_KEY"
        )


        if paid_key:

            self.paid_client = (
                genai.Client(
                    api_key=paid_key
                )
            )

        else:

            self.paid_client = None


    # ========================================================
    # MODE
    # ========================================================

    def setMode(
        self,
        mode
    ):

        self.mode = mode


    def _getClientAndModel(self):

        if self.mode == AIMode.PAID:

            if self.paid_client is None:

                raise RuntimeError(
                    "Paid AI mode selected, but "
                    "GEMINI_PAID_API_KEY is not set."
                )


            return (
                self.paid_client,
                "gemini-3.5-flash"
            )


        return (
            self.free_client,
            "gemini-3.5-flash-lite"
        )


    # ========================================================
    # SUBJECT PLAN GENERATION
    # ========================================================

    def createSubjectPlan(
        self,
        name,
        description
    ):

        client, model = (
            self._getClientAndModel()
        )


        prompt = self.subject_planner_prompt.format(
            subject_name=name,
            description=description
        )

        response = (
            client.models.generate_content(
                model=model,

                contents=prompt,

                config={
                    "response_mime_type":
                        "application/json",

                    "response_schema":
                        SubjectPlan
                }
            )
        )


        return response.parsed


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

        client, model = self._getClientAndModel()

        if user_inputs is None:
            user_inputs = {}

        prompt = self.study_agent_prompt.format(
            subject_name=subject_name,
            current_topic=current_topic,
            resources=resources,
            evaluation=evaluation,
            user_inputs=user_inputs,
            action=action
        )

        response = client.models.generate_content(
            model=model,
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": StudyResponse
            }
        )

        if response.parsed is None:
            raise RuntimeError(
                "Gemini returned no parsed StudyResponse."
            )

        return response.parsed