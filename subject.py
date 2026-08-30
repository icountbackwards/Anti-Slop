class Subject:
    def __init__(
        self,
        subject_id=None,
        name="",
        topics=None,
        resources=None,
        progressPointer=0,
        evaluation=""
    ):
        self.id = subject_id
        self.name = name
        self.topics = topics if topics is not None else []
        self.resources = resources if resources is not None else []
        self.progressPointer = progressPointer
        self.evaluation = evaluation