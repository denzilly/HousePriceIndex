#Data cleaning and shit




setwd("D:/programming/HousePriceIndex")

regions <- c('Nederland', 'Noord-Nederland', 'Oost-Nederland','West-Nederland','Zuid-Nederland', 'Groningen', 'Friesland', 'Drenthe', 'Overijssel', 'Flevoland', 'Gelderland', 'Utrecht', 
             'Noord-Holland', 'Zuid-Holland', 'Zeeland', 'Noord-Brabant', 'Limburg', 'Amsterdam','Den-Haag','Rotterdam','Utrecht (Gemeente)')


price_data <- read.csv("pbk_regio_note.csv", header = TRUE, sep = ";")
loc_metadata <- read.csv("loc_codes.csv", header = TRUE, sep = ";")



# add region codes
colnames(price_data)[2] <- "Code"
price_data$Landsdeel <- loc_metadata$Landsdeel[match(price_data$Code, loc_metadata$Code, nomatch = 1)]
price_data$Landsdeel <- gsub("-", "", price_data$Landsdeel)


# Separate Quarterly and Annual
price_data$freq <- "Q"
price_data$freq[grepl("KW", price_data$Perioden) == FALSE] <- "Y"

# Separate DF for quarterly, set date properly
q_d <- price_data[price_data$freq == "Q",]
q_d$Perioden <- as.yearqtr(q_d$Perioden, "%YKW%q")





# Create separate quarterly TS objects for each region
for (x in unique(q_d$Landsdeel)){
  assign(x, zoo(as.matrix(q_d[q_d$Landsdeel == x,4]), as.yearqtr(q_d$Perioden, "%YKW%q")))
  assign(x, q_d[q_d$Landsdeel == toString(x),])
}




