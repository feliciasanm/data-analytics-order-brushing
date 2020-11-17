brushdetector <- function() {
  
  library(lubridate)
  library(dplyr)
  
  classlist <- c("character")
  data <- read.csv("order_brush_order.csv", colClasses = classlist, stringsAsFactors = FALSE)
  data[,2] <- as.numeric(data[,2])
  data[,3] <- as.numeric(data[,3])
  data[,4] <- ymd_hms(data[,4])
  
  shoplist <- unique(data$shopid)
  resultdata <- data.frame(shopid = shoplist, userid = c(""), stringsAsFactors = FALSE)
  
  for (shop in shoplist) {
    
    shopdata <- filter(data, shopid == shop) %>% select(-shopid)
    orderlist <- shopdata$orderid
    masterdata <- filter(shopdata, orderid == 0)
    
    for (order in orderlist) {
      
      lowertime <- filter(shopdata, orderid == order)
      lowertime <- lowertime$event_time
      uppertime <- lowertime + hours(1)
      intervaldata <- filter(shopdata, event_time <= uppertime, event_time >= lowertime)
      
      buyerlist <- unique(intervaldata$userid)
      orderlist <- unique(intervaldata$orderid)
      
      concentraterate <- length(orderlist) / length(buyerlist)
      
      if (concentraterate >= 3) {
        
        masterdata <- rbind(masterdata, intervaldata)
      
      }
        
    }
      
    if (nrow(masterdata) > 0) {
      
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
      badbuyer <- c()
    }
    
    resultdata[resultdata$shopid == shop, 2] <- if (length(badbuyer) > 0) {
      paste(badbuyer, collapse = "&")
    } else { 
      "0" 
    }
  }
  
  write.csv(resultdata, "submission.csv", row.names = FALSE)
      
}