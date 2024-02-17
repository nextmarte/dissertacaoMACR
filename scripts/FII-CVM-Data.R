# This script is used to download and process financial fii data from the CVM website.

# Load necessary libraries
# tidyverse: A collection of R packages designed for data science.
library(tidyverse)

# Function to download and read data
# This function takes a year as an argument, constructs a URL to download a zip file containing financial data for that year,
# downloads the file, reads the data from three CSV files contained in the zip file into data frames,
# and then deletes the zip file.
download_and_read <- function(year) {
    # Build the URL
    url <- paste0(
        "https://dados.cvm.gov.br/dados/FII/DOC/INF_MENSAL/DADOS/inf_mensal_fii_",
        year, ".zip"
    )

    # Download the zip file
    zip_file <- paste0("inf_mensal_fii_", year, ".zip")
    download.file(url, destfile = zip_file)

    # Read data from zip files with error logging
    # If an error occurs while reading a file, a message is printed and the function returns NULL for that file.
    data_ativo_passivo <- tryCatch(read_delim(
        unz(
            zip_file,
            paste0("inf_mensal_fii_ativo_passivo_", year, ".csv")
        ),
        delim = ";", locale = locale(encoding = "ISO-8859-1"),
        show_col_types = FALSE
    ), error = function(e) {
        message(
            "Error reading ativo_passivo data for year ",
            year, ": ", e
        )
        return()
    })
    data_complemento <- tryCatch(read_delim(
        unz(
            zip_file,
            paste0("inf_mensal_fii_complemento_", year, ".csv")
        ),
        delim = ";", locale = locale(encoding = "ISO-8859-1"),
        show_col_types = FALSE
    ), error = function(e) {
        message(
            "Error reading complemento data for year ", year, ": ", e
        )
        return()
    })
    data_geral <- tryCatch(read_delim(
        unz(
            zip_file,
            paste0("inf_mensal_fii_geral_", year, ".csv")
        ),
        delim = ";", locale = locale(encoding = "ISO-8859-1"),
        show_col_types = FALSE
    ), error = function(e) {
        message(
            "Error reading geral data for year ", year, ": ", e
        )
        return()
    })

    # Remove the zip file
    file.remove(zip_file)

    # Return a list containing the three data frames
    list(data_ativo_passivo = data_ativo_passivo, data_complemento = data_complemento, data_geral = data_geral)
}

# Define the range of years
# This script will download and process data for each year in this range.
years <- seq(2016, 2024)

# Use purrr::map to apply the download_and_read function to each year in the range
# The result is a list of lists, where each inner list contains the data for one year.
data_list <- map(years, download_and_read)

# Add data to the list
# This step restructures the data_list to group the data by type (ativo_passivo, geral, complemento) rather than by year.
data_list <- map(data_list, function(data) {
    list(
        ativo_passivo = data$data_ativo_passivo,
        geral = data$data_geral,
        complemento = data$data_complemento
    )
})

# Unify the "complemento" table data
# This step concatenates all the "complemento" data into a single data frame.
complemento_data <- map(data_list, "complemento") %>% bind_rows()

# Return the data frames instead of assigning them to the global environment
# The script returns a list containing the restructured data_list and the unified complemento_data.
list(data_list = data_list, complemento_data = complemento_data)

# Load the necessary libraries
library(dplyr)
library(lubridate)

# Extract the year from the date
complemento_data$Year <- year(as.Date(complemento_data$Data_Referencia))

# Group and summarize the data
summary_data <- complemento_data %>%
    group_by(Year) %>%
    summarise(Total_Numero_Cotistas = sum(Total_Numero_Cotistas, na.rm = TRUE))

# Print the summary data
print(summary_data)


shareholders<-ggplot(summary_data, aes(x = Year, y = Total_Numero_Cotistas)) +
    geom_bar(stat = "identity", fill = "steelblue", color = "black") +
    geom_text(aes(label = format(Total_Numero_Cotistas, big.mark = ",")), vjust = -0.3, size = 3) +
    labs(x = "Year", 
       y = "Total Number of Shareholders", 
       title = "Total Number of Shareholders Over the Years") +
    theme_minimal() +
    theme(text = element_text(size = 12),
        plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_y_continuous(labels = scales::comma)