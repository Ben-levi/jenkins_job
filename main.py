from datetime import datetime

current_datetime = datetime.now()
day_of_week = current_datetime.strftime("%A")

print(f"Current date and time: {current_datetime}")
print(f"Day of the week: {day_of_week}")
