import database
from datetime import date
from ui_main import Application
from subject import Subject
import sys
from pathlib import Path
from studytools import StudySession
from ai import AI, AIMode

from PySide6.QtCore import QObject, Property, QStringListModel, Slot, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

class Core(QObject):
    def __init__(self, db):
        super().__init__()

        self.db = db
        self.ai = AI(
            AIMode.FREE
        )

        self._session = StudySession(self.db, self.ai)

        self._slider_value = 1

        self.dropdown = QStringListModel(
            subject.name
            for subject in self.db.getSubjects()
        )

    @Property(int, constant=True)
    def sliderValue(self):
        return self._slider_value
    
    @Property(QObject, constant=True)
    def session(self):
        return self._session

    @Slot(int, str)
    def startStudyingClicked(
        self,
        time,
        subject_name
    ):

        print(
            "Time:",
            time,
            "hours"
        )

        print(
            "Subject:",
            subject_name
        )


        # Load full Subject object from SQLite.
        subject = self.db.getSubjectByName(
            subject_name
        )


        if subject is None:

            print(
                "Subject not found:",
                subject_name
            )

            return


        print(
            "Progress pointer:",
            subject.progressPointer
        )

        print(
            "Topics:",
            subject.topics
        )


        self._session.startSession(
            time,
            subject
        )

    @Slot()
    def newSubjectClicked(self):
        print("New Subject Clicked")

    @Slot(str, str, "QVariantList", result="QVariantMap")
    def createSubject(
        self,
        name,
        description,
        attachments
    ):
        print("Creating subject:")
        print("Name:", name)
        print("Description:", description)

        # ============================================================
        # MANUALLY ADDED RESOURCES
        # ============================================================

        attachment_paths = []

        for attachment in attachments:
            path = Path(
                QUrl(attachment).toLocalFile()
            )

            if path.exists():
                path_string = str(path)

                attachment_paths.append(
                    path_string
                )

                print(
                    "Attachment:",
                    path_string
                )


        # ============================================================
        # AI GENERATION
        # ============================================================

        plan = self.ai.createSubjectPlan(
            name,
            description
        )

        topics_list = plan.topics

        ai_resources = [
            {
                "name": resource.name,
                "url": resource.url
            }
            for resource in plan.resources
        ]


        print(
            "Generated topics:",
            topics_list
        )

        print(
            "Generated resources:",
            ai_resources
        )


        # ============================================================
        # CREATE SUBJECT
        # ============================================================

        newsubject = Subject()

        newsubject.name = name

        newsubject.topics = topics_list

        # We'll improve this representation below.
        newsubject.resources = attachment_paths

        today = date.today().isoformat()

        self.db.insertSubject(
            newsubject,
            today
        )


        # ============================================================
        # STORE AI RESOURCES
        # ============================================================

        for resource in ai_resources:
            self.db.insertResource(
                newsubject.id,
                resource["name"],
                resource["url"]
            )


        self.refreshDropdown()


        # ============================================================
        # RESULT PAGE
        # ============================================================

        result_resources = []

        # Local files
        for path in attachment_paths:
            result_resources.append({
                "name": Path(path).name,
                "url": path
            })

        # AI resources
        result_resources.extend(
            ai_resources
        )


        return {
            "name": name,
            "topics": topics_list,
            "resources": result_resources
        }

    @Slot()
    def refreshDropdown(self):
        self.dropdown.setStringList(subject.name for subject in self.db.getSubjects())

    @Slot(str)
    def setAIMode(self, mode):

        if mode == "paid":
            self.ai.setMode(
                AIMode.PAID
            )

            print("AI mode: PAID")

        else:
            self.ai.setMode(
                AIMode.FREE
            )

            print("AI mode: FREE")