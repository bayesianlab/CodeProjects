#%% 
from dash import Dash, html, dcc, callback, Output, Input, dash_table
import dash_bootstrap_components as dbc
import plotly.express as px
import pandas as pd

just_data = pd.read_csv('fromsql.csv')
just_data = just_data[['Dt', 'LookCnt']]

titles = ('Begin Dt', 'End Dt', 'Mean LookCnt', 'Std LookCnt', 'N Obs')
data = (just_data['Dt'].min(), just_data['Dt'].max(), round(just_data['LookCnt'].mean(),3),
         round(just_data['LookCnt'].std(),3), just_data.shape[0])
table = pd.DataFrame(dict(zip(titles, data)), index=[0])


df = pd.read_csv('dataset_cell1.csv')
df['Dt'] = pd.to_datetime(df['Dt'])
df.sort_values(by='Dt', inplace=True)

df2 = pd.read_csv('dataset_cell2.csv')
df2['Dt'] = pd.to_datetime(df2['Dt'])
df2.sort_values(by='Dt', inplace=True)

app = Dash(__name__)

fonts = {'arial':'Arial'}

colors = {'checkboxes':'rgb(0, 255, 255)', 'checkbox-content':'rgb(64,64,64)',
          'main-content':'rgb(160,160,160)'}

class CSSHeaderStyle:

    def __init__(self, text) -> None:
        self.style = {'textAlign':'center', 
                      'font-family':fonts['arial']}
        self.text = text

class CSSCheckboxStyle:

    def __init__(self):
        self.style = {'background-color':colors['checkbox-content'],
                      'border-radius':'5px', 
                      'color':colors['checkboxes'],
                      'font-family':fonts['arial'],
                      'padding':'15px'}
class CSSSidenav:
    def __init__(self):
        self.style = {'background-color':colors['checkbox-content'],
                      'width':'200px',
                      'height':'100%',
                      'position':'fixed',
                      'z-index':1,
                      'top':0,
                      'left':0,
                      'bottom':0,
                      'padding-top':'20px',
                      'font-family':fonts['arial'],
                      'color':colors['checkboxes']}
        
class ContentStyle:

    def __init__(self) -> None:
        self.style = {'margin-left': "18rem",
                      'margin-right': '2rem',
                      'padding':'2rem 1rem'}


class UlStyle:
    def __init__(self, text_list) -> None:
        self.text_list = text_list
        self.style = {'color':'white', 
                      'font-family':fonts['arial']}

text = '''
                Time Series of LookCnt
                '''
zero_header = CSSHeaderStyle(text)
text = """
        Adding Time Features One At A Time
        """
first_header = CSSHeaderStyle(text)
text = """
        Adding Continuous Features One At A Time
        """
second_header = CSSHeaderStyle(text)
textlist = ['Predict 5 days out', 'Iterate by 1 day', 
        'Endpoint no adjustment made (last 5 days decrease in out of sample size)',
        'Take the average of MAE for each split point']
experiment_list = UlStyle(textlist)
divcontent = ContentStyle()
main_content_style = CSSCheckboxStyle()
sidenav = CSSSidenav()

sidebar = html.Div(html.H2('Contents'), style=sidenav.style)

time_series = px.line(just_data, x='Dt', y='LookCnt')

top_header = html.H1(children=zero_header.text, style=zero_header.style)
summary_table =  dash_table.DataTable(table.to_dict('records'), 
                                      style_cell={'color':'black','textAlign':'center'})
content0 = html.Div([top_header,summary_table,dcc.Graph(id='time-series-graph', figure=time_series)],
                    style=main_content_style.style)

content1_header = html.H1(children=first_header.text, style=first_header.style)

content1 =  html.Div([content1_header,
                      html.Ul([html.Li(x) for x in experiment_list.text_list], style=experiment_list.style),
                        html.Div(dcc.Checklist(options=df['Model Name'].unique(),
                                            value=['Sheet'], id='check-selection')),
                        dcc.Graph(id='graph-content', figure={}),
                        dash_table.DataTable(id='updating-table', data=df.to_dict('records'), 
                                             style_cell={'color':'black'})
                        ],  
                        style=main_content_style.style)

content2 = html.Div([html.H1(children=second_header.text,  style=second_header.style),
                      html.Ul([html.Li(x) for x in experiment_list.text_list], style=experiment_list.style),
                             html.Div([dcc.Checklist(options=df2['Model Name'].unique(), value=['Sheet'],
                                                         id='check-selection-2')]),
                                 dcc.Graph(id='graph-content-2', figure={})],style=main_content_style.style)

content = html.Div([content0, content1, content2], style=divcontent.style)

app.layout = html.Div([sidebar, content], style={'background-color':colors['main-content']})
                                 

@callback(Output('updating-table', 'data'), Input('check-selection', 'value'))
def update_table(value):
    
    tmp = df[df['Model Name'].isin(value)].copy() 
    tmp = tmp[tmp['Metric']=='MAE']
    tmp.sort_values(by='Metric Value', inplace=True, ascending=False)
    tmp = tmp[['Model Name', 'Metric', 'Metric Value']].groupby(['Model Name', 'Metric']).mean()
    tmp.reset_index(inplace=True)
    tmp['Metric Value'] = tmp['Metric Value'].round(3)
    return tmp.to_dict('records')

@callback(
    Output('graph-content', 'figure'),
    Input('check-selection', 'value')
)
def update_graph(value):
    dff = df[df['Model Name'].isin(value)].copy()
    dff = dff.copy()
    dff = dff[dff['Metric']=='MAE']
    cmap = {'Sheet':'#FF0000', 'DayNum':'black', 'DayNum + MonthNum':'green', 'DayNum + MonthNum + YearNum':'blue'}
    return px.line(dff, x='Dt', y='Metric Value', color='Model Name', color_discrete_map=cmap)

@callback(
    Output('graph-content-2', 'figure'),
    Input('check-selection-2', 'value')
)
def update_graph2(value):
    dff = df2[df2['Model Name'].isin(value)].copy()
    dff = dff.copy()
    dff = dff[dff['Metric']=='MAE']
    cmap = {'Sheet':'#FF0000', 'MarketEarlyClose':'black', 
            'MarketEarlyClose + FirstBusDay':'green', 'MarketEarlyClose + FirstBusDay + LastBusDay':'blue',
            'MarketEarlyClose + FirstBusDay + LastBusDay + ShortWeek':'violet'}
    return px.line(dff, x='Dt', y='Metric Value', color='Model Name', color_discrete_map=cmap)

if __name__ == '__main__':
    app.run(debug=True, port=3041)