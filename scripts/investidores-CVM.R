# Load necessary libraries
library(tidyverse)

# Function to download and read data
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

    list(data_ativo_passivo = data_ativo_passivo, data_complemento = data_complemento, data_geral = data_geral)
}

# Define the range of years
years <- seq(2016, 2024)

# Use purrr::map for loop over the years
data_list <- map(years, download_and_read)

# Add data to the list
data_list <- map(data_list, function(data) {
    list(
        ativo_passivo = data$data_ativo_passivo,
        geral = data$data_geral,
        complemento = data$data_complemento
    )
})

# Unify the "complemento" table data
complemento_data <- map(data_list, "complemento") %>% bind_rows()

# Return the data frames instead of assigning them to the global environment
list(data_list = data_list, complemento_data = complemento_data)