import math

DEV_MAX = math.pow(2,15)
#print("DEV_MAX:", DEV_MAX)

f_range = 1e9 / 2  # 1 GHz z.B RFout = 19,25GHz - 20,25GHz -> f_RANGE = 1 GHz
t_range = 60e-6          # 20 us
f_DEV = 122.88e5 / 32
f_PFD = 122.88e6    # 122,88 MHz
f_RES = f_PFD/math.pow(2,25)
#print("f_RES:", f_RES)

CLK_2 = 1

DEV_OFFSET = round(math.log2(f_DEV/(f_RES*DEV_MAX)))
print("DEV_OFFSET:", DEV_OFFSET)

f_DEV_RES = f_RES * math.pow(2,DEV_OFFSET)
#print("f_DEV_RES:", f_DEV_RES)

DEV = round(f_DEV / (f_RES * math.pow(2,DEV_OFFSET)))
print("DEV:", DEV)

f_DEV_ACTUAL = (f_PFD/math.pow(2,25)) * (DEV * math.pow(2,DEV_OFFSET))
#print("f_DEV_ACTUAL:", f_DEV_ACTUAL)

N_steps = round(f_range / f_DEV_ACTUAL)
print("N_steps:", N_steps)

timer = t_range / N_steps
#print("timer:", timer)

CLK_1 = round(timer * f_PFD / CLK_2)
print("CLK1:", CLK_1)
print("CLK2:", CLK_2)





