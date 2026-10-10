cash = 350
battery = 61
stress = 10
connection_minutes = 95


def show_status():
    print(f"Cash: ${cash}")
    print(f"Battery: {battery}%")
    print(f"Stress: {stress}")
    print(f"Connection time: {connection_minutes} minutes")


print("BORDERLINE")
print()

print("Route: Lagos -> London -> Dallas")
show_status()
print()

print("Your flight arrives 27 minutes late.")
connection_minutes -= 27

print(f"You now have {connection_minutes} minutes to make your connection.")
print()

print("1. Go directly to immigration")
print("2. Find a bathroom first")
print("3. Ask an airport employee about your connection")

choice = input("\nWhat do you do? ")

if choice == "1":
    stress += 5
    print("\nYou head straight toward immigration.")

elif choice == "2":
    connection_minutes -= 8
    stress -= 2
    print("\nYou stop at the bathroom. Time is ticking.")

elif choice == "3":
    connection_minutes -= 4
    stress -= 5
    print("\nYou find an airport employee and explain your tight connection.")

else:
    print("\nInvalid choice.")

print()
print("UPDATED STATUS")
show_status()

print()
print("You reach immigration.")
print("The normal line is long, and your connection is getting tighter.")
print()

print("1. Join the normal line")
print("2. Ask an officer if you can use the priority lane")
print("3. Step aside and check your documents first")

immigration_choice = input("\nWhat do you do? ")

if immigration_choice == "1":
    connection_minutes -= 25
    stress += 8
    print("\nYou join the normal line and slowly move toward the front.")

elif immigration_choice == "2":
    connection_minutes -= 5
    stress += 3
    print("\nYou explain your connection time to an officer.")

    if connection_minutes <= 60:
        print("The officer lets you use the priority lane.")
        connection_minutes -= 7
        stress -= 4
    else:
        print("The officer tells you to stay in the normal line.")
        connection_minutes -= 20
        stress += 5

elif immigration_choice == "3":
    connection_minutes -= 4
    stress -= 2
    print("\nYou step aside and check your passport, visa, and boarding pass.")

else:
    print("\nInvalid choice.")

print()
print("CURRENT STATUS")
show_status()