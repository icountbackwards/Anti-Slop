# database.py

import sqlite3
from pathlib import Path
import log
from subject import Subject

class Database:
    def __init__(self, path):
        self.path = Path(path)
        self.conn = None
        self.cursor = None
        self.path.parent.mkdir(parents=True, exist_ok=True)

        if self.path.exists() and self.path.suffix.lower() == ".db":
            self.loadDatabase()
        else:
            log.throwWarning(log.WARNING_DB_NOT_EXIST)
            self.initEmpty()

    def connect(self):
        self.conn = sqlite3.connect(self.path)
        self.conn.execute("PRAGMA foreign_keys = ON")
        self.cursor = self.conn.cursor()

    def initEmpty(self):
        self.connect()
        self.cursor.executescript("""
            CREATE TABLE IF NOT EXISTS subjects (
                id INTEGER PRIMARY KEY,
                subject_name TEXT NOT NULL,
                date_created DATE NOT NULL,
                progress_pointer INTEGER NOT NULL,
                evaluation TEXT
            );

            CREATE TABLE IF NOT EXISTS topics (
                id INTEGER PRIMARY KEY,
                subject_id INTEGER NOT NULL,
                topic_name TEXT NOT NULL,
                FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS resources (
                id INTEGER PRIMARY KEY,
                subject_id INTEGER NOT NULL,
                resource_name TEXT NOT NULL,
                resource_url TEXT,
                FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
            );
        """)
        self.conn.commit()

    def loadDatabase(self):
        self.connect()

    def insertSubject(self, subject, date):

        if subject.progressPointer is None:
            subject.progressPointer = 0

        self.cursor.execute("""
            INSERT INTO subjects (
                subject_name,
                date_created,
                progress_pointer,
                evaluation
            )

            VALUES (?, ?, ?, ?)
        """, (
            subject.name,
            date,
            subject.progressPointer,
            subject.evaluation
        ))

        subject.id = self.cursor.lastrowid


        # ============================================================
        # TOPICS
        # ============================================================

        for topic in subject.topics:

            self.cursor.execute("""
                INSERT INTO topics (
                    subject_id,
                    topic_name
                )

                VALUES (?, ?)
            """, (
                subject.id,
                str(topic)
            ))


        # ============================================================
        # RESOURCES
        # ============================================================

        for resource in subject.resources:

            self.cursor.execute("""
                INSERT INTO resources (
                    subject_id,
                    resource_name
                )

                VALUES (?, ?)
            """, (
                subject.id,
                str(resource)
            ))


        self.conn.commit()

        return subject.id

    def deleteSubject(self, subject):
        self.cursor.execute("DELETE FROM subjects WHERE id = ?", (subject.id,))
        self.conn.commit()

    def getSubject(self, subject_id):

        self.cursor.execute("""
            SELECT
                subject_name,
                progress_pointer,
                evaluation

            FROM subjects

            WHERE id = ?
        """, (
            subject_id,
        ))

        row = self.cursor.fetchone()

        if row is None:
            return None


        subject_name, progress_pointer, evaluation = row


        # ============================================================
        # TOPICS
        # ============================================================

        self.cursor.execute("""
            SELECT topic_name

            FROM topics

            WHERE subject_id = ?

            ORDER BY id
        """, (
            subject_id,
        ))

        topics = [
            row[0]
            for row in self.cursor.fetchall()
        ]


        # ============================================================
        # RESOURCES
        # ============================================================

        self.cursor.execute("""
            SELECT resource_name

            FROM resources

            WHERE subject_id = ?

            ORDER BY id
        """, (
            subject_id,
        ))

        resources = [
            row[0]
            for row in self.cursor.fetchall()
        ]


        return Subject(
            subject_id,
            subject_name,
            topics,
            resources,
            progress_pointer,
            evaluation
        )

    def getSubjectByName(self, subject_name):

        self.cursor.execute("""
            SELECT id

            FROM subjects

            WHERE subject_name = ?
        """, (
            subject_name,
        ))

        row = self.cursor.fetchone()

        if row is None:
            return None

        return self.getSubject(
            row[0]
        )

    def getSubjects(self):
        self.cursor.execute("SELECT id FROM subjects")
        return [self.getSubject(row[0]) for row in self.cursor.fetchall()]

    def renameSubject(self, subject, newName):
        self.cursor.execute("""
            UPDATE subjects
            SET subject_name = ?
            WHERE id = ?
        """, (newName, subject.id))

        subject.name = newName
        self.conn.commit()

    def moveProgressPointer(self, subject):

        if subject is None:
            return False

        if subject.progressPointer >= len(subject.topics):
            return False

        subject.progressPointer += 1

        self.cursor.execute("""
            UPDATE subjects

            SET progress_pointer = ?

            WHERE id = ?
        """, (
            subject.progressPointer,
            subject.id
        ))

        self.conn.commit()

        return True

    def updateEvaluation(self, subject, evaluation):
        self.cursor.execute("""
            UPDATE subjects
            SET evaluation = ?
            WHERE id = ?
        """, (evaluation, subject.id))

        subject.evaluation = evaluation
        self.conn.commit()

    def close(self):
        if self.conn:
            self.conn.close()

    def insertResource(
        self,
        subject_id,
        name,
        url=None
    ):
        self.cursor.execute("""
            INSERT INTO resources (
                subject_id,
                resource_name,
                resource_url
            )

            VALUES (?, ?, ?)
        """, (
            subject_id,
            name,
            url
        ))

        self.conn.commit()