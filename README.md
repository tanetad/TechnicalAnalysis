# BDA400 Assignment 6 - Technical Analysis

A Shiny-based R application for technical analysis and stock market visualization using real-time data from Yahoo Finance.

## Project Structure

```
BDA400-Assignment6/
│
├── app.R                    # Main Shiny application
├── README.md               # This file
├── cover_page.pdf          # Assignment cover page
├── data/
│   └── sample_data.csv     # Sample stock data
└── screenshots/
    └── dashboard.png       # Application dashboard screenshot
```

## Features

- **Stock Data Retrieval**: Fetch real-time stock data from Yahoo Finance
- **Interactive Visualizations**: Dynamic charts using ggplot2
- **User-Friendly Interface**: Built with Shiny for interactive exploration
- **Customizable Parameters**: Easily change stock symbols and date ranges

## Prerequisites

- R (version 3.6.0 or higher)
- The following R packages:
  - `shiny`
  - `ggplot2`
  - `quantmod`

## Installation

### 1. Install Required Packages

```r
install.packages("shiny")
install.packages("ggplot2")
install.packages("quantmod")
```

### 2. Load Libraries

```r
library(shiny)
library(ggplot2)
library(quantmod)
```

## Usage

### Running the Application

To run the Shiny application:

```r
shiny::runApp("app.R")
```

### Fetching Stock Data

```r
# Configuration
stock_symbol <- "AAPL"  # Replace with your desired stock symbol
start_date <- "2023-01-01"  # Replace with your desired start date
end_date <- "2023-07-01"    # Replace with your desired end date

# Retrieve stock data from Yahoo Finance
stock_data <- getSymbols(
  stock_symbol,
  src = "yahoo",
  from = start_date,
  to = end_date,
  auto.assign = FALSE
)

# Convert to data frame for analysis
stock_df <- data.frame(
  date = index(stock_data),
  coredata(stock_data)
)
```

## Supported Stock Symbols

Any valid stock symbol available on Yahoo Finance can be used. Common examples:
- AAPL (Apple Inc.)
- GOOGL (Alphabet Inc.)
- MSFT (Microsoft Corporation)
- TSLA (Tesla Inc.)
- AMZN (Amazon.com Inc.)

## Data Source

Stock data is retrieved from **Yahoo Finance** using the `quantmod` package.

## Assignment Details

This project is part of **BDA400** coursework and includes:
- Live stock market data analysis
- Technical indicators visualization
- Interactive dashboard
- Complete documentation

## Screenshots

See `screenshots/dashboard.png` for a preview of the application interface.

## Notes

- Ensure you have an active internet connection to fetch real-time data
- Yahoo Finance data is subject to delays and availability
- Date ranges should follow the format: `"YYYY-MM-DD"`

## Author

Created as an assignment for BDA400.

## License

This project is provided for educational purposes.
