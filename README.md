# SeafoodKart_Website_Analytics
Capstone project analyzing website data using SQL, Excel, and visualized through Power BI.

#### **SeaFoodKart**  offers a wide range of seafood products delivered directly to customers' doorsteps, with a focus on quality, convenience, and sustainability. 
It's an online seafood store. When people visit their website, they're on a journey, like going through a funnel. At the top of the funnel are all the people who visit the site, and at the bottom are the ones who actually buy something. But, not everyone who visits ends up buying. Some people might leave before even looking at the products, some might add things to their cart but then change their mind, and some might start to buy but then decide not to. 

##### As part of this project, we are required to work on below things.

##### Digital Analysis: The Analysis of SeaFoodKart's dataset provides crucial insights into user behavior and website performance. It reveals information on user metrics, Visit analysis, Event analysis, Page performance, product performance. These insights empower SeaFoodKart to optimize its website, marketing strategies, and product offerings, ultimately enhancing customer experience and driving sales growth.

##### Product Funnel Analysis: It helps in giving insights into product performance, abandonment rates, conversion rates, and other key metrics. By analyzing individual products and product categories, SeaFoodKart can identify popular products, areas for improvement, and opportunities to optimize the conversion funnel, ultimately enhancing customer experience and increasing sales.

##### Campaign Analysis: Generate a table that provides comprehensive insights into user visits and their interactions with campaigns and products. 

#### Data Availability ( Refer to SeaFoodKart_dataset.zip file ):
##### 1. Users Table - Customers who visit the SeaFoodKart website are tagged via their cookie_id.
##### 2. Events Table - Customer visits are logged in this events table at a cookie_id level and the event_type and page_id values can be used to join onto relevant satellite tables to obtain further information about each event. The sequence_number is used to order the events within each visit.
##### 3. Event Identifier  Table- The event_identifier table shows the types of events which are captured by  SeaFoodKart's digital data systems
##### 4. Campaign Identifier Table- This table shows information for the 3 campaigns that SeaFoodKart has run on their website so far in 2020.
##### 5. Page Hierarchy Table - This table lists all of the pages on the SeaFoodKart website which are tagged and have data passing through from user interaction events


#### **Analytical Approach Applied:**

##### * Leveraged SQL to manipulate data and generate summaries at the page, product, category, and user-visit levels.  
##### * Evaluated campaign performance by creating a detailed table with key metrics such as `user_id`, `visit_start_time`, `page_views`, `cart_adds`, `purchase_flag`, `campaign_name`, `impression_count`, `click_count`, and `cart_products` (a comma-separated, order-sorted list of products added to the cart).  
##### * Conducted deeper analysis using SQL to identify patterns and extract actionable insights.  
##### * Enhanced the analysis with Excel for further exploration and presented the findings through an interactive Power BI dashboard.  
