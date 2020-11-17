brushdetector <- function() {
  
  library(lubridate)
  library(dplyr)
  
  # Read the data into R
  classlist <- c("character")
  data <- read.csv("order_brush_order.csv", colClasses = classlist, stringsAsFactors = FALSE)
  data[,2] <- as.numeric(data[,2])
  data[,3] <- as.numeric(data[,3])
  data[,4] <- ymd_hms(data[,4])
  
  # Create a list of all shops in the data set
  # Also, create a result list ready to hold the results of all calculations later
  shoplist <- unique(data$shopid)
  resultdata <- data.frame(shopid = shoplist, userid = c(""), stringsAsFactors = FALSE)
  
  # Loop through each shop in the list
  for (shop in shoplist) {
    
    # Create a list of orders related to the shop
    # Also, create a master list to hold all occurences of order brushing in the shop
    shopdata <- filter(data, shopid == shop) %>% select(-shopid)
    orderlist <- shopdata$orderid
    masterdata <- filter(shopdata, orderid == 0)
    
    # Loop through each of the orders
    for (order in orderlist) {
      
      # For each order in the list, find all transactions connected with the shop
      # within 1 hour after the order
      lowertime <- filter(shopdata, orderid == order)
      lowertime <- lowertime$event_time
      uppertime <- lowertime + hours(1)
      intervaldata <- filter(shopdata, event_time <= uppertime, event_time >= lowertime)
      
      # Create a buyer and order list
      buyerlist <- unique(intervaldata$userid)
      orderlist <- unique(intervaldata$orderid)
      
      # Calculate the concentrate rate from the list of buyers and orders
      concentraterate <- length(orderlist) / length(buyerlist)
      
      if (concentraterate >= 3) {
      
        # If the concentrate rate is equal or higher than 3, add data 
        # from the one-hour interval into a master list  
        masterdata <- rbind(masterdata, intervaldata)
      
      }
        
    }
    
    # If the master list is not empty... 
    # (read: order brushing has occurred in the shop)  
    if (nrow(masterdata) > 0) {
      
      # Find who are the suspicious buyers
      masterdata <- unique(masterdata)
      buyerlist <- unique(masterdata$userid)
      buyerdb <- data.frame(buyerlist, c(0))
      colnames(buyerdb) <- c("buyerid", "proportion")
      
      for (buyer in buyerlist) {
          buyertransaction <- filter(masterdata, userid == buyer)
          buyerproportion <- nrow(buyertransaction) / nrow(masterdata)
          buyerdb[buyerdb$buyerid == buyer, 2] <- buyerproportion
      }
      
      buyerdb <- arrange(buyerdb, desc(proportion))
      badbuyer <- filter(buyerdb, proportion == buyerdb[1,2])
      badbuyer <- badbuyer$buyerid
      badbuyer <- sort(badbuyer)
    
    } else {
    
      # Assign badbuyer with an empty vector if there is no order brushing
      badbuyer <- c()
    
    }
    
    # If there are suspicious buyers, string their userid together with &
    # If not, return 0 to indicate no suspicious buyers
    resultdata[resultdata$shopid == shop, 2] <- if (length(badbuyer) > 0) {
      paste(badbuyer, collapse = "&")
    } else { 
      "0" 
    }
  }
  
  # After all orders and shops have been checked, write out the result in a csv file
  write.csv(resultdata, "submission.csv", row.names = FALSE)
      
}