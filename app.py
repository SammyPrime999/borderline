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

        self.reset_state()
        self.start_game()

    # --------------------------------------------------
    # STATE
    # --------------------------------------------------

    def reset_state(self):
        self._cash = 350
        self._battery = 61
        self._stress = 10
        self._suspicion = 0
        self._connection_minutes = 95

        self.traveler = {
            "name": "Samuel",
            "purpose": "study",
            "destination": "Dallas",
            "stay_days": 120,
            "has_return_ticket": False,
            "has_school_letter": True,
            "has_housing_address": True,
            "available_funds": 350,
        }

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
    def sceneTitle(self):
        return self._scene_title

    @Property(str, notify=stateChanged)
    def story(self):
        return self._story

    @Property("QStringList", notify=stateChanged)
    def choices(self):
        return self._choices

    # --------------------------------------------------
    # CORE SCENE SYSTEM
    # --------------------------------------------------

    def set_scene(self, title, story, choices):
        self._scene_title = title
        self._story = story

        self._choices = [label for label, _ in choices]
        self._choice_actions = [action for _, action in choices]

        self.stateChanged.emit()

    @Slot(int)
    def choose(self, index):
        if 0 <= index < len(self._choice_actions):
            action = self._choice_actions[index]
            action()

    @Slot()
    def restart(self):
        self.reset_state()
        self.start_game()

    def clean_suspicion(self):
        if self._suspicion < 0:
            self._suspicion = 0

    # --------------------------------------------------
    # ARRIVAL
    # --------------------------------------------------

    def start_game(self):
        self._connection_minutes -= 27

        self.set_scene(
            "ARRIVAL",
            (
                "Your flight touches down 27 minutes late.\n\n"
                f"You now have {self._connection_minutes} minutes "
                "to make your connection."
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
            "You head straight toward immigration.",
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
                "You feel slightly better, but you just burned "
                "eight minutes."
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
                "You find an airport employee and explain that "
                "your connection is getting tight."
            ),
            [
                ("Continue to immigration", self.immigration_queue),
            ],
        )

    # --------------------------------------------------
    # IMMIGRATION QUEUE
    # --------------------------------------------------

    def immigration_queue(self):
        self.set_scene(
            "IMMIGRATION",
            (
                "You reach passport control.\n\n"
                "The normal line stretches across the hall. "
                "Your connection is getting tighter."
            ),
            [
                ("Join the normal line", self.normal_line),
                ("Ask to use the priority lane", self.priority_lane),
                (
                    "Step aside and check your documents first",
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
                "You join the normal line.\n\n"
                "Twenty-five minutes disappear before you finally "
                "reach the front."
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
                "You show the officer your boarding pass.\n\n"
                "They glance at the departure time and wave you "
                "into the priority lane."
            )

        else:
            self._connection_minutes -= 20
            self._stress += 5

            text = (
                "You ask for the priority lane.\n\n"
                "The officer looks at your boarding pass.\n\n"
                "\"You still have time. Normal queue.\"\n\n"
                "That gamble cost you."
            )

        self.set_scene(
            "PRIORITY REQUEST",
            text,
            [
                ("Approach immigration officer", self.interview_question_one),
            ],
        )

    def check_documents(self):
        self._connection_minutes -= 4
        self._stress -= 2

        self.set_scene(
            "DOCUMENT CHECK",
            (
                "You step aside.\n\n"
                "Passport. Visa. Boarding pass. School letter.\n\n"
                "Everything appears to be there."
            ),
            [
                ("Join immigration", self.interview_question_one),
            ],
        )

    # --------------------------------------------------
    # PRIMARY INTERVIEW
    # --------------------------------------------------

    def interview_question_one(self):
        self.set_scene(
            "IMMIGRATION INTERVIEW",
            'The officer opens your passport.\n\n"What is the purpose of your trip?"',
            [
                ("Tourism", lambda: self.answer_purpose("tourism")),
                ("Study", lambda: self.answer_purpose("study")),
                ("Work", lambda: self.answer_purpose("work")),
            ],
        )

    def answer_purpose(self, answer):
        self._connection_minutes -= 2

        if answer == self.traveler["purpose"]:
            text = '"Study. Okay."'

        else:
            self._suspicion += 20
            self._stress += 10

            text = (
                "The officer looks at your visa.\n\n"
                "Then back at you.\n\n"
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
            text = '"Dallas. Understood."'

        else:
            self._suspicion += 15
            self._stress += 7

            text = (
                "The officer pauses.\n\n"
                f'"Your itinerary says {self.traveler["destination"]}."'
            )

        self.set_scene(
            "IMMIGRATION INTERVIEW",
            text,
            [
                ("Continue", self.interview_question_three),
            ],
        )

    def interview_question_three(self):
        self.set_scene(
            "IMMIGRATION INTERVIEW",
            '"Do you have your school admission letter?"',
            [
                ("Yes", lambda: self.answer_school_letter(True)),
                ("No", lambda: self.answer_school_letter(False)),
            ],
        )

    def answer_school_letter(self, answer):
        self._connection_minutes -= 2

        if answer and self.traveler["has_school_letter"]:
            self._suspicion -= 5
            self.clean_suspicion()

            text = (
                "You hand over the admission letter.\n\n"
                "The officer compares it with your passport."
            )

        elif not answer and self.traveler["has_school_letter"]:
            self._suspicion += 15
            self._stress += 8

            text = (
                "You say no.\n\n"
                "The document is sitting inside your bag."
            )

        else:
            self._suspicion += 20
            self._stress += 10

            text = "The officer looks unconvinced."

        self.set_scene(
            "INTERVIEW RESULT",
            text,
            [
                ("See decision", self.interview_result),
            ],
        )

    def interview_result(self):
        if self._suspicion >= 30:
            self.set_scene(
                "REFERRED",
                (
                    "The officer closes your passport.\n\n"
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
                    "The officer disappears with your documents.\n\n"
                    "Eight long minutes pass.\n\n"
                    "They return your passport.\n\n"
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
                    "The officer returns your passport.\n\n"
                    '"You are good to continue. Have a safe trip."'
                ),
                [
                    ("Head toward the gate", self.final_stage),
                ],
            )

    # --------------------------------------------------
    # SECONDARY SCREENING
    # --------------------------------------------------

    def secondary_screening_start(self):
        self._connection_minutes -= 10
        self._stress += 10

        self.set_scene(
            "SECONDARY SCREENING",
            (
                "A second officer takes your passport.\n\n"
                "You are led into a smaller room away from "
                "the main immigration hall.\n\n"
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

        if answer == "address" and self.traveler["has_housing_address"]:
            self._suspicion -= 10

            text = (
                "You provide the Dallas address.\n\n"
                "The officer checks it against your paperwork."
            )

        elif answer == "unknown":
            self._suspicion += 10
            self._stress += 5

            text = (
                "The officer says nothing.\n\n"
                "They write something in the file."
            )

        else:
            self._suspicion += 20
            self._stress += 8

            text = (
                "The officer looks up immediately.\n\n"
                '"London?"'
            )

        self.clean_suspicion()

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
            '"How much money do you have available for the trip?"',
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

            text = (
                "The amount matches the funds you have available."
            )

        elif answer is None:
            self._suspicion += 10
            self._stress += 5

            text = (
                "The officer leans back.\n\n"
                '"You don\'t know?"'
            )

        else:
            self._suspicion += 20
            self._stress += 8

            text = (
                "The officer turns the monitor toward themselves.\n\n"
                '"Show me proof of those funds."'
            )

        self.clean_suspicion()

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

            text = (
                "The answer matches your school documents."
            )

        else:
            self._suspicion += 20
            self._stress += 10

            text = (
                "The officer stops writing.\n\n"
                "Your answer conflicts with the documents "
                "already reviewed."
            )

        self.clean_suspicion()

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
                    "The officer keeps your passport.\n\n"
                    '"We need to continue reviewing your case."\n\n'
                    "You watch the minutes disappear from the clock.\n\n"
                    "Your connection is effectively lost."
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
                    "They finally return your passport.\n\n"
                    '"You may continue, but move quickly."'
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
                    '"Everything checks out. You may continue."'
                ),
                [
                    ("Head toward the gate", self.final_stage),
                ],
            )

    # --------------------------------------------------
    # END OF CURRENT BUILD
    # --------------------------------------------------

    def final_stage(self):
        if self._connection_minutes <= 0:
            title = "CONNECTION MISSED"

            text = (
                "The departure board changes.\n\n"
                "GATE CLOSED.\n\n"
                "Your flight is gone."
            )

        elif self._connection_minutes <= 15:
            title = "FINAL CALL"

            text = (
                f"{self._connection_minutes} minutes remain.\n\n"
                "Your gate is closing.\n\n"
                "You need to move. Now."
            )

        else:
            title = "CONNECTION"

            text = (
                f"{self._connection_minutes} minutes remain.\n\n"
                "You still have time to reach your gate.\n\n"
                "The journey is not over yet."
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