﻿



CREATE VIEW [DASH].[v_BATCH_SCHD_AVGS]
 as
With CTE AS
(
SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 7,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 31

UNION ALL

SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 32

UNION ALL

SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 33

UNION ALL

SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 34

UNION ALL

SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 7,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 31

Union All 

SELECT TOP 20 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 32

Union All 

SELECT TOP 10 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 33

Union All 

SELECT TOP 10 PERCENT LOG_ID, SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,B.START_DTE,B.END_DTE) as 'Seconds'
FROM [AM].[BATCH_CTRL_DETAIL] B
WHERE B.END_DTE is not null 
	and B.START_DTE is not null
	and DateDIFF(Second,B.START_DTE,B.END_DTE) > 120
	and START_DTE >= DATEADD(dd,- 30,GetDate())
	and SCHEDULE_TYPE_VALUE_ID = 34


)
,
CTE2 
AS
(
SELECT B.SCHEDULE_TYPE_VALUE_ID, C.CODE_VALUE_DESC ,Avg(Seconds) as 'AVG'
FROM CTE B
	JOIN AM.ARTIFACT_CODE_VALUE C
		ON C.CODE_VALUE_ID = b.SCHEDULE_TYPE_VALUE_ID
Group By SCHEDULE_TYPE_VALUE_ID, C.CODE_VALUE_DESC
)
SELECT CTE2.SCHEDULE_TYPE_VALUE_ID, CODE_VALUE_DESC, [AVG], CUR, X.ElapsedTime
FROM CTE2 
JOIN
  (Select SCHEDULE_TYPE_VALUE_ID, DateDIFF(Second,START_DTE,Isnull(END_DTE,GETDATE())) AS 'CUR'
  ,Concat(datepart(MINUTE,isnull(END_DTE, Getdate()) - START_DTE), ':', Isnull(datepart(SECOND,isnull(END_DTE,Getdate()) - START_DTE),00)) as ElapsedTime
	 FROM AM.BATCH_CTRL_MASTER) X
   ON X.SCHEDULE_TYPE_VALUE_ID = CTE2.SCHEDULE_TYPE_VALUE_ID 


