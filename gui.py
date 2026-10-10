import tkinter as tk
from tkinter import ttk


class BorderlineGame:
    def __init__(self, root):
        self.root = root
        self.root.title("BORDERLINE")
        self.root.geometry("900x650")
        self.root.minsize(800, 600)

        # -------------------------
        # GAME STATE
        # -------------------------
        self.cash = 350
        self.battery = 61
        self.stress = 10
        self.suspicion = 0
        self.connection_minutes = 95

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

        self.build_interface()
        self.start_game()

    # -------------------------
    # INTERFACE
    # -------------------------

    def build_interface(self):
        title = tk.Label(
            self.root,
            text="BORDERLINE",
            font=("Arial", 28, "bold")
        )
        title.pack(pady=(20, 10))

        route = tk.Label(
            self.root,
            text="Lagos  →  London  →  Dallas",
            font=("Arial", 14)
        )
        route.pack()

        # Status area
        status_frame = ttk.Frame(self.root)
        status_frame.pack(fill="x", padx=40, pady=20)

        self.cash_label = ttk.Label(status_frame)
        self.cash_label.grid(row=0, column=0, padx=15)

        self.battery_label = ttk.Label(status_frame)
        self.battery_label.grid(row=0, column=1, padx=15)

        self.stress_label = ttk.Label(status_frame)
        self.stress_label.grid(row=0, column=2, padx=15)

        self.suspicion_label = ttk.Label(status_frame)
        self.suspicion_label.grid(row=0, column=3, padx=15)

        self.time_label = ttk.Label(status_frame)
        self.time_label.grid(row=0, column=4, padx=15)

        for i in range(5):
            status_frame.columnconfigure(i, weight=1)

        # Scene heading
        self.scene_title = tk.Label(
            self.root,
            text="",
            font=("Arial", 18, "bold")
        )
        self.scene_title.pack(pady=(10, 5))

        # Main narrative
        self.story_text = tk.Label(
            self.root,
            text="",
            font=("Arial", 13),
            wraplength=720,
            justify="left"
        )
        self.story_text.pack(padx=50, pady=20)

        # Choice area
        self.choice_frame = ttk.Frame(self.root)
        self.choice_frame.pack(fill="x", padx=100, pady=20)

        self.update_status()

    def update_status(self):
        self.cash_label.config(text=f"Cash: ${self.cash}")
        self.battery_label.config(text=f"Battery: {self.battery}%")
        self.stress_label.config(text=f"Stress: {self.stress}")
        self.suspicion_label.config(text=f"Suspicion: {self.suspicion}")
        self.time_label.config(
            text=f"Connection: {self.connection_minutes} min"
        )

    def show_scene(self, title, text, choices):
        self.scene_title.config(text=title)
        self.story_text.config(text=text)

        for widget in self.choice_frame.winfo_children():
            widget.destroy()

        for button_text, command in choices:
            button = ttk.Button(
                self.choice_frame,
                text=button_text,
                command=command
            )
            button.pack(fill="x", pady=6)

        self.update_status()

    # -------------------------
    # GAME START
    # -------------------------

    def start_game(self):
        self.connection_minutes -= 27

        self.show_scene(
            "Arrival",
            (
                "Your flight arrives 27 minutes late.\n\n"
                f"You now have {self.connection_minutes} minutes "
                "to make your connection."
            ),
            [
                ("Go directly to immigration", self.go_directly),
                ("Find a bathroom first", self.use_bathroom),
                (
                    "Ask an airport employee about your connection",
                    self.ask_employee
                ),
            ],
        )

    # -------------------------
    # FIRST DECISION
    # -------------------------

    def go_directly(self):
        self.stress += 5

        self.show_scene(
            "Immigration Hall",
            "You head straight toward immigration.",
            [("Continue", self.immigration_queue)],
        )

    def use_bathroom(self):
        self.connection_minutes -= 8
        self.stress -= 2

        self.show_scene(
            "Bathroom Stop",
            (
                "You stop at the bathroom.\n\n"
                "You feel slightly better, but time is ticking."
            ),
            [("Continue to immigration", self.immigration_queue)],
        )

    def ask_employee(self):
        self.connection_minutes -= 4
        self.stress -= 5

        self.show_scene(
            "Airport Employee",
            (
                "You find an airport employee and explain "
                "your tight connection."
            ),
            [("Continue to immigration", self.immigration_queue)],
        )

    # -------------------------
    # IMMIGRATION QUEUE
    # -------------------------

    def immigration_queue(self):
        self.show_scene(
            "Immigration",
            (
                "You reach immigration.\n\n"
                "The normal line is long, and your connection "
                "is getting tighter."
            ),
            [
                ("Join the normal line", self.normal_line),
                ("Ask to use the priority lane", self.priority_lane),
                (
                    "Step aside and check your documents first",
                    self.check_documents
                ),
            ],
        )

    def normal_line(self):
        self.connection_minutes -= 25
        self.stress += 8

        self.show_scene(
            "Immigration Queue",
            "You join the normal line and slowly move toward the front.",
            [("Approach the officer", self.interview_question_one)],
        )

    def priority_lane(self):
        self.connection_minutes -= 5
        self.stress += 3

        if self.connection_minutes <= 60:
            self.connection_minutes -= 7
            self.stress -= 4

            text = (
                "You explain your connection time to an officer.\n\n"
                "The officer looks at your boarding pass and lets "
                "you use the priority lane."
            )
        else:
            self.connection_minutes -= 20
            self.stress += 5

            text = (
                "You explain your connection time to an officer.\n\n"
                "The officer tells you to stay in the normal line."
            )

        self.show_scene(
            "Priority Lane",
            text,
            [("Approach the officer", self.interview_question_one)],
        )

    def check_documents(self):
        self.connection_minutes -= 4
        self.stress -= 2

        self.show_scene(
            "Document Check",
            (
                "You step aside and check your passport, visa, "
                "boarding pass, and school documents."
            ),
            [("Join immigration", self.interview_question_one)],
        )

    # -------------------------
    # IMMIGRATION INTERVIEW
    # -------------------------

    def interview_question_one(self):
        self.show_scene(
            "Immigration Interview",
            'Officer: "What is the purpose of your trip?"',
            [
                ("Tourism", lambda: self.answer_purpose("tourism")),
                ("Study", lambda: self.answer_purpose("study")),
                ("Work", lambda: self.answer_purpose("work")),
            ],
        )

    def answer_purpose(self, answer):
        self.connection_minutes -= 2

        if answer != self.traveler["purpose"]:
            self.suspicion += 20
            self.stress += 10

            text = (
                "The officer looks at your visa, then back at you.\n\n"
                '"That is not what your documents indicate."'
            )
        else:
            text = 'Officer: "Okay."'

        self.show_scene(
            "Immigration Interview",
            text,
            [("Continue", self.interview_question_two)],
        )

    def interview_question_two(self):
        self.show_scene(
            "Immigration Interview",
            'Officer: "Where are you going?"',
            [
                ("Dallas", lambda: self.answer_destination("Dallas")),
                ("London", lambda: self.answer_destination("London")),
                ("New York", lambda: self.answer_destination("New York")),
            ],
        )

    def answer_destination(self, answer):
        self.connection_minutes -= 2

        if answer != self.traveler["destination"]:
            self.suspicion += 15
            self.stress += 7

            text = (
                "The officer pauses.\n\n"
                f'"Your itinerary says {self.traveler["destination"]}."'
            )
        else:
            text = 'Officer: "Dallas. Understood."'

        self.show_scene(
            "Immigration Interview",
            text,
            [("Continue", self.interview_question_three)],
        )

    def interview_question_three(self):
        self.show_scene(
            "Immigration Interview",
            'Officer: "Do you have your school admission letter?"',
            [
                ("Yes", lambda: self.answer_school_letter(True)),
                ("No", lambda: self.answer_school_letter(False)),
            ],
        )

    def answer_school_letter(self, answer):
        self.connection_minutes -= 2

        if answer and self.traveler["has_school_letter"]:
            self.suspicion -= 5

            if self.suspicion < 0:
                self.suspicion = 0

            text = "You hand the officer your admission letter."

        elif not answer and self.traveler["has_school_letter"]:
            self.suspicion += 15
            self.stress += 8

            text = (
                "You hesitate even though the document "
                "is sitting in your bag."
            )

        else:
            self.suspicion += 20
            self.stress += 10
            text = "The officer looks unconvinced."

        self.show_scene(
            "Interview Result",
            text,
            [("See decision", self.interview_result)],
        )

    def interview_result(self):
        if self.suspicion >= 30:
            self.show_scene(
                "Immigration Decision",
                (
                    "The officer closes your passport.\n\n"
                    '"Please follow me for additional screening."'
                ),
                [("Follow the officer", self.secondary_screening_start)],
            )

        elif self.suspicion >= 15:
            self.connection_minutes -= 8
            self.stress += 5

            self.show_scene(
                "Document Verification",
                (
                    "The officer studies your documents for several minutes.\n\n"
                    '"You may continue."'
                ),
                [("Continue", self.final_stage)],
            )

        else:
            self.show_scene(
                "Cleared",
                (
                    "The officer returns your passport.\n\n"
                    '"You are good to continue. Have a safe trip."'
                ),
                [("Head toward the gate", self.final_stage)],
            )

    # -------------------------
    # SECONDARY SCREENING
    # -------------------------

    def secondary_screening_start(self):
        self.connection_minutes -= 10
        self.stress += 10

        self.show_scene(
            "Secondary Screening",
            (
                "You are taken to a smaller waiting area.\n\n"
                "Another officer places your passport on the desk.\n\n"
                '"Where will you be staying?"'
            ),
            [
                (
                    "I have an address in Dallas",
                    lambda: self.answer_housing("address")
                ),
                (
                    "I will figure it out when I arrive",
                    lambda: self.answer_housing("unknown")
                ),
                (
                    "I am staying in London",
                    lambda: self.answer_housing("london")
                ),
            ],
        )

    def answer_housing(self, answer):
        self.connection_minutes -= 3

        if answer == "address" and self.traveler["has_housing_address"]:
            self.suspicion -= 10
            text = "You provide the Dallas address from your documents."

        elif answer == "unknown":
            self.suspicion += 10
            self.stress += 5
            text = "The officer writes something down."

        else:
            self.suspicion += 20
            self.stress += 8
            text = "The officer looks confused by your answer."

        if self.suspicion < 0:
            self.suspicion = 0

        self.show_scene(
            "Secondary Screening",
            text,
            [("Continue", self.secondary_money_question)],
        )

    def secondary_money_question(self):
        self.show_scene(
            "Secondary Screening",
            'Officer: "How much money do you have available for the trip?"',
            [
                ("About $350", lambda: self.answer_money(350)),
                ("About $3,500", lambda: self.answer_money(3500)),
                ("I am not sure", lambda: self.answer_money(None)),
            ],
        )

    def answer_money(self, answer):
        self.connection_minutes -= 3

        if answer == self.traveler["available_funds"]:
            self.suspicion -= 5
            text = "Your answer matches the money you have available."

        elif answer is None:
            self.suspicion += 10
            self.stress += 5
            text = "The officer does not seem satisfied."

        else:
            self.suspicion += 20
            self.stress += 8
            text = "The officer asks you to prove that amount."

        if self.suspicion < 0:
            self.suspicion = 0

        self.show_scene(
            "Secondary Screening",
            text,
            [("Continue", self.secondary_reason_question)],
        )

    def secondary_reason_question(self):
        self.show_scene(
            "Secondary Screening",
            'Officer: "Why are you traveling to Dallas?"',
            [
                (
                    "To begin my studies",
                    lambda: self.answer_reason("study")
                ),
                (
                    "For a vacation",
                    lambda: self.answer_reason("vacation")
                ),
                (
                    "To look for work",
                    lambda: self.answer_reason("work")
                ),
            ],
        )

    def answer_reason(self, answer):
        self.connection_minutes -= 3

        if answer == self.traveler["purpose"]:
            self.suspicion -= 10
            text = "The answer matches your school documents."
        else:
            self.suspicion += 20
            self.stress += 10
            text = "Your answer conflicts with the documents already reviewed."

        if self.suspicion < 0:
            self.suspicion = 0

        self.show_scene(
            "Secondary Screening",
            text,
            [("See decision", self.secondary_result)],
        )

    def secondary_result(self):
        if self.suspicion >= 45:
            text = (
                "The officer keeps your passport on the desk.\n\n"
                '"We need to continue reviewing your case."\n\n'
                "Your connection is now in serious danger."
            )

        elif self.suspicion >= 20:
            self.connection_minutes -= 10
            self.stress += 5

            text = (
                "The officer leaves to verify your documents.\n\n"
                "Several minutes later, the officer returns.\n\n"
                '"You may continue, but move quickly."'
            )

        else:
            text = (
                "The officer returns your passport.\n\n"
                '"Everything checks out. You may continue."'
            )

        self.show_scene(
            "Secondary Screening Result",
            text,
            [("Continue", self.final_stage)],
        )

    # -------------------------
    # END OF CURRENT BUILD
    # -------------------------

    def final_stage(self):
        if self.connection_minutes <= 0:
            text = (
                "You hear the announcement over the terminal speakers.\n\n"
                "Your flight has departed.\n\n"
                "CONNECTION MISSED"
            )

        elif self.connection_minutes <= 15:
            text = (
                "Your gate is closing soon.\n\n"
                "You need to move. Now."
            )

        else:
            text = (
                f"You still have {self.connection_minutes} minutes "
                "to reach your gate.\n\n"
                "The journey is not over yet."
            )

        self.show_scene(
            "Current End of Build",
            text,
            [
                ("Restart Game", self.restart_game),
                ("Exit", self.root.destroy),
            ],
        )

    def restart_game(self):
        self.cash = 350
        self.battery = 61
        self.stress = 10
        self.suspicion = 0
        self.connection_minutes = 95

        self.start_game()


root = tk.Tk()
game = BorderlineGame(root)
root.mainloop()