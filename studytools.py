from enum import Enum

from PySide6.QtCore import (
    QObject,
    Property,
    Signal,
    Slot,
)


class WidgetType(str, Enum):

    # OUTPUT
    TEXT = "text"
    LATEX = "latex"
    RICH_TEXT = "rich_text"

    IMAGE = "image"

    GRAPH = "graph"
    MANIM = "manim"

    CODE_OUTPUT = "code_output"

    DIVIDER = "divider"

    # INPUT
    TEXT_INPUT = "text_input"
    LATEX_INPUT = "latex_input"
    CODE_INPUT = "code_input"
    IMAGE_INPUT = "image_input"

    MULTIPLE_CHOICE = "multiple_choice"

    # ACTION
    BUTTON = "button"


class StudySession(QObject):

    # ============================================================
    # SIGNALS
    # ============================================================

    timerChanged = Signal()
    runningChanged = Signal()
    sessionChanged = Signal()

    canvasChanged = Signal()
    topicChanged = Signal()


    # ============================================================
    # INITIALIZATION
    # ============================================================

    def __init__(self, db, ai):
        super().__init__()

        self.db = db
        self.ai = ai

        # ========================================================
        # SESSION STATE
        # ========================================================

        self._timer = 0
        self._running = False

        self.startFlag = False
        self.finishFlag = False

        self.time = 0

        # Full Subject object
        self.subject = None

        # Topic pointed to by subject.progressPointer
        self._current_topic = ""


        # ========================================================
        # AI CANVAS STATE
        # ========================================================

        self._canvas = []

        # Values entered into dynamically generated widgets.
        #
        # Example:
        #
        # {
        #     "answer1": "4",
        #     "code1": "..."
        # }
        #
        self._widget_values = {}


    # ============================================================
    # QML PROPERTIES
    # ============================================================

    @Property(int, notify=timerChanged)
    def timer(self):
        return self._timer


    @Property(bool, notify=runningChanged)
    def running(self):
        return self._running


    @Property(str, notify=topicChanged)
    def currentTopic(self):
        return self._current_topic


    @Property("QVariantList", notify=canvasChanged)
    def canvasModel(self):
        return self._canvas


    # ============================================================
    # SESSION
    # ============================================================

    def startSession(self, time, subject):

        self._timer = time * 3600
        self._running = True

        self.startFlag = True
        self.finishFlag = False

        self.time = time * 3600
        self.subject = subject

        self._widget_values = {}

        current_topic = self.getCurrentTopic()

        if current_topic is None:

            self._current_topic = ""

            self.setCanvas([
                {
                    "type": WidgetType.TEXT.value,
                    "widgetId": "finished",
                    "text": (
                        f"You have completed all topics in "
                        f"{subject.name}."
                    )
                }
            ])

        else:

            self._current_topic = current_topic

            self.generateStudyStep()

        self.timerChanged.emit()
        self.runningChanged.emit()
        self.topicChanged.emit()
        self.sessionChanged.emit()


    @Slot()
    def endSession(self):

        self._timer = 0
        self._running = False

        self.startFlag = False
        self.finishFlag = True

        self.time = 0

        self.subject = None
        self._current_topic = ""

        self._canvas = []
        self._widget_values = {}

        self.timerChanged.emit()
        self.runningChanged.emit()
        self.topicChanged.emit()
        self.canvasChanged.emit()
        self.sessionChanged.emit()


    # ============================================================
    # CURRENT TOPIC
    # ============================================================

    def getCurrentTopic(self):

        if self.subject is None:
            return None

        pointer = self.subject.progressPointer

        if pointer < 0:
            return None

        if pointer >= len(self.subject.topics):
            return None

        return self.subject.topics[pointer]


    # ============================================================
    # COMPLETE CURRENT TOPIC
    # ============================================================

    @Slot()
    def completeCurrentTopic(self):

        if self.subject is None:
            return

        if self.subject.progressPointer >= len(self.subject.topics):
            return

        self.db.moveProgressPointer(
            self.subject
        )

        next_topic = self.getCurrentTopic()

        if next_topic is None:

            self._current_topic = ""

            self.setCanvas([
                {
                    "type": WidgetType.TEXT.value,
                    "widgetId": "finished",
                    "text": (
                        f"You have completed all topics in "
                        f"{self.subject.name}."
                    )
                }
            ])

        else:

            self._current_topic = next_topic

            self.setCanvas([
                {
                    "type": WidgetType.TEXT.value,
                    "widgetId": "nextTopic",
                    "text": (
                        f"Next topic: {next_topic}"
                    )
                },

                {
                    "type": WidgetType.BUTTON.value,
                    "widgetId": "startNextTopic",
                    "text": "Start Topic"
                }
            ])

        self.topicChanged.emit()
        self.sessionChanged.emit()


    # ============================================================
    # TIMER CONTROL
    # ============================================================

    @Slot()
    def startTimer(self):

        if self._timer <= 0:
            return

        self._running = True

        self.runningChanged.emit()


    @Slot()
    def pauseTimer(self):

        self._running = False

        self.runningChanged.emit()


    @Slot()
    def toggleTimer(self):

        if self._timer <= 0:
            return

        self._running = not self._running

        self.runningChanged.emit()


    @Slot()
    def tickTimer(self):

        if not self._running:
            return

        if self._timer > 0:

            self._timer -= 1

            self.timerChanged.emit()

        if self._timer <= 0:

            self._timer = 0
            self._running = False

            self.timerChanged.emit()
            self.runningChanged.emit()


    # ============================================================
    # CANVAS
    # ============================================================

    def setCanvas(self, widgets):

        self._canvas = widgets

        self.canvasChanged.emit()


    def clearCanvas(self):

        self._canvas = []

        self.canvasChanged.emit()


    # ============================================================
    # WIDGET VALUES
    # ============================================================

    @Slot(str, "QVariant")
    def setWidgetValue(
        self,
        widget_id,
        value
    ):

        self._widget_values[widget_id] = value

        print(
            "Widget value:",
            widget_id,
            "=",
            value
        )


    # ============================================================
    # WIDGET ACTION
    # ============================================================

    @Slot(str)
    def widgetAction(
        self,
        widget_id
    ):

        print(
            "Widget action:",
            widget_id
        )

        print(
            "Current inputs:",
            self._widget_values
        )


        # Special local action used after completing a topic.
        if widget_id == "startNextTopic":

            if not self._current_topic:
                return

            self._widget_values = {}

            self.generateStudyStep()

            return


        # Everything else goes back through the AI.
        self.generateStudyStep(
            action=widget_id
        )


    # ============================================================
    # GENERATE NEXT AI STUDY STEP
    # ============================================================

    def generateStudyStep(
        self,
        action=None
    ):

        if self.subject is None:
            return

        if not self._current_topic:
            return


        try:

            response = self.ai.runStudyAgent(
                subject_name=self.subject.name,
                current_topic=self._current_topic,
                resources=self.subject.resources,
                evaluation=self.subject.evaluation,
                user_inputs=self._widget_values,
                action=action
            )

        except Exception as e:

            print(
                "Study AI error:",
                repr(e)
            )

            self.setCanvas([
                {
                    "type": WidgetType.TEXT.value,
                    "widgetId": "aiError",
                    "text": (
                        "The study assistant could not generate "
                        "the next step."
                    )
                }
            ])

            return


        # ========================================================
        # DEBUG RAW AI RESPONSE
        # ========================================================

        print(
            "\n========== RAW AI RESPONSE =========="
        )

        for widget in response.widgets:
            print(widget)

        print(
            "=====================================\n"
        )


        # ========================================================
        # CONVERT AI OBJECTS -> QML DICTS
        # ========================================================

        widgets = []

        for widget in response.widgets:

            data = {
                "type": widget.type,
                "widgetId": widget.widgetId
            }


            if widget.text is not None:
                data["text"] = widget.text


            if widget.latex is not None:
                data["latex"] = widget.latex


            if widget.placeholder is not None:
                data["placeholder"] = (
                    widget.placeholder
                )


            if widget.question is not None:
                data["question"] = (
                    widget.question
                )


            if widget.options is not None:
                data["options"] = (
                    widget.options
                )


            if widget.language is not None:
                data["language"] = (
                    widget.language
                )


            if widget.starterCode is not None:
                data["starterCode"] = (
                    widget.starterCode
                )


            widgets.append(data)


        # ========================================================
        # VALIDATE / REPAIR AI CANVAS
        # ========================================================

        widgets = self.validateCanvas(
            widgets
        )


        # ========================================================
        # DEBUG FINAL CANVAS
        # ========================================================

        print(
            "\n========== FINAL CANVAS =========="
        )

        for index, widget in enumerate(widgets):
            print(
                index,
                widget
            )

        print(
            "==================================\n"
        )


        # ========================================================
        # UPDATE QML
        # ========================================================

        self.setCanvas(
            widgets
        )


        # Current inputs have already been sent to the AI.
        # The next generated screen starts fresh.
        self._widget_values = {}


        # ========================================================
        # UPDATE EVALUATION
        # ========================================================

        if response.evaluation:

            self.subject.evaluation = (
                response.evaluation
            )

            self.db.updateEvaluation(
                self.subject,
                response.evaluation
            )


        # ========================================================
        # TOPIC COMPLETION
        # ========================================================

        if response.topic_complete:

            self.completeCurrentTopic()


    # ============================================================
    # CANVAS VALIDATION
    # ============================================================

    def validateCanvas(
        self,
        widgets
    ):

        input_types = {
            WidgetType.TEXT_INPUT.value,
            WidgetType.CODE_INPUT.value,
            WidgetType.MULTIPLE_CHOICE.value,
            WidgetType.LATEX_INPUT.value,
            WidgetType.IMAGE_INPUT.value
        }

        result = []

        input_seen = False


        for widget in widgets:

            widget_type = (
                widget.get("type")
            )


            if widget_type in input_types:

                input_seen = True


            # ====================================================
            # SUBMIT BUTTON VALIDATION
            # ====================================================

            if widget_type == WidgetType.BUTTON.value:

                button_id = (
                    widget
                    .get(
                        "widgetId",
                        ""
                    )
                    .lower()
                )

                button_text = (
                    widget
                    .get(
                        "text",
                        ""
                    )
                    .lower()
                )


                is_submit = (
                    "submit" in button_id
                    or
                    "submit" in button_text
                    or
                    "check answer" in button_text
                    or
                    "check" in button_id
                )


                # AI created a submit button without
                # providing any answer input.
                if (
                    is_submit
                    and
                    not input_seen
                ):

                    result.append({
                        "type":
                            WidgetType.TEXT_INPUT.value,

                        "widgetId":
                            "answer_auto",

                        "placeholder":
                            "Enter your answer..."
                    })

                    input_seen = True


            result.append(widget)


        return result


    # ============================================================
    # GENERIC AGENT OUTPUT ENTRY POINT
    # ============================================================

    def processAgentOutput(
        self,
        output
    ):

        widgets = output.get(
            "widgets",
            []
        )

        widgets = self.validateCanvas(
            widgets
        )

        self.setCanvas(
            widgets
        )