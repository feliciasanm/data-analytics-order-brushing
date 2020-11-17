# Code League 2020 - Order Brushing

Hi, this is my code for the first challenge in [Shopee Code League 2020](https://careers.shopee.sg/codeleague), which is Order Brushing, conducted on June 13, 2020. It was categorized under data analytics in the competition. The solution was written in R, using `lubridate` and `dplyr` within the code. Before discussing about the challenge itself and the code, a short background is in order.


## What is Shopee Code League (2020)?

Shopee Code League (2020) is a competition held by Shopee for coders around Asia region, to be exact Singapore, China, Indonesia, Malaysia, Philippines, Taiwan, Thailand, and Vietnam. The entire event was held between June 8 to August 8, consisting of eight main challenges and many workshops within the event. It was done completely online, usually using Kaggle as the platform, and it had two participation categories: Student and Open. I participated on the Open category, as one of my team members had already graduated. 

Order brushing, which is discussed here, was the first of the eight main challenges in the competition. As I participated on the Open category, the one featured here will be the Open category's version.


## Order Brushing Challenge

The objective of the challenge was to detect order brushing using data provided in the competition. 

### Order Brushing

Order brushing is when sellers deliberately create fake orders for their products, in order to improve the rating of the products or their own shops. The orders are made by or on behalf of the seller, with the purpose of giving high rating using the fake orders, thus artificially inflating the rating of the shop or the product. Therefore, there are three important components to order brushing in this context: the shop, the fake orders, and the suspicious buyers.

### Data

In this competition, the participants are given transaction (order) data with the necessary information to calculate what is called a "concentrate rate". If the concentrate rate of a shop is equal or greater than 3, then the shop will be suspected of order brushing. If a shop is identified as conducting order brushing, we also want to know which of their buyers are the ones doing suspicious transactions.

The data consists of 222,750 rows, with four variables containing the necessary information to calculate the concentrate rate.

Column name | Description
----------- | -----------
`orderid`   | unique identifier of the transaction
`shopid`    | unique identifier of the shop
`userid`    | unique identifier of the buyer
`event_time`| time stamp of the transaction

### Calculation

Concentrate rate will be calculated from the data using this equation:

```
Concentrate rate = Number of orders within 1 hour / Number of unique buyers within 1 hour
```

Furthermore, in this challenge, suspicious buyers are the one who has the highest proportion of orders to the shops when order brushing occurred. It means that the result will often be just one `userid`, but it can be more than one if the highest proportion is tied between more than one `userid`.

### Objective

The objective of the challenge was to produce a csv file that labeled which shops are suspected of order brushing. The structure of the csv file was required to be as follows:

Column name | Description
----------- | -----------
`shopid`    | unique identifier of the shop
`userid`    | list of suspicious buyers (id) associated with the shop, separated with `&` and no space, 0 if there is none

To clarify the structure further, below I will provide an example of the resulting csv file structure. 

Suppose that there are two shops in the data set, with 111 and 112 as their shopid. Shop 111 has concentrate rate lower than 3, so there is no suspicious buyer identified. On the other hand, shop 112 has concentrate rate equal or higher than 3, so there will be suspicious buyer(s) on the shop. In this case, there are two suspicious buyers, which are buyers with userid of 221 and 222. The csv file will be arranged as follows:

shopid  | userid
------- | -----------
111     | 0
112     | 221&222


## Solution Code

The solution featured here is written in R. In my team, the R version was written by me, separate from other versions written by other team members. When I wrote the R code, the use of library was limited to `lubridate` and `dplyr` only, the rest written in base R (check my other repositories to see R code written using tidyverse). The entire solution code is encapsulated in a function named `brushdetector`, which needs to be invoked to run the solution.

The competition was conducted until 4.30 pm, which was roughly when the working code was finished without including the time needed to actually execute the code. The csv result was submitted to Kaggle using late submission, resulting in a score of 0.89933 out of 1. I took additional 1 hour and 42 minutes to clean up the code, which I publish here unmodified (other than possible additional comments) in code on this repository. 


## What I Learned From the Experience

The code featured here is a good picture of what I can write on June 2020 in 3-5 hours, and I have since improved from the experience and further learning. From this experience, there are several things that I learned: 

1. It can take a surprisingly long time to run code on relatively large amount of data. 

    The challenge was my first experience processing thousands of rows of data, so I was quite surprised that my relatively short piece of code can take 15 minutes to run on the data (considering I used an Intel i7 laptop to run the code). 

2. I also learned how to write code relatively quickly on large amount of data 

    The main trick was to write the code in the `for` loop but comment out the `for` statement itself. It will take too long to iterate on the code if we tried it using the entire data. Write then comment out the `for` loop statement (to make it easy to enable the loop again later), then assign `i` (what we usually use to keep track of the loop) with the first index of the loop. We can iterate the code quickly in this manner. When we are confident with the code, we can uncomment the `for` loop statement again and remove or comment the `i` variable assignment.  

If I can write it again, I would have taken the time to check more convenient functions that I later discovered exist, and I would improve the performance of the code. Specifically, on the next data analytics challenge that I participated in (see in [this](https://github.com/feliciasanm/data-analytics-logistics-performance) repository), I reached out to use `data.table` on the final version to significantly reduce the time needed to run the code. It was an interesting challenge to do, and I would be very interested to participate in similar events in the future!

## To Do
* Adding comments to the code