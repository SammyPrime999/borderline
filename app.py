import sys

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class BorderlineGame(QObject):
    stateChanged = Signal()

    def __init__(self):
        super().__init__()

        self._scene_title = ""
        self._story = ""
        self._choices = []
        self._choice_actions = []

        self._document_request_active = False
        self._document_request_text = ""
        self._requested_document_id = None
        self._document_attempts = 0

        self.reset_state()
        self.start_game()

    # ============================================================
    # STATE
    # ============================================================

    def reset_state(self):
        self._cash = 350
        self._battery = 61
        self._stress = 10
        self._suspicion = 0
        self._connection_minutes = 95

        self._gate = "B42"
        self._gate_walk_minutes = 17

        self._document_request_active = False
        self._document_request_text = ""
        self._requested_document_id = None
        self._document_attempts = 0

        self.traveler = {
            "name": "Samuel",
            "purpose": "study",
            "destination": "Dallas",
            "has_school_letter": True,
            "has_i20": True,
            "has_housing_address": True,
            "available_funds": 350,
        }

        self.documents = [
            {
                "id": "passport",
                "name": "Passport",
                "detail": "Nigerian passport",
            },
            {
                "id": "visa",
                "name": "F-1 Visa",
                "detail": "United States student visa",
            },
            {
                "id": "i20",
                "name": "Form I-20",
                "detail": "Certificate of Eligibility for Student Status",
            },
            {
                "id": "admission",
                "name": "Admission Letter",
                "detail": "University admission confirmation",
            },
            {
                "id": "boarding",
                "name": "Boarding Pass",
                "detail": "London → Dallas • Gate B42",
            },
            {
                "id": "housing",
                "name": "Housing Confirmation",
                "detail": "Dallas accommodation address",
            },
        ]

    # ============================================================
    # QML PROPERTIES
    # ============================================================

    @Property(int, notify=stateChanged)
    def cash(self):
        return self._cash

    @Property(int, notify=stateChanged)
    def battery(self):
        return self._battery

    @Property(int, notify=stateChanged)
    def stress(self):
        return self._stress

    @Property(int, notify=stateChanged)
    def suspicion(self):
        return self._suspicion

    @Property(int, notify=stateChanged)
    def connectionMinutes(self):
        return self._connection_minutes

    @Property(str, notify=stateChanged)
    def gate(self):
        return self._gate

    @Property(int, notify=stateChanged)
    def gateWalkMinutes(self):
        return self._gate_walk_minutes

    @Property(str, notify=stateChanged)
    def sceneTitle(self):
        return self._scene_title

    @Property(str, notify=stateChanged)
    def story(self):
        return self._story

    @Property("QStringList", notify=stateChanged)
    def choices(self):
        return self._choices

    @Property("QVariantList", notify=stateChanged)
    def documentList(self):
        return self.documents

    @Property(bool, notify=stateChanged)
    def documentRequestActive(self):
        return self._document_request_active

    @Property(str, notify=stateChanged)
    def documentRequestText(self):
        return self._document_request_text

    # ============================================================
    # CORE
    # ============================================================

    def set_scene(self, title, story, choices):
        self._scene_title = title
        self._story = story
        self._choices = [label for label, _ in choices]
        self._choice_actions = [action for _, action in choices]

        self.stateChanged.emit()

    @Slot(int)
    def choose(self, index):
        if 0 <= index < len(self._choice_actions):
            self._choice_actions[index]()

    @Slot()
    def restart(self):
        self.reset_state()
        self.start_game()

    def clean_suspicion(self):
        self._suspicion = max(0, self._suspicion)

    # ============================================================
    # PHONE
    # ============================================================

    @Slot()
    def usePhone(self):
        if self._battery > 0:
            self._battery -= 1

        self.stateChanged.emit()

    # ============================================================
    # DOCUMENT SYSTEM
    # ============================================================

    def request_document(self, document_id, request_text):
        self._requested_document_id = document_id
        self._document_request_text = request_text
        self._document_request_active = True
        self._document_attempts = 0

        self._choices = []
        self._choice_actions = []

        self.stateChanged.emit()

    @Slot(int)
    def presentDocument(self, index):
        if not self._document_request_active:
            return

        if not (0 <= index < len(self.documents)):
            return

        document = self.documents[index]

        self._connection_minutes -= 1

        if document["id"] == self._requested_document_id:
            self._document_request_active = False
            self._document_request_text = ""
            self._requested_document_id = None

            self._suspicion -= 5
            self.clean_suspicion()

            self.set_scene(
                "DOCUMENT ACCEPTED",
                (
                    f"You place the {document['name']} on the counter.\n\n"
                    "The officer checks the information against your passport "
                    "and visa.\n\n"
                    "After a moment, they slide it back toward you."
                ),
                [
                    ("See immigration decision", self.interview_result),
                ],
            )

            return

        self._document_attempts += 1
        self._suspicion += 8
        self._stress += 5

        if self._document_attempts >= 2:
            self._document_request_active = False
            self._document_request_text = ""
            self._requested_document_id = None

            self.set_scene(
                "REFERRED",
                (
                    f'You present the {document["name"]}.\n\n'
                    "The officer doesn't take it.\n\n"
                    '"That is the second time I have asked for a specific '
                    'document."\n\n'
                    "They close your passport."
                ),
                [
                    ("Follow the officer", self.secondary_screening_start),
                ],
            )

        else:
            self._scene_title = "DOCUMENT REQUEST"
            self._story = (
                f'You present the {document["name"]}.\n\n'
                "The officer glances at it and pushes it back.\n\n"
                '"That is not what I asked for."\n\n'
                '"Your I-20, please."'
            )

            self._document_request_text = "Present your Form I-20"
            self.stateChanged.emit()

    # ============================================================
    # ARRIVAL
    # ============================================================

    def start_game(self):
        self._connection_minutes -= 27

        self.set_scene(
            "ARRIVAL",
            (
                "Your flight touches down 27 minutes late.\n\n"
                f"You have {self._connection_minutes} minutes before "
                "your connecting flight departs."
            ),
            [
                ("Go directly to immigration", self.go_directly),
                ("Find a bathroom first", self.use_bathroom),
                (
                    "Ask an airport employee about your connection",
                    self.ask_employee,
                ),
            ],
        )

    def go_directly(self):
        self._stress += 5

        self.set_scene(
            "IMMIGRATION HALL",
            (
                "You follow the signs toward passport control.\n\n"
                "The crowd grows thicker as you approach the hall."
            ),
            [
                ("Continue", self.immigration_queue),
            ],
        )

    def use_bathroom(self):
        self._connection_minutes -= 8
        self._stress -= 2

        self.set_scene(
            "BATHROOM STOP",
            (
                "You stop at the bathroom.\n\n"
                "Eight minutes disappear, but you feel slightly more composed."
            ),
            [
                ("Continue to immigration", self.immigration_queue),
            ],
        )

    def ask_employee(self):
        self._connection_minutes -= 4
        self._stress -= 5

        self.set_scene(
            "AIRPORT STAFF",
            (
                "You show an airport employee your boarding pass.\n\n"
                '"Passport control is straight ahead. Keep moving."'
            ),
            [
                ("Continue", self.immigration_queue),
            ],
        )

    # ============================================================
    # IMMIGRATION QUEUE
    # ============================================================

    def immigration_queue(self):
        self.set_scene(
            "IMMIGRATION",
            (
                "You enter the passport-control hall.\n\n"
                "The normal queue stretches across several barriers. "
                "A staff member stands beside the priority lane."
            ),
            [
                ("Join the normal line", self.normal_line),
                ("Ask about the priority lane", self.priority_lane),
                (
                    "Step aside and check your documents",
                    self.check_documents,
                ),
            ],
        )

    def normal_line(self):
        self._connection_minutes -= 25
        self._stress += 8

        self.set_scene(
            "IMMIGRATION QUEUE",
            (
                "The line crawls forward.\n\n"
                "Twenty-five minutes later, the passenger ahead of you "
                "walks away from the counter.\n\n"
                "The officer looks up."
            ),
            [
                ("Approach the officer", self.interview_question_one),
            ],
        )

    def priority_lane(self):
        self._connection_minutes -= 5
        self._stress += 3

        if self._connection_minutes <= 60:
            self._connection_minutes -= 7
            self._stress -= 4

            text = (
                "You show the employee your boarding pass.\n\n"
                "They check the departure time.\n\n"
                '"Go ahead. Priority lane."\n\n'
                "You reach the counter quickly."
            )

        else:
            self._connection_minutes -= 20
            self._stress += 5

            text = (
                "You ask to use the priority lane.\n\n"
                "The employee checks your boarding pass.\n\n"
                '"You still have time. Normal queue."\n\n'
                "The attempt cost you valuable minutes."
            )

        self.set_scene(
            "PRIORITY REQUEST",
            text,
            [
                ("Approach the officer", self.interview_question_one),
            ],
        )

    def check_documents(self):
        self._connection_minutes -= 4
        self._stress -= 2

        self.set_scene(
            "DOCUMENT CHECK",
            (
                "You step out of the flow of passengers and open your carry-on.\n\n"
                "Passport.\n"
                "Visa.\n"
                "I-20.\n"
                "Admission letter.\n"
                "Boarding pass.\n\n"
                "Everything appears to be there."
            ),
            [
                ("Approach immigration", self.interview_question_one),
            ],
        )

    # ============================================================
    # PRIMARY INTERVIEW
    # ============================================================

    def interview_question_one(self):
        self.set_scene(
            "IMMIGRATION INTERVIEW",
            (
                "The officer takes your passport and looks at the visa page.\n\n"
                '"What is the purpose of your trip?"'
            ),
            [
                ("Tourism", lambda: self.answer_purpose("tourism")),
                ("Study", lambda: self.answer_purpose("study")),
                ("Work", lambda: self.answer_purpose("work")),
            ],
        )

    def answer_purpose(self, answer):
        self._connection_minutes -= 2

        if answer == self.traveler["purpose"]:
            text = (
                '"Study."\n\n'
                "The officer continues typing without looking up."
            )

        else:
            self._suspicion += 20
            self._stress += 10

            text = (
                "The officer stops typing.\n\n"
                "They look at your visa.\n\n"
                "Then at you.\n\n"
                '"That is not what your documents indicate."'
            )

        self.set_scene(
            "IMMIGRATION INTERVIEW",
            text,
            [
                ("Continue", self.interview_question_two),
            ],
        )

    def interview_question_two(self):
        self.set_scene(
            "IMMIGRATION INTERVIEW",
            '"Where are you going?"',
            [
                ("Dallas", lambda: self.answer_destination("Dallas")),
                ("London", lambda: self.answer_destination("London")),
                ("New York", lambda: self.answer_destination("New York")),
            ],
        )

    def answer_destination(self, answer):
        self._connection_minutes -= 2

        if answer == self.traveler["destination"]:
            text = (
                '"Dallas."\n\n'
                "The officer glances at your itinerary."
            )

        else:
            self._suspicion += 15
            self._stress += 7

            text = (
                "The officer's eyes remain on the screen.\n\n"
                f'"Your itinerary says {self.traveler["destination"]}."'
            )

        self.set_scene(
            "IMMIGRATION INTERVIEW",
            text,
            [
                ("Continue", self.request_i20),
            ],
        )

    def request_i20(self):
        self._scene_title = "DOCUMENT REQUEST"

        self._story = (
            "The officer turns a page in your passport.\n\n"
            '"Show me your Form I-20."'
        )

        self.request_document(
            "i20",
            "Present your Form I-20",
        )

    # ============================================================
    # INTERVIEW RESULT
    # ============================================================

    def interview_result(self):
        if self._suspicion >= 30:
            self.set_scene(
                "REFERRED",
                (
                    "The officer keeps your passport.\n\n"
                    "Their expression gives very little away.\n\n"
                    '"Please follow me for additional screening."'
                ),
                [
                    ("Follow the officer", self.secondary_screening_start),
                ],
            )

        elif self._suspicion >= 15:
            self._connection_minutes -= 8
            self._stress += 5

            self.set_scene(
                "DOCUMENT VERIFICATION",
                (
                    "The officer stands and walks away with your passport "
                    "and I-20.\n\n"
                    "You wait at the counter.\n\n"
                    "Eight minutes later, they return.\n\n"
                    '"You may continue."'
                ),
                [
                    ("Head toward the gate", self.final_stage),
                ],
            )

        else:
            self.set_scene(
                "CLEARED",
                (
                    "The officer returns your documents.\n\n"
                    "\"You're good to continue.\"\n\n"
                    "You gather your things and step away from the counter."
                ),
                [
                    ("Head toward the gate", self.final_stage),
                ],
            )

    # ============================================================
    # SECONDARY SCREENING
    # ============================================================

    def secondary_screening_start(self):
        self._connection_minutes -= 10
        self._stress += 10

        self.set_scene(
            "SECONDARY SCREENING",
            (
                "A second officer leads you through a side door.\n\n"
                "The room is quieter than the immigration hall.\n\n"
                "Your passport is placed on the desk between you.\n\n"
                '"Where will you be staying?"'
            ),
            [
                (
                    "I have an address in Dallas",
                    lambda: self.answer_housing("address"),
                ),
                (
                    "I'll figure it out when I arrive",
                    lambda: self.answer_housing("unknown"),
                ),
                (
                    "I'm staying in London",
                    lambda: self.answer_housing("london"),
                ),
            ],
        )

    def answer_housing(self, answer):
        self._connection_minutes -= 3

        if answer == "address":
            self._suspicion -= 10
            self.clean_suspicion()

            text = (
                "You give the Dallas address.\n\n"
                "The officer enters it into the computer."
            )

        elif answer == "unknown":
            self._suspicion += 10
            self._stress += 5

            text = (
                "The officer pauses.\n\n"
                "They write something in the file."
            )

        else:
            self._suspicion += 20
            self._stress += 8

            text = (
                "The officer looks up immediately.\n\n"
                '"London?"'
            )

        self.set_scene(
            "SECONDARY SCREENING",
            text,
            [
                ("Continue", self.secondary_money_question),
            ],
        )

    def secondary_money_question(self):
        self.set_scene(
            "SECONDARY SCREENING",
            '"How much money do you currently have available?"',
            [
                ("About $350", lambda: self.answer_money(350)),
                ("About $3,500", lambda: self.answer_money(3500)),
                ("I'm not sure", lambda: self.answer_money(None)),
            ],
        )

    def answer_money(self, answer):
        self._connection_minutes -= 3

        if answer == self.traveler["available_funds"]:
            self._suspicion -= 5
            self.clean_suspicion()

            text = (
                "The officer records the amount without reacting."
            )

        elif answer is None:
            self._suspicion += 10
            self._stress += 5

            text = (
                "The officer stops writing.\n\n"
                '"You don\'t know?"'
            )

        else:
            self._suspicion += 20
            self._stress += 8

            text = (
                '"Show me evidence of those funds."'
            )

        self.set_scene(
            "SECONDARY SCREENING",
            text,
            [
                ("Continue", self.secondary_reason_question),
            ],
        )

    def secondary_reason_question(self):
        self.set_scene(
            "SECONDARY SCREENING",
            '"Why are you traveling to Dallas?"',
            [
                (
                    "To begin my studies",
                    lambda: self.answer_reason("study"),
                ),
                (
                    "For a vacation",
                    lambda: self.answer_reason("vacation"),
                ),
                (
                    "To look for work",
                    lambda: self.answer_reason("work"),
                ),
            ],
        )

    def answer_reason(self, answer):
        self._connection_minutes -= 3

        if answer == self.traveler["purpose"]:
            self._suspicion -= 10
            self.clean_suspicion()

            text = (
                "The answer matches your school documentation."
            )

        else:
            self._suspicion += 20
            self._stress += 10

            text = (
                "The officer stops typing.\n\n"
                "Your answer conflicts with what you said earlier."
            )

        self.set_scene(
            "SECONDARY SCREENING",
            text,
            [
                ("See decision", self.secondary_result),
            ],
        )

    def secondary_result(self):
        if self._suspicion >= 45:
            self.set_scene(
                "HELD FOR REVIEW",
                (
                    "The officer keeps your passport on the desk.\n\n"
                    '"We need to continue reviewing your case."\n\n'
                    "Somewhere outside the room, your connection clock "
                    "continues running."
                ),
                [
                    ("Restart run", self.restart),
                ],
            )

        elif self._suspicion >= 20:
            self._connection_minutes -= 10
            self._stress += 5

            self.set_scene(
                "VERIFICATION",
                (
                    "The officer leaves the room.\n\n"
                    "Ten minutes pass.\n\n"
                    "They eventually return with your passport.\n\n"
                    '"You may continue. Move quickly."'
                ),
                [
                    ("Run for the gate", self.final_stage),
                ],
            )

        else:
            self.set_scene(
                "CLEARED",
                (
                    "The officer returns your passport.\n\n"
                    '"Everything checks out."\n\n'
                    "The door opens back into the terminal."
                ),
                [
                    ("Head toward the gate", self.final_stage),
                ],
            )

    # ============================================================
    # CURRENT END
    # ============================================================

    def final_stage(self):
        if self._connection_minutes <= 0:
            title = "CONNECTION MISSED"

            text = (
                "The departure screen changes.\n\n"
                f"{self._gate} — GATE CLOSED\n\n"
                "Your flight is gone."
            )

        elif self._connection_minutes <= 15:
            title = "FINAL CALL"

            text = (
                f"Gate {self._gate}.\n\n"
                f"{self._connection_minutes} minutes remain.\n\n"
                "Your phone says the walk takes "
                f"{self._gate_walk_minutes} minutes.\n\n"
                "You need another plan."
            )

        else:
            title = "CONNECTION"

            text = (
                f"Gate {self._gate}.\n\n"
                f"{self._connection_minutes} minutes remain.\n\n"
                f"The airport map estimates a {self._gate_walk_minutes}-minute "
                "walk.\n\n"
                "For now, you still have time."
            )

        self.set_scene(
            title,
            text,
            [
                ("Restart run", self.restart),
            ],
        )


app = QGuiApplication(sys.argv)

engine = QQmlApplicationEngine()

game = BorderlineGame()

engine.rootContext().setContextProperty("game", game)

engine.load("Main.qml")

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())