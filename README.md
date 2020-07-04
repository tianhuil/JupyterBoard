# JupyterBoard
Build automatically-updating hosted dashboards built from your Jupyter Notebooks

## Use Case:
1. Have a regularly updating stream of data and
2. Perform some transformations as the data updates and
3. Plot the results for everyone to see:

For this use case, you need a hosted, regularly automatically-updating dashboard.  Maintaining hosting and updating the dashboard is a pain.  The following use cases show all the code needed in a Jupyter Notebook to build an automatically-updating hosted dashboard.

### 1. App Usage
Quick dashbboard for app usage segmented by platform and country.  I want this data updated hourly.
```python
# User.ipynb

# Run this once an hour
@cache('stock %Y-%m-%d %H')
def read_sql_db():
    # read data from app sql database
    return pd.read_sql(...)

df = read_sql_db()

df.groupby('platform')['usage'].plot.bar(title='By Platform')

df.groupby('country')['usage'].plot.bar(title='By Country')
```

### 2. Stock Price Indicator
Plot a custom indicator against the latest stock prices for SPY, updated minutely:
```python
# Stock.ipynb
yesterday = ...
week_ago = ...

# Run this once a minute
@cache('users %Y-%m-%d %H:%M')
def read_stocks():
    # Connect to Bloomberg using Python Binding
    conn = pdblp.BCon(...)
    df = con.bdh('SPY US Equity', 'PX_LAST', week_ago, yesterday)
    df['indicator'] = custom_indicator(df['SPY US Equity'])
    return df

df = read_stocks()

df[['SPY US Equity', 'indicator']].plot()
```


### 3. COVID-19 Dashboard
Plot expoential moving average of new versus existing COVID-19 infections for a selectable state, updated daily:

```python
# COVID.ipynb

US_COVID_URL = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv'

# Run this once a day
@cache('covid %Y-%m-%d')
def read_covid_data():
    # Use Python requests library
    requests.get(US_COVID_URL)
    return pd.read_csv(US_DIR)

df = read_covid_data()

def plot_ema_by_state(state):
    df_st = df[df['state'] == state]
    df_st['delta'] = df_st['cases'] - df_st['cases'].shift()
    return df_st.set_index('cases')['delta'].ewm(7).mean().plot()

# interactive widget via Jupyter Widgets
iwidget = widgets.Dropdown(
    options=us_states,
    value='Washington',
    description='State: ',
)

interactive(plot_ema_by_state, i=iwidget)
```

## How does it work?
Uploading the notebook `COVID.ipynb` (via `JupyterBoard.org` or `git push`) creates dashboard on `JupyterBoard.org/COVID.ipynb`.
- Functions wrapped in `@cache` are cached based on the cache string provided (e.g. daily or hourly or minutely)
- The notebook can provide interactive widgets via Jupyter Widgets
- A new upload updates the notebook
- When deploying with git, can set `requirements.txt` to extend the default dependency libraries
