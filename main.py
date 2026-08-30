import sys
from pathlib import Path
import database

from datetime import date
from ui_main import Application
from core import Core


def resource_path(relative_path):
    if getattr(sys, "frozen", False):
        base_path = Path(sys._MEIPASS)
    else:
        base_path = Path(__file__).resolve().parent

    return base_path / relative_path


today = date.today().isoformat()

print("Hello World")

db = database.Database(
    resource_path("db/database.db")
)

core = Core(db)

app = Application(core)

db.close()