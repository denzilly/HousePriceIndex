price_data <- read.csv("pbk_regio_note.csv", header = TRUE, sep = ";")
loc_metadata <- read.csv("loc_codes.csv", header = TRUE, sep = ";")


colnames(price_data)[2] <- "Code"





price_data$Landsdeel <- loc_metadata$Landsdeel[match(price_data$Code, loc_metadata$Code, nomatch = 1)]
