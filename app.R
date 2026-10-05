library(shiny)
library(ggplot2)
library(quantmod)
library(TTR)        # SMA, EMA, RSI, MACD
library(patchwork)  # Combine plots

# Load stock data
stock_symbol <- "AAPL"
start_date <- "2023-01-01"
end_date   <- "2023-07-01"

stock_data <- getSymbols(
  stock_symbol,
  src = "yahoo",
  from = start_date,
  to = end_date,
  auto.assign = FALSE
)

# Rename columns for easier handling
colnames(stock_data) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")

# -----------------------------
# UI
# -----------------------------
ui <- fluidPage(
  titlePanel("Stock Visualization Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(
        "date_range",
        "Select Date Range:",
        start = "2023-01-01",
        end   = "2023-07-01"
      ),
      
      selectInput(
        "time_frame",
        "Select Time Frame:",
        choices = c("Daily", "Weekly", "Monthly"),
        selected = "Daily"
      ),
      
      checkboxGroupInput(
        "technical_indicators",
        "Select Technical Indicators:",
        choices = c("Moving Averages", "RSI", "MACD"),
        selected = "Moving Averages"
      )
    ),
    
    mainPanel(
      plotOutput("stock_chart", height = "800px")
    )
  )
)

# -----------------------------
# SERVER
# -----------------------------
server <- function(input, output) {
  
  output$stock_chart <- renderPlot({
    
    # Convert xts to data frame
    df <- data.frame(
      date = index(stock_data),
      coredata(stock_data),
      row.names = NULL
    )
    
    # Filter by date range
    df <- subset(df, date >= input$date_range[1] & date <= input$date_range[2])
    
    if (nrow(df) == 0) {
      return(ggplot() + geom_text(aes(x = 0.5, y = 0.5, label = "No data in selected range")) + theme_void())
    }
    
    # Apply time frame selection
    if (input$time_frame == "Weekly") {
      df_xts <- to.weekly(stock_data)
      df <- data.frame(
        date = index(df_xts),
        coredata(df_xts),
        row.names = NULL
      )
      colnames(df) <- c("date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
      df <- subset(df, date >= input$date_range[1] & date <= input$date_range[2])
    } else if (input$time_frame == "Monthly") {
      df_xts <- to.monthly(stock_data)
      df <- data.frame(
        date = index(df_xts),
        coredata(df_xts),
        row.names = NULL
      )
      colnames(df) <- c("date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
      df <- subset(df, date >= input$date_range[1] & date <= input$date_range[2])
    }
    
    # -----------------------------
    # TRADING RULES (MA CROSSOVER)
    # -----------------------------
    short_ma <- SMA(df$Close, n = 20)
    long_ma  <- SMA(df$Close, n = 50)
    
    # Replace NaN and Inf values with NA
    short_ma[is.nan(short_ma) | is.infinite(short_ma)] <- NA
    long_ma[is.nan(long_ma) | is.infinite(long_ma)] <- NA
    
    signals <- ifelse(
      is.na(short_ma) | is.na(long_ma), "Hold",
      ifelse(short_ma > long_ma, "Buy",
             ifelse(short_ma < long_ma, "Sell", "Hold"))
    )
    
    df$ShortMA <- as.numeric(short_ma)
    df$LongMA  <- as.numeric(long_ma)
    df$Signal  <- signals
    
    # -----------------------------
    # BASE PRICE PLOT
    # -----------------------------
    p <- ggplot(df, aes(x = date, y = Close)) +
      geom_line(color = "blue", linewidth = 0.8) +
      geom_point(size = 1.5, alpha = 0.5) +
      labs(
        title = paste("AAPL Stock Price -", input$time_frame, "TimeFrame"),
        x = "Date",
        y = "Closing Price ($)"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold", size = 14),
        axis.title = element_text(size = 11)
      )
    
    # Moving averages overlay (if selected)
    if ("Moving Averages" %in% input$technical_indicators) {
      p <- p +
        geom_line(aes(y = ShortMA), color = "red", linewidth = 0.8, linetype = "dashed", na.rm = TRUE) +
        geom_line(aes(y = LongMA), color = "purple", linewidth = 0.8, linetype = "dashed", na.rm = TRUE) +
        annotate("text", x = Inf, y = Inf, label = "Red: 20-day MA | Purple: 50-day MA", 
                 hjust = 1.1, vjust = 1.5, size = 3, color = "gray40")
    }
    
    # Signal annotations on price (only for significant signals)
    buy_signals <- df[df$Signal == "Buy", ]
    sell_signals <- df[df$Signal == "Sell", ]
    
    if (nrow(buy_signals) > 0) {
      p <- p + geom_point(data = buy_signals, aes(x = date, y = Close), 
                          color = "green", size = 3, shape = 24)
    }
    
    if (nrow(sell_signals) > 0) {
      p <- p + geom_point(data = sell_signals, aes(x = date, y = Close), 
                          color = "red", size = 3, shape = 25)
    }
    
    plots_list <- list(p)
    
    # -----------------------------
    # RSI PANEL
    # -----------------------------
    if ("RSI" %in% input$technical_indicators) {
      
      rsi_vals <- RSI(df$Close, n = 14)
      df$RSI <- as.numeric(rsi_vals)
      
      rsi_plot <- ggplot(df, aes(x = date, y = RSI)) +
        geom_line(color = "darkgreen", linewidth = 0.8, na.rm = TRUE) +
        geom_hline(yintercept = 70, linetype = "dashed", color = "red", alpha = 0.7) +
        geom_hline(yintercept = 30, linetype = "dashed", color = "blue", alpha = 0.7) +
        geom_hline(yintercept = 50, linetype = "dotted", color = "gray", alpha = 0.5) +
        ylim(0, 100) +
        labs(title = "RSI (14)", y = "RSI", x = "Date") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold", size = 12),
          axis.title = element_text(size = 10)
        )
      
      plots_list[[length(plots_list) + 1]] <- rsi_plot
    }
    
    # -----------------------------
    # MACD PANEL
    # -----------------------------
    if ("MACD" %in% input$technical_indicators) {
      
      macd_vals <- MACD(df$Close, nFast = 12, nSlow = 26, nSig = 9)
      
      df$MACD <- as.numeric(macd_vals[, 1])
      df$SignalLine <- as.numeric(macd_vals[, 2])
      df$Hist <- df$MACD - df$SignalLine
      
      macd_plot <- ggplot(df, aes(x = date)) +
        geom_col(aes(y = Hist), fill = "grey", alpha = 0.6) +
        geom_line(aes(y = MACD), color = "orange", linewidth = 0.8, na.rm = TRUE) +
        geom_line(aes(y = SignalLine), color = "purple", linewidth = 0.8, na.rm = TRUE) +
        geom_hline(yintercept = 0, linetype = "solid", color = "black", alpha = 0.3) +
        labs(title = "MACD", y = "MACD", x = "Date") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold", size = 12),
          axis.title = element_text(size = 10)
        )
      
      plots_list[[length(plots_list) + 1]] <- macd_plot
    }
    
    # -----------------------------
    # COMBINE PANELS
    # -----------------------------
    if (length(plots_list) > 1) {
      # Use reduce with / operator to stack plots
      combined_plot <- Reduce(`/`, plots_list)
      print(combined_plot)
    } else {
      print(plots_list[[1]])
    }
  })
}

# -----------------------------
# RUN APP
# -----------------------------
shinyApp(ui, server)
