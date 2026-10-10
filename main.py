cash = 350
battery = 61
stress = 10
connection_minutes = 95

print("BORDERLINE")
print()

print("Route: Lagos -> London -> Dallas")
print(f"Cash: ${cash}")
print(f"Battery: {battery}%")
print(f"Stress: {stress}")
print(f"Connection time: {connection_minutes} minutes")
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
print(f"Cash: ${cash}")
print(f"Battery: {battery}%")
print(f"Stress: {stress}")
print(f"Connection time: {connection_minutes} minutes")