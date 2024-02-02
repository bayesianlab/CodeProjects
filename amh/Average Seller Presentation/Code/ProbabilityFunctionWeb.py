import dash
import numpy as np
from dash import Input, Output, dcc, html
import plotly.express as px
import dash_bootstrap_components as dbc
import numpy as np 

def prob(x, s,m,w):
    return (1./(1+np.exp(-w))) * (1./(1+np.exp(8*np.exp(s)*(x - m) )))

def wrap(row):
    return prob(row.iloc[0], row.iloc[1], row.iloc[2], row.iloc[3])


x=np.arange(-2, 2, 0.01)

app = dash.Dash(__name__)



graph = dcc.Graph(id="PDF")

@app.callback(Output('myoutput',component_property='children'),Input('s-slider', 'value'))
def update_output(input_value):
    return f'S:  {input_value}'

@app.callback(Output('myoutputm',component_property='children'),Input('m-slider', 'value'))
def update_output(input_value):
    return f'M:  {input_value}'

@app.callback(Output('myoutputw',component_property='children'),Input('w-slider', 'value'))
def update_output(input_value):
    return f'W:  {input_value}'

@app.callback(
    Output("PDF", "figure"),
    Input("s-slider", "value"),
    Input("m-slider", "value"),
    Input("w-slider", "value")
)
def graph_line(s,m,w):
    s=float(s)
    m=float(m)
    w=float(w) 
    fig = px.line(x=x, y=prob(x,s,m,w))
    fig.update_layout(yaxis_range=[-.1,1.2])
    return fig


smarks={}
mmarks={}
wmarks={}
for i in np.arange(-5,5,step=.5):
    smarks[i] = str(i)
for i in np.arange(-2,2,step=.25):
    mmarks[i] = str(i)
for i in np.arange(-5,10,step=.5):
    wmarks[i] = str(i)
app.layout = dbc.Container(
    [
        html.H1("PDF"),
        html.Div(id='myoutput'),
        html.Div(id='myoutputm'),
        html.Div(id='myoutputw'),
        dbc.Row(dbc.Col(graph)),
        html.Div(
            ["S",
            dcc.Slider(
                -5,5,step=.01, value=-1,marks=smarks,
                id='s-slider'
            ),
            "M",
            dcc.Slider(
                -2,2,step=.01, value=0,marks=mmarks,
                id='m-slider'
            ),
            "W",
            dcc.Slider(
                -5,10,step=.1, value=10,marks=wmarks,
                id='w-slider'
            )
            ]
        )
    ]
)

if __name__ == '__main__':
    app.run(debug=True)