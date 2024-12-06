

/*  Analysing data using the following created summaries:

    user_visit_summary
    product_level_summary
    product_category_level_summary
    Final_Raw_Data      
  
*/

Select Count (distinct user_id) as user_count from users
-- There are 500 users 


Select Avg(cookie_count) AS average_cookie_count
FROM (
    Select user_id, Count (cookie_id) AS cookie_count
    FROM users  Group by user_id
) AS user_cookie_counts;  -- 3 cookies per user



/*  Unique visits by users per month  */

Select Months, count(distinct visit_id) as unique_visits
From (
       SELECT user_id, visit_id, DATENAME(Month, user_start_date) as Months
	   from Final_Raw_Data where user_id IS NOT NULL
     ) AS Monthly_visits
Group by Months




/*  No. of events for each event_type  */

Select count(e.event_type) as No_of_events, en.event_name as event_type
From events e
Left Join event_identifier en 
ON e.event_type = en.event_type
Where en.event_name is not Null
Group By en.event_name




/*  percentage of visits which have a purchase event  */

Select Count(Case When event_name = 'purchase' then visit_id end) AS purchase_visits,
       Count(*) AS total_visits,
      (Count (CASE WHEN event_name = 'purchase' THEN visit_id END) * 100.0 / COUNT(*)) 
	   AS percentage_purchase_visits
From
Final_Raw_data;



/*  percentage of abandoned visits  */

Select Count(Case When event_name <> 'purchase' and page_name = 'Checkout'
       then visit_id end) AS abandoned_visits,
       Count(*) AS total_visits,
      (Count (Case When event_name <> 'purchase' and page_name = 'Checkout'
       then visit_id end) * 100.0 / COUNT(*)) 
	   AS percentage_abandoned_visits
From
Final_Raw_data;





/*  Top 3 pages by No. of views  */

WITH  pgview
as  (
      Select page_name , count(event_name) as page_views From Final_Raw_Data
	  Where event_name = 'Page View'
	  Group By page_name      
	  
 ) Select Top 3 *  From pgview
   Order by page_views desc




/*  views & carts for each category */

Select product_category, sum(view_count) as view_count, sum(add_to_cart_count) as add_to_cart_count,
sum(purchased_count) as purchased_count,  sum(abandoned_count) as abandoned_count
from product_category_level_summary
Group by product_category




/*  Top 3 most purchased products  */

Select Top 3  products From product_level_summary
Order by purchased_count desc



/*  Lobster is the most famous among other products  */

Select Top 1 products From product_level_summary
Order by purchased_count desc



/*  Russian Caviar  was most likely to be abandoned  */
Select Top 1 products From product_level_summary
Order by abandoned_count desc   




/*  Lobster had the highest view to purchase %age  */

Select Top 1 products, ( Cast (purchased_count as float ) / view_count ) as view_to_purchase_percentage
From product_level_summary
Order by view_to_purchase_percentage desc




/*   Avg view_to_cart conversion rate  */

Select avg(view_to_cart_percentage) as avg_conversion_rate
 From (
          Select products, ( Cast (add_to_cart_count as float ) / view_count ) as view_to_cart_percentage
          From product_level_summary
       )  AS per


                      

/*  Avg cart_to_purchase conversion rate  */

Select avg(cart_to_purchase_percentage) as avg_conversion_rate
 From (
          Select products, ( Cast (purchased_count as float ) / add_to_cart_count ) as cart_to_purchase_percentage
          From product_level_summary
       )  AS per
                      




/* Method: 1 , all metrics compared in one Table */

SELECT  user_id, campaign_name,
        Count(Case When ad_impressions Is Not NULL Then purchase_flag Else 0 End) AS purchaseflag_with_impression,
	    Count(Case When ad_impressions IS NULL Then purchase_flag Else 0 End) AS purchaseflag_without_impression,
        Sum(Case When ad_impressions Is Not NULL Then page_views Else 0 End) AS views_with_impression,
	    Sum(Case When ad_impressions IS NULL Then page_views Else 0 End) AS views_without_impression,
        Sum(Case When ad_impressions Is Not NULL Then cart_adds Else 0 End) AS cart_adds_with_impression,
        Sum(Case When ad_impressions IS NULL Then cart_adds Else 0 End) AS cart_adds_without_impression
From visit_summary
Where campaign_name is not Null
Group by user_id, campaign_name
Order by campaign_name , user_id



/*  Method: 2 , you can run both queries together 
to compare data  */

Select * from visit_summary
Where ad_impressions Is Not Null  and campaign_name Is Not Null
Order by campaign_name

Select * from visit_summary
Where ad_impressions Is Null  and campaign_name Is Not Null
Order by campaign_name





/* Impression Clicks 
Yes, we can conclude that clicking on impressions lead to higher 
purchase rate : 88.8%                   */

Select ad_clicks, (Cast(Sum(purchase_flag) as float) / Count(purchase_flag))*100 as purchase_rate,
COUNT(*) as impression_count
From visit_summary
Where ad_impressions is not NUll
Group by ad_clicks;




/*  Uplift in purchase rate: Critical Analysis
after running both the queries, we can see that the purchase rate 
spiked to 84% when received impressions ( as seen in Step 1 ).
While it got uplifted by additional 4%  with a purchase share propostion 
of 88% when we got clicks on our received impressions ( as seen in Step 2 )
*/

-- Step 1: Impression_status_table

Select Case
         When ad_impressions = 1 then 'Impression Received'
         else 'No Impression'
         end as impression_status,
    (Cast(Sum(purchase_flag) as float) / Count(purchase_flag))*100 as purchase_rate,
     Count(*) as user_count
From visit_summary
Where user_id Is NOT NULL
Group by Case 
            When ad_impressions = 1 then 'Impression Received'
            else 'No Impression' end 

--- Step: 2 : clicks_status_table

Select Case
         When ad_clicks = 1 then 'clicked'
         else 'Not clicked'
         end as Clicks_status,
    (Cast(Sum(purchase_flag) as float) / Count(purchase_flag))*100 as purchase_rate,
     Count(*) as user_count
From visit_summary
Where ad_impressions = 1
and user_id Is NOT NULL
Group by Case 
           When ad_clicks = 1 then 'clicked'
           else 'Not clicked' end





/*  Campaign Metrics Comparison Table  */

Select campaign_name, count(ad_impressions) as impressions, count(ad_clicks) as clicks,
count(purchase_flag) as purchases, Sum(page_views) as total_views, 
Sum(cart_adds) as total_add_to_carts
From visit_summary
Where campaign_name is not Null
Group by campaign_name










