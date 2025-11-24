# mvo - small returns demo

This repository contains a small script `mvo.py` that downloads monthly adjusted-close prices for a short list of tickers, computes simple monthly returns, arithmetic/geometric means, population (1/T) covariance matrix, and prints/saves the results.

Files
- `mvo.py` — main script

- `mvo.m` — MATLAB script that implements the mean-variance optimizer (MVO). It accepts the expected returns vector `mu` and covariance matrix `Q` (or reads CSVs produced by the Python script), solves the MVO for portfolios along the efficient frontier (shorting allowed and no-short constraints), plots the efficient frontier and asset locations, and prints a table of target returns, volatilities, and asset weights.

Usage
1. Create and activate a Python virtual environment and install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy yfinance
```

2. Run the script:

```bash
python mvo.py
```

Notes
- The script writes `mvo_monthly_stats.csv` and `mvo_population_explicit.csv` in the current directory.
- I intentionally include only the script and README in this repository template. Generated CSVs are not committed.

MATLAB usage

```matlab

% from MATLAB, in the repository directory
mvo(); % reads CSVs (if present) and runs the MVO, plots the efficient frontier

% or provide mu and Q explicitly:
stats = readtable('mvo_monthly_stats.csv','ReadRowNames',true);
mu = stats.mean_monthly_arith;
Q = readmatrix('mvo_population_explicit.csv');
mvo(mu, Q);
```

Notes:
- `mvo.m` requires MATLAB's Optimization Toolbox (`quadprog`).
- Ensure the CSV files are present and that the ticker ordering in the CSVs matches the order expected by MATLAB.
