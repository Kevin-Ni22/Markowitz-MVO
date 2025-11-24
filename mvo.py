import yfinance as yf
import pandas as pd
import numpy as np

# Define the tickers and the date range
TICKERS = ['IREN', 'BITF', 'EOSE', 'CIFR']
START_DATE = '2022-12-31'
END_DATE = '2025-10-31'

# Download monthly adjusted-close prices
data = yf.download(
    TICKERS,
    start=START_DATE,
    end=END_DATE,
    interval="1mo",
    auto_adjust=True,
    progress=False
)

# Adjusted-close prices are in the 'Close' column when auto_adjust=True
prices = data['Close']

# Compute simple monthly returns
returns = prices.pct_change().dropna()

results = []
print('\nExpected returns and standard deviations:')
for asset in returns.columns:
    r = returns[asset].dropna()
    n = len(r)

    # Arithmetic mean monthly (simple average)
    mean_monthly = r.mean()

    # Geometric mean monthly (compound average): (prod(1+r))^(1/n) - 1
    geo_monthly = r.add(1).prod() ** (1.0 / n) - 1

    # Monthly standard deviation computed as population std (1/T)
    std_monthly = np.sqrt(((r - mean_monthly) ** 2).sum() / float(n))

    results.append({
        'asset': asset,
        'mean_monthly_arith': mean_monthly,
        'mean_monthly_geo': geo_monthly,
        'std_monthly': std_monthly
    })

# Present results in a tidy table (monthly values only)
summary_df = pd.DataFrame(results).set_index('asset')
pd.set_option('display.float_format', '{:,.6f}'.format)
print('\nMonthly expected returns and standard deviations:')
print(summary_df)

# Save the monthly stats to CSV for inspection
summary_df.to_csv('mvo_monthly_stats.csv')

# Compute population covariance matrix (1/T) for all tickers
Tn = len(returns)
X = returns.values
mu = summary_df['mvo_monthly_arith'].values
dev = X - mu
cov_matrix_pop = (dev.T @ dev) / float(Tn)
cov_df = pd.DataFrame(cov_matrix_pop, index=returns.columns, columns=returns.columns)

# Update stds in the summary from the diagonal of the population covariance (ensures consistency)
pop_vars = np.diag(cov_matrix_pop)
pop_stds = np.sqrt(pop_vars)
summary_df['std_monthly'] = pd.Series(pop_stds, index=summary_df.index)

# Print results for verification
print('\nUpdated summary (population stds):')
print(summary_df)
print('\nCovariance matrix:')
print(cov_df)

# Save covariance to CSV
cov_df.to_csv('forfun_population_explicit.csv')
print('\nSaved `forfun_monthly_stats.csv` and `forfun_population_explicit.csv`.')
