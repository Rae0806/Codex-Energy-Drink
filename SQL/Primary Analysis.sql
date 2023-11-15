
-- Demographic Insights

-- Question 1: Who prefers energy drink more? (male/female/non-binary?)

select b.Gender, count(*)  total_count
from fact_survey_responses a
join respondents b on a.Respondent_ID = b.Respondent_ID
group by b.Gender
order by total_count desc;

-- Question2:  Which age group prefers energy drinks more?

select b.Age, count(*)  total_count
from fact_survey_responses a
join respondents b on a.Respondent_ID = b.Respondent_ID
group by b.Age
order by total_count desc;

-- Question 3: Which type of marketing reaches the most Youth (15-30)?
select a.Marketing_channels, count(*)  total_reach
from fact_survey_responses a
join respondents b on a.Respondent_ID = b.Respondent_ID
where b.Age = '19-30'
group by a.Marketing_channels
order by total_reach desc;


-- Consuumer Preferences

-- What are the preferred ingredients of energy drinks among respondents?
select Ingredients_expected, count(*) preferred_ingredient_count
from fact_survey_responses
group by Ingredients_expected;

-- What packaging preferences do respondents have for energy drinks?
select distinct Packaging_preference
from fact_survey_responses;

-- Competition Analysis
-- Who are the current market leaders?
select Current_brands, count(Current_brands) current_consumer_count
from fact_survey_responses
group by Current_brands
order by current_consumer_count desc;

-- What are the primary reasons consumers prefer those brands over ours?
with reason as (
select Current_brands, Reasons_for_choosing_brands, count(Reasons_for_choosing_brands) total_count,
		row_number() over(partition by current_brands  order by count(Reasons_for_choosing_brands) desc) rn
from fact_survey_responses
group by Current_brands, Reasons_for_choosing_brands
order by Current_brands, total_count
)

select current_brands, reasons_for_choosing_brands
from reason
where rn = 1;

-- Marketing Channels and Brand Awareness 

--  Which marketing channel can be used to reach more customers?

select Marketing_channels, count(*) total_reach
from fact_survey_responses
group by Marketing_channels
order by total_reach desc;

-- How effective are different marketing strategies and channels in reaching our customers?
with reach as (
select 	Marketing_channels, 
		count(*) consumer_reach_count, 
		(select count(*) from fact_survey_responses) total_consumer
from fact_survey_responses
where Current_brands = 'Codex'
group by Marketing_channels
order by consumer_reach_count desc
)

select Marketing_channels, round((consumer_reach_count/total_consumer)*100,2) reach_percent
from reach ;

-- the Effectiveness of Marketing strategies in reaching our customers


-- Brand Penetration 
-- Question: What do people think about our brand? (overall rating)

with rating as (
select Tried_before, Taste_experience,
		case when tried_before = 'No' then 0 
			else Taste_experience end overall_rating
from fact_survey_responses
)

select round(avg(overall_rating)) avg_overall_rating
from rating ;

--  Which cities do we need to focus more on?

select  c.City, count(a.Respondent_ID) consumer_count
from fact_survey_responses a
join respondents b on a.Respondent_ID = b.Respondent_ID
join cities c on b.City_ID = c.City_ID
group by c.City
order by consumer_count desc
limit 5;

-- Purchase Behaviour 

-- Where do respondents prefer to purchase energy drinks?
select Purchase_location, count(Purchase_location) purchase_count 
from fact_survey_responses
group by Purchase_location 
order by purchase_count desc;

-- What are the typical consumption situations for energy drinks among respondents?

select Consume_time, count(Consume_time) respondent_count
from fact_survey_responses
group by Consume_time;

-- What factors influence respondents' purchase decisions, such as price range and limited edition packaging?

-- Price Range
select Price_range, count(Price_range) cnt 
from fact_survey_responses
group by Price_range 
order by cnt desc;

-- Limited Edition Packaging  

select Limited_edition_packaging, count(Limited_edition_packaging) cnt 
from fact_survey_responses
group by Limited_edition_packaging
order by cnt desc;

-- Health Concern

select Health_concerns, count(Health_concerns) cnt 
from fact_survey_responses
group by Health_concerns;


-- Product Development 

--  Which area of business should we focus more on our product development? (Branding/taste/availability)

with cte as (
select respondent_feedback, sum(respondent_cnt) respondent_cnt
from (
		select case when Taste_experience < 4 then 'Bad Taste'
					else 'Good Taste' end respondent_feedback,
			   count(*) respondent_cnt
		from fact_survey_responses
        where Heard_before ='Yes' and  Tried_before = 'Yes'
        group by respondent_feedback
	 ) a
group by respondent_feedback
order by respondent_cnt desc
limit 1
),

cte1 as (
select 	Reasons_preventing_trying as respondent_feedback, 
		count(*) respondent_cnt
from 	fact_survey_responses
where Reasons_preventing_trying not in ('Other', 'Not interested in energy drinks') and Tried_before = 'No' 
group by respondent_feedback
)

select respondent_feedback , respondent_cnt
from cte 
group by respondent_feedback , respondent_cnt

union all 

select respondent_feedback, respondent_cnt
from cte1
group by respondent_feedback , respondent_cnt
order by respondent_cnt desc
