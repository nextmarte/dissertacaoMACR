# Carregar as bibliotecas necessárias
library(utils)
library(readr)

# Definir o intervalo de anos
years <- 2016:2023

# Criar uma lista para armazenar os dados
data_list <- list()

# Loop através dos anos
for (year in years) {
    # Construir a URL
    url <- paste0("https://dados.cvm.gov.br/dados/FII/DOC/INF_MENSAL/DADOS/inf_mensal_fii_", year, ".zip")
    
    # Baixar o arquivo zip
    download.file(url, destfile = paste0("inf_mensal_fii_", year, ".zip"))
    
    # Ler os dados dos arquivos zip
    data_ativo_passivo <- read_delim(unz(paste0("inf_mensal_fii_", year, ".zip"), paste0("inf_mensal_fii_ativo_passivo_", year, ".csv")), delim = ";", locale = locale(encoding = "ISO-8859-1"), show_col_types = FALSE)
    data_complemento <- read_delim(unz(paste0("inf_mensal_fii_", year, ".zip"), paste0("inf_mensal_fii_complemento_", year, ".csv")), delim = ";", locale = locale(encoding = "ISO-8859-1"), show_col_types = FALSE)
    data_geral <- read_delim(unz(paste0("inf_mensal_fii_", year, ".zip"), paste0("inf_mensal_fii_geral_", year, ".csv")), delim = ";", locale = locale(encoding = "ISO-8859-1"), show_col_types = FALSE)
    
    # Adicionar os dados à lista
    data_list[[paste0("ativo_passivo_", year)]] <- data_ativo_passivo
    data_list[[paste0("complemento_", year)]] <- data_complemento
    data_list[[paste0("geral_", year)]] <- data_geral
}

# Salvar a lista de dados no ambiente
assign("data_list", data_list, envir = .GlobalEnv)