import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWebEngineQuick import QtWebEngineQuick


def resource_path(relative_path):
    if getattr(sys, "frozen", False):
        # Running from PyInstaller
        base_path = Path(sys._MEIPASS)
    else:
        # Running normally with Python
        base_path = Path(__file__).resolve().parent

    return base_path / relative_path


class Application:

    def __init__(self, core):

        self.core = core

        QtWebEngineQuick.initialize()

        self.app = QGuiApplication(sys.argv)

        self.engine = QQmlApplicationEngine()

        self.engine.rootContext().setContextProperty(
            "core",
            self.core
        )

        self.engine.rootContext().setContextProperty(
            "dropdown",
            self.core.dropdown
        )

        # Correct path for both Python and PyInstaller
        qml_path = resource_path("ui/main.qml")

        print("Loading QML from:", qml_path)

        self.engine.load(str(qml_path))

        if not self.engine.rootObjects():
            print("ERROR: Could not load main.qml")
            sys.exit(-1)

        sys.exit(self.app.exec())