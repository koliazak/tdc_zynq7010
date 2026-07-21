import csv
import matplotlib.pyplot as plt
from collections import Counter


RESOLUTION       = 128
CSV_FILE = "tdc_data.csv"

x = []
y = []

with open(CSV_FILE, mode='r', encoding='utf-8') as f:
	reader = csv.DictReader(f)

	current_step = None
	current_phase = 0.0
	current_ones = []


	for row in reader:
		step_id = int(row["Step"])
		phase_ps = float(row["Phase_step_ps"])
		popcount = int(row["PopCount"])

		if current_step is not None and current_step != step_id:
			most_common_popcount = Counter(current_ones).most_common(1)[0][0]
			x.append(current_phase)
			y.append(most_common_popcount)
			current_ones.clear()
		current_step = step_id
		current_phase = phase_ps
		current_ones.append(popcount)
	
	if (current_ones):
		most_common_popcount = Counter(current_ones).most_common(1)[0][0]
		x.append(current_phase)
		y.append(most_common_popcount)

print(f"Processed {len(x)} phase steps.")


plt.step(x, y, linewidth=2, zorder=2, where='post')

plt.title("TDC analyzation")
plt.xlabel("Time [ps]")
plt.ylabel("Thermometer Code (Popcount mode)")

plt.grid(True)
plt.tight_layout()
plt.savefig("TDC.png", dpi=300)
plt.show()

