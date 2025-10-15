-- 1. Create table 
DROP TABLE IF EXISTS public.marketing_data;
CREATE TABLE public.marketing_data (
  id           SERIAL PRIMARY KEY,
  date         DATE,
  campaign_name TEXT,
  category     TEXT,
  campaign_id  TEXT,
  impressions  BIGINT,
  mark_budget  NUMERIC(12,2),
  clicks       BIGINT,
  leads        BIGINT,
  orders       BIGINT,
  revenue      NUMERIC(12,2)
);


--------------------------------------------------------------------------------
-- 2. Add helper columns
--------------------------------------------------------------------------------
ALTER TABLE public.marketing_data
  ADD COLUMN IF NOT EXISTS day_type TEXT,
  ADD COLUMN IF NOT EXISTS platform TEXT,
  ADD COLUMN IF NOT EXISTS target_type TEXT;

--------------------------------------------------------------------------------
-- 3. Populate day_type (Weekday / Weekend)
-- EXTRACT(DOW FROM date): 0 = Sunday, 1 = Monday, ..., 6 = Saturday
--------------------------------------------------------------------------------
UPDATE public.marketing_data
SET day_type = CASE
  WHEN date IS NULL THEN 'Unknown'
  WHEN EXTRACT(DOW FROM date) IN (0,6) THEN 'Weekend'
  ELSE 'Weekday'
END
WHERE day_type IS NULL OR day_type = '';

--------------------------------------------------------------------------------
-- 4. Populate platform from campaign_name
-- Use ILIKE for case-insensitive pattern matching
--------------------------------------------------------------------------------
UPDATE public.marketing_data
SET platform = CASE
  WHEN campaign_name ILIKE '%facebook%' THEN 'facebook'
  WHEN campaign_name ILIKE '%instagram%' THEN 'instagram'
  WHEN campaign_name ILIKE '%google%' THEN 'google'
  WHEN campaign_name ILIKE '%youtube%' THEN 'youtube'
  WHEN campaign_name ILIKE '%banner%' THEN 'banner'
  ELSE 'other'
END
WHERE platform IS NULL OR platform = '';

--------------------------------------------------------------------------------
-- 5. Populate target_type from campaign_name
--------------------------------------------------------------------------------
UPDATE public.marketing_data
SET target_type = CASE
  WHEN campaign_name ILIKE '%tier1%' THEN 'tier1'
  WHEN campaign_name ILIKE '%tier2%' THEN 'tier2'
  WHEN campaign_name ILIKE '%blogger%' OR campaign_name ILIKE '%blogg%' THEN 'blogger'
  WHEN campaign_name ILIKE '%lal%' OR campaign_name ILIKE '%lookalike%' THEN 'lookalike'
  WHEN campaign_name ILIKE '%retargeting%' OR campaign_name ILIKE '%retarget%' THEN 'retargeting'
  WHEN campaign_name ILIKE '%partner%' THEN 'partner'
  WHEN campaign_name ILIKE '%hot%' THEN 'hot'
  WHEN campaign_name ILIKE '%wide%' THEN 'wide'
  ELSE 'other'
END
WHERE target_type IS NULL OR target_type = '';

--------------------------------------------------------------------------------
-- 6. Data cleaning helper
--------------------------------------------------------------------------------
UPDATE public.marketing_data
SET campaign_name = LOWER(TRIM(campaign_name))
WHERE campaign_name IS NOT NULL;

--------------------------------------------------------------------------------
-- 7. Quick summary counts after enrichment
--------------------------------------------------------------------------------
SELECT day_type, COUNT(*) AS cnt FROM public.marketing_data GROUP BY day_type ORDER BY cnt DESC;
SELECT platform, COUNT(*) AS cnt FROM public.marketing_data GROUP BY platform ORDER BY cnt DESC;
SELECT target_type, COUNT(*) AS cnt FROM public.marketing_data GROUP BY target_type ORDER BY cnt DESC;
SELECT DISTINCT campaign_name FROM public.marketing_data ORDER BY campaign_name

--------------------------------------------------------------------------------
-- 8. Create a view with calculated metrics
-- View calculates ROMI, CTR, conv rates, CPC, CPL, CAC, AOV, profit for each row (campaign X date)
--------------------------------------------------------------------------------
DROP VIEW IF EXISTS public.marketing_metrics;
CREATE VIEW public.marketing_metrics AS
SELECT
  id,
  date,
  campaign_name,
  category,
  campaign_id,
  impressions,
  mark_budget,
  clicks,
  leads,
  orders,
  revenue,
  -- metrics (use NULLIF to avoid division by zero)
  (revenue - mark_budget) / NULLIF(mark_budget, 0) AS romi,
  (clicks::numeric / NULLIF(impressions, 0)) AS ctr,
  (leads::numeric / NULLIF(clicks, 0)) AS conv1,
  (orders::numeric / NULLIF(leads, 0)) AS conv2,
  (mark_budget / NULLIF(clicks, 0)) AS cpc,
  (mark_budget / NULLIF(leads, 0)) AS cpl,
  (mark_budget / NULLIF(orders, 0)) AS cac,
  (revenue / NULLIF(orders, 0)) AS aov,
  (revenue - mark_budget) AS profit,
  day_type,
  platform,
  target_type
FROM public.marketing_data;

--------------------------------------------------------------------------------
-- 9. Overall marketing ROI & totals
SELECT
  ROUND(SUM(mark_budget), 2) AS total_spend,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(revenue) - SUM(mark_budget), 2) AS profit,
  ROUND((SUM(revenue) - SUM(mark_budget)) / NULLIF(SUM(mark_budget), 0), 2) AS overall_romi
FROM public.marketing_metrics;

-- 10.Platform-wise metrics
SELECT
  platform,
  ROUND((SUM(revenue) - SUM(mark_budget)) / NULLIF(SUM(mark_budget),0), 2) AS romi,
  ROUND(SUM(mark_budget), 2) AS total_spend,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(cpc), 2) AS avg_cpc,
  ROUND(AVG(cac), 2) AS avg_cac,
  ROUND(AVG(aov), 2) AS avg_aov
FROM public.marketing_metrics
GROUP BY platform
ORDER BY romi DESC;

-- 11 ROMI by target_type
SELECT
  target_type,
  ROUND((SUM(revenue) - SUM(mark_budget)) / NULLIF(SUM(mark_budget),0), 2) AS romi,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(mark_budget), 2) AS total_spend,
  ROUND(AVG(cac), 2) AS avg_cac,
  ROUND(AVG(aov), 2) AS avg_aov
FROM public.marketing_metrics
GROUP BY target_type
ORDER BY romi DESC;

-- 12.Weekday vs Weekend
SELECT
  day_type,
  ROUND(AVG(romi), 2) AS avg_romi,
  ROUND(AVG(aov), 2) AS avg_order_value,
  ROUND(AVG(cac), 2) AS avg_cac,
  ROUND(AVG(cpc), 2) AS avg_cpc,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(mark_budget), 2) AS total_spend
FROM public.marketing_metrics
GROUP BY day_type
ORDER BY avg_romi DESC;

-- 13. Daily spend & revenue trends
SELECT
  date,
  ROUND(SUM(mark_budget),2) AS total_spend,
  ROUND(SUM(revenue),2) AS total_revenue,
  ROUND((SUM(revenue) - SUM(mark_budget)) / NULLIF(SUM(mark_budget),0), 2) AS romi
FROM public.marketing_metrics
GROUP BY date
ORDER BY date;

-- 14. Combined platform + target_type summary (dashboard)
SELECT
  platform,
  target_type,
  ROUND(SUM(mark_budget), 2) AS total_spend,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND((SUM(revenue) - SUM(mark_budget)) / NULLIF(SUM(mark_budget),0), 2) AS romi,
  ROUND(AVG(cpc), 2) AS avg_cpc,
  ROUND(AVG(cac), 2) AS avg_cac,
  ROUND(AVG(aov), 2) AS avg_aov
FROM public.marketing_metrics
GROUP BY platform, target_type
ORDER BY romi DESC NULLS LAST;

-- 15. Top rows by ROMI (inspect best performing rows)
SELECT *
FROM public.marketing_metrics
ORDER BY romi DESC NULLS LAST
LIMIT 20;

-- 16. Basic data quality checks
SELECT
  SUM(CASE WHEN impressions IS NULL OR impressions = 0 THEN 1 ELSE 0 END) AS no_impressions,
  SUM(CASE WHEN clicks IS NULL OR clicks = 0 THEN 1 ELSE 0 END) AS no_clicks,
  SUM(CASE WHEN leads IS NULL OR leads = 0 THEN 1 ELSE 0 END) AS no_leads,
  SUM(CASE WHEN orders IS NULL OR orders = 0 THEN 1 ELSE 0 END) AS no_orders
FROM public.marketing_data;

