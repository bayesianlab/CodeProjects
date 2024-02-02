import plotly.graph_objects as go
import pandas as pd 
import numpy as np

def prob(x, s,m,w):
    return (1./(1+np.exp(-w))) * (1./(1+np.exp(8*np.exp(s)*(x - m) )))

def wrap(row):
    return prob(row.iloc[0], row.iloc[1], row.iloc[2], row.iloc[3])

# N = 1000
# x = np.linspace(-2,2,N)
# s = np.linspace(-5,5,N)
# m = np.linspace(-2,2,N)
# w = np.linspace(-10,10,N)
# data = pd.DataFrame({"S":s, "M":m, "W":w})
# Add traces, one for each slider step


s=-1.5
m=0
w=0

fig = go.Figure()
x=np.arange(-2, 2, 0.01)
z = np.arange(0, 3, 0.1)
for step in np.arange(0, 4, 0.1):
    fig.add_trace(
        go.Scatter(
            visible=False,
            line=dict(color="#00CED1", width=6),
            name="𝜈 = " + str(step),
            x=np.arange(-2, 2, 0.01),
            y=prob(x, s+step,m,w)))

# Make 10th trace visible
fig.data[10].visible = True

# Create and add slider
steps = []
for i in range(len(z)):
    step = dict(
        method="update",
        args=[{"visible": [False] * len(fig.data)},
              {"title": "Slider switched to step: " + str(s + z[i])}],  # layout attribute
    )
    step["args"][0]["visible"][i] = True  # Toggle i'th trace to "visible"
    steps.append(step)

sliders = [dict(
    active=10,
    currentvalue={"prefix": "S value: "},
    pad={"t": 50},
    steps=steps
)]

fig.update_layout(
    sliders=sliders
)

fig.show()



