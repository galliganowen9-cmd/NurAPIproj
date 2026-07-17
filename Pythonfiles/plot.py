import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
import subprocess
subprocess.run(["sudo","/home/samalab/NurAPI/filter/plotfil.sh"])

#create a check here for files before loading data.
file_path = Path("/home/samalab/NurAPI/data/organizeddata/gps_x_values.txt")
file_path2 = Path("/home/samalab/NurAPI/data/organizeddata/gps_y_values.txt")
file_path3 = Path("/home/samalab/NurAPI/data/organizeddata/drone_utc_values.txt")
while True:
	if not file_path.exists() and file_path2.exists() and file_path3.exists:
		print("Does not exist")
	elif (file_path.stat().st_size == 0) or (file_path2.stat().st_size == 0) or (file_path3.stat().st_size == 0):
		print("Exists, no content")
	else:
		print("exists and has content")
		break
print("Rest of progam")

x = np.atleast_1d(np.loadtxt("/home/samalab/NurAPI/data/organizeddata/gps_x_values.txt"))
y = np.atleast_1d(np.loadtxt("/home/samalab/NurAPI/data/organizeddata/gps_y_values.txt"))
drone_time = np.atleast_1d(np.loadtxt("/home/samalab/NurAPI/data/organizeddata/drone_utc_values.txt"))


tag_time = np.atleast_1d(np.loadtxt("/home/samalab/NurAPI/data/organizeddata/rfid_utc_values.txt"))
tag_rssi = np.atleast_1d(np.loadtxt("/home/samalab/NurAPI/data/organizeddata/average_rssi.txt"))



if not (len(x) == len(y) == len(drone_time)):
    raise ValueError(
        "GPS X, GPS Y, and drone UTC files must have the same number of values."
    )

if len(tag_time) != len(tag_rssi):
    raise ValueError(
        "Tag UTC and RSSI files must have the same number of values."
    )



valid_drone_rows = ~(
    (x == 0) &
    (y == 0) &
    (drone_time == 0)
)

x = x[valid_drone_rows]
y = y[valid_drone_rows]
drone_time = drone_time[valid_drone_rows]



order = np.argsort(drone_time)

drone_time = drone_time[order]
x = x[order]
y = y[order]


valid_tag_rows = (
    (tag_time >= drone_time[0]) &
    (tag_time <= drone_time[-1])
)

tag_time = tag_time[valid_tag_rows]
tag_rssi = tag_rssi[valid_tag_rows]




unique_tag_time, group_number = np.unique(
    tag_time,
    return_inverse=True
)


scan_count = np.bincount(group_number)


rssi_sum = np.bincount(
    group_number,
    weights=tag_rssi
)


average_rssi = rssi_sum / scan_count




tag_x = np.interp(
    unique_tag_time,
    drone_time,
    x
)

tag_y = np.interp(
    unique_tag_time,
    drone_time,
    y
)




marker_size = 30 + scan_count * 25




fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")



ax.plot3D(
    x,
    y,
    drone_time,
    label="Drone path"
)


scan_points = ax.scatter3D(
    tag_x,
    tag_y,
    unique_tag_time,
    c=average_rssi,
    s=marker_size,
    label="RFID scans"
)




ax.set_xlabel("GPS X")
ax.set_ylabel("GPS Y")
ax.set_zlabel("UTC")
ax.set_title("Drone Path and RFID RSSI")

ax.legend()

fig.colorbar(
    scan_points,
    ax=ax,
    label="Average RSSI (dBm)",
    pad=0.1
)

plt.show()
