# BDA400 Assignment 6 - Technical Analysis

A Shiny-based R application for technical analysis and stock market visualization using real-time data from Yahoo Finance. Features interactive dashboards with multiple technical indicators and trading signals.

## Features

- **Stock Data Retrieval**: Fetch real-time stock data from Yahoo Finance
- **Interactive Visualizations**: Dynamic charts using ggplot2 and patchwork
- **User-Friendly Interface**: Built with Shiny for interactive exploration
- **Customizable Parameters**: Easily change stock symbols and date ranges
- **Time Frame Selection**: View data in Daily, Weekly, or Monthly intervals
- **Technical Indicators**:
  - Moving Averages (SMA) with MA Crossover Trading Signals
  - Relative Strength Index (RSI)
  - MACD (Moving Average Convergence Divergence)
- **Multi-Panel Dashboard**: Combine price charts with indicator panels

## Prerequisites

- R (version 3.6.0 or higher)
- The following R packages:
  - `shiny` - Interactive web application framework
  - `ggplot2` - Data visualization
  - `quantmod` - Stock data retrieval
  - `TTR` - Technical trading rules and indicators
  - `patchwork` - Combining multiple plots

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/tanetad/TechnicalAnalysis.git
cd TechnicalAnalysis
```

### 2. Install Required Packages

```r
install.packages(c("shiny", "ggplot2", "quantmod", "TTR", "patchwork"))
```

## Usage

### Running the Application

To run the Shiny application:

```r
shiny::runApp("app.R")
```

The application will open in your default web browser at `http://localhost:3838`.

### Application Features

#### Date Range Selection
- Use the date range picker to filter historical data
- Default range: January 1, 2023 - July 1, 2023

#### Time Frame Options
Select from:
- **Daily**: Highest granularity data
- **Weekly**: Aggregated weekly OHLC data
- **Monthly**: Aggregated monthly OHLC data

#### Technical Indicators
Select one or more indicators:
- **Moving Averages**: 20-day (red) and 50-day (purple) SMA with Buy/Sell/Hold signals
- **RSI**: 14-period Relative Strength Index with overbought (70) and oversold (30) levels
- **MACD**: 12/26/9 MACD with signal line and histogram

#### Trading Rules
The application implements an MA Crossover strategy:
- **Buy Signal**: When 20-day SMA crosses above 50-day SMA
- **Sell Signal**: When 20-day SMA crosses below 50-day SMA
- **Hold Signal**: When moving averages are in transition

### Code Structure

```
app.R
├── Libraries & Configuration
├── Data Loading
│   └── Yahoo Finance data via quantmod
├── UI Definition
│   ├── Date range input
│   ├── Time frame selector
│   ├── Technical indicator selector
│   └── Plot output
└── Server Logic
    ├── Data filtering and transformation
    ├── Technical indicator calculations
    ├── Signal generation
    ├── Individual plot creation
    └── Plot combination with patchwork
```

## Supported Stock Symbols

Any valid stock symbol available on Yahoo Finance can be used. Common examples:
- AAPL (Apple Inc.)
- GOOGL (Alphabet Inc.)
- MSFT (Microsoft Corporation)
- TSLA (Tesla Inc.)
- AMZN (Amazon.com Inc.)

To modify the default stock symbol, edit line 9 in `app.R`:
```r
stock_symbol <- "YOUR_SYMBOL"
```

## Data Source

Stock data is retrieved from **Yahoo Finance** using the `quantmod` package.

## Technical Indicators Reference

### Moving Averages (SMA)
- **20-day SMA**: Fast-moving average, more responsive to price changes
- **50-day SMA**: Slow-moving average, indicates longer-term trend
- **Crossover Strategy**: Signals trend changes when the two averages intersect

### RSI (Relative Strength Index)
- **Range**: 0-100
- **Overbought**: RSI > 70 (potential reversal)
- **Oversold**: RSI < 30 (potential recovery)
- **Period**: 14 days

### MACD (Moving Average Convergence Divergence)
- **MACD Line**: 12-day EMA minus 26-day EMA (orange)
- **Signal Line**: 9-day EMA of MACD line (purple)
- **Histogram**: Difference between MACD and Signal line (grey bars)
- **Signal**: Convergence/divergence indicates momentum changes

## Project Structure

```
tanetad/TechnicalAnalysis/
├── README.md          # Project documentation
├── app.R              # Main Shiny application
├── screenshots/
│   └── dashboard.png  # Application interface preview
└── .gitignore         # Git configuration
```

## Notes

- Ensure you have an active internet connection to fetch real-time data
- Yahoo Finance data is subject to delays and availability limitations
- Date ranges should follow the format: `"YYYY-MM-DD"`
- Technical indicators require a minimum number of data points to calculate
- The application loads all data at startup; for large date ranges, performance may vary

## Disclaimer

This project is for educational purposes only. Technical analysis indicators should not be used as the sole basis for investment decisions. Always conduct thorough research and consider consulting with a financial advisor.

## Author

Created as an assignment for BDA400 course.

## License

This project is provided for educational purposes.

## Contributing

To contribute improvements:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Submit a pull request

## Support

For issues or questions, please open an issue on the GitHub repository.
