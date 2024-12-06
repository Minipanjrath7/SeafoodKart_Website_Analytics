
/* Creating database & making it active for use */

Create Database Seafoodkart;
Use Seafoodkart

Select Count(*) as user_count   from users  
Select Count(*) as event_count  from events  
Select Count(*) as eiden_count  from event_identifier  
Select Count(*) as camp_count   from campaign_identifier  
Select Count(*) as page_count   from page_heirarchy  



/* Changed the data types of start & end date columns in campaign_identifier  */

ALTER TABLE campaign_identifier 
ALTER COLUMN start_date Date;

ALTER TABLE campaign_identifier 
ALTER COLUMN end_date Date; 



/* Combined all the data into single table using joins & Common Table Expression ( CTE )  */

WITH JOINED as
   (
       Select u.user_id,  u.start_date as user_start_date, e.visit_id, e.cookie_id, e.sequence_number, edn.event_name, e.event_type,
              e.event_time, p.page_id , p.page_name,  p.product_id,  p.product_category
       From events e 
       Left Join users u  on  e.cookie_id = u.cookie_id
       Left Join event_identifier edn  on  e.event_type = edn.event_type
       Left Join page_heirarchy p  on  e.page_id = p.page_id  
   ) 
       Select JOINED.*  , cam.campaign_id, cam.campaign_name , cam.start_date , cam.end_date
INTO Final_Raw_Data From JOINED 
Left Join  campaign_identifier cam  on  JOINED.product_category = cam.products
Order by JOINED.user_id , JOINED.cookie_id


Select * From Final_Raw_Data;



/* Created product_level summary Table using joins & Common Table Expression ( CTE )  */

WITH  view_count 
as  (
      Select product_id, page_name as products, count(event_name) as view_count 
      From Final_Raw_Data
      Where page_name IN ('Lobster', 'Salmon', 'Russian Caviar', 'Tuna', 'Kingfish', 'Oyster', 'Crab', 'Abalone', 'Black Truffle' )
      and event_name = 'Page View'
      Group By page_name, product_id    ) , 
vc_cart  as 
    (
      Select  view_count.*  ,  cart_count.add_to_cart_count  From  view_count
      LEFT JOIN 	 
      	 (   
		 
		 Select product_id, page_name as products, count(event_name) as  add_to_cart_count
         From Final_Raw_Data
         Where page_name IN ('Lobster', 'Salmon', 'Russian Caviar', 'Tuna', 'Kingfish', 'Oyster', 'Crab', 'Abalone', 'Black Truffle' )
         and event_name = 'Add to Cart'
         Group By page_name, product_id
	  
	 )   as cart_count
         ON view_count.product_id = cart_count.product_id   ) ,
vc_pur   as
     (  
	  Select  vc_cart.*  ,  pur_count.purchased_count  From  vc_cart
      LEFT JOIN 	 
      	 (   
		 Select product_id, page_name as products, count(event_name) as  purchased_count
         From Final_Raw_Data
         Where page_name IN ('Lobster', 'Salmon', 'Russian Caviar', 'Tuna', 'Kingfish', 'Oyster', 'Crab', 'Abalone', 'Black Truffle' )
         and event_name = 'Add to Cart' and visit_id IN (SELECT visit_id from Final_Raw_Data where event_name = 'Purchase')
         Group By page_name, product_id
	     
	 )   as pur_count
	     ON vc_cart.product_id = pur_count.product_id     ) ,
vc_abd   as
     (  
	  Select  vc_pur.*  ,  abd_count.abandoned_count  From  vc_pur
      LEFT JOIN 	 
      	 (   
		 Select product_id, page_name as products, count(event_name) as  abandoned_count
         From Final_Raw_Data
         Where page_name IN ('Lobster', 'Salmon', 'Russian Caviar', 'Tuna', 'Kingfish', 'Oyster', 'Crab', 'Abalone', 'Black Truffle' )
         and event_name = 'Add to Cart' and visit_id NOT IN (SELECT visit_id from Final_Raw_Data where event_name = 'Purchase')
         Group By page_name, product_id
	     
	 )   as abd_count
	     ON vc_pur.product_id = abd_count.product_id    )
Select * 
Into product_level_summary  From vc_abd

		 
Select * From product_level_summary  




/* Created product_category_level summary Table using joins & Common Table Expression ( CTE )  */

WITH  vc
as  (
      Select product_category, product_id, count(event_name) as view_count 
      From Final_Raw_Data
      Where product_category IN ('Luxury', 'Shellfish', 'Fish')
      and event_name = 'Page View'
      Group By product_category, product_id   ) , 
vc_cart  as 
    (
      Select  vc.*  ,  cart_count.add_to_cart_count  From  vc
      LEFT JOIN 	 
      	 (   

		 Select product_category, product_id, count(event_name) as add_to_cart_count
         From Final_Raw_Data
         Where product_category IN ('Luxury', 'Shellfish', 'Fish')
         and event_name = 'Add to Cart'
         Group By product_category, product_id   
	  
	 )   as cart_count
         ON vc.product_id = cart_count.product_id  ) ,
vc_pur   as
     (  
	  Select  vc_cart.*  ,  pur_count.purchased_count  From  vc_cart
      LEFT JOIN 	 
      	 (   
		 Select product_category, product_id, count(event_name) as purchased_count 
         From Final_Raw_Data
         Where product_category IN ('Luxury', 'Shellfish', 'Fish')
         and event_name = 'Add to Cart' and visit_id IN (SELECT visit_id from Final_Raw_Data where event_name = 'Purchase')
         Group By product_category, product_id
	     
	 )   as pur_count
	     ON vc_cart.product_id = pur_count.product_id     ) ,
vc_abd   as
     (  
	  Select  vc_pur.*  ,  abd_count.abandoned_count  From  vc_pur
      LEFT JOIN 	 
      	 (   
		 Select product_category, product_id, count(event_name)  as  abandoned_count
         From Final_Raw_Data
         Where product_category IN ('Luxury', 'Shellfish', 'Fish')         
		 and event_name = 'Add to Cart' and visit_id NOT IN (SELECT visit_id from Final_Raw_Data where event_name = 'Purchase')
         Group By product_category, product_id
	     
	 )   as abd_count
	     ON vc_pur.product_id = abd_count.product_id    )

Select product_category, sum(view_count) as view_count, sum(add_to_cart_count) as add_to_cart_count,	
sum(purchased_count) as purchased_count, sum(abandoned_count) as abandoned_count 
Into product_category_level_summary 
From vc_abd
Group by product_category

		 
Select * From product_category_level_summary




/* Created visit_summary Table using using joins & Common Table Expression ( CTE )  */


WITH  pflag 
as (  

       Select user_id , visit_id, min(event_time) as visit_start_time,
	   Case when Max (case when event_type = '3' then 1 else 0 end ) = 1 then 1 
	   else 0  end as purchase_flag from Final_Raw_Data
       group by user_id , visit_id

   ),  pageview
as (
       Select  pflag.*  ,  pv.page_views  From pflag
       LEFT JOIN  (

       Select visit_id, count(event_name) as page_views
	   From Final_Raw_Data 
	   Where event_name = 'Page View'
	   Group By visit_id
   )   as pv  
	   ON pflag.visit_id = pv.visit_id
	
   ),  Viewcart 
as (
       Select  pageview.*  ,  ca.cart_adds  From pageview
       Left JOIN  (

	                Select visit_id, count(event_name) as cart_adds
	                From Final_Raw_Data 
	                Where event_name = 'Add to Cart'
	                Group By visit_id
        		    
		     )  as ca   
	   ON pageview.visit_id = ca.visit_id
	          
   ), campaign
as (  
       Select  Viewcart.*  ,  camp.campaign_name  From Viewcart
       Left JOIN  (

	                Select visit_id , min(event_time) as visit_time , campaign_name , start_date , end_date
	                From Final_Raw_Data 
	                group by visit_id , campaign_name , start_date , end_date 
                    Having min(event_time) between start_date and end_date
        		    
		     )  as camp   
	   ON viewcart.visit_id = camp.visit_id

	), impressions
as  (
       Select  campaign.*  , imp.ad_impressions  From campaign
       Left JOIN  (

	                Select visit_id, count(event_type) as ad_impressions 
	                From Final_Raw_Data 
	                Where event_type = '4'
	                Group By visit_id
        		    
		     )  as imp  
	   ON campaign.visit_id = imp.visit_id

	), clicks
as  (
       Select  impressions.*  , cl.ad_clicks  From impressions
       Left JOIN  (

	                Select visit_id, count(event_type) as ad_clicks 
	                From Final_Raw_Data 
	                Where event_type = '5'
	                Group By visit_id
        		    
		     )  as cl  
	   ON impressions.visit_id = cl.visit_id

	), cartadds
as  (
       Select  clicks.*  , ct.cart_products  From clicks
       Left JOIN  (
	                SELECT visit_id, 
                    STRING_AGG(page_name, ', ') Within Group (Order by sequence_number asc) as cart_products
                    From Final_Raw_Data
                    where event_name = 'Add to Cart'
                    GROUP BY visit_id
                            		    
		     )  as ct
	   ON clicks.visit_id = ct.visit_id

 ) Select *  Into  visit_summary 
   From  cartadds


   Select * from visit_summary





