
-- aggregates overview
SELECT
  year_name, class_name,
  SUM(occurrence) total_occurrence,
SUM(injured) sum_injured,
SUM(killed) sum_killed
FROM ROADEVENTS_STAR
GROUP BY year_name, class_name
ORDER BY year_name, class_name;

-- slice
SELECT
  SUM(occurrence) total_occurrence,
  SUM(injured) sum_injured,
  SUM(killed) sum_killed
FROM ROADEVENTS_STAR
WHERE day_date=TO_DATE('20170812','YYYYMMDD');
-- selection

-- drill-down
SELECT class_name, category_name, event_name,
  SUM(occurrence) total_occurrence,
  SUM(injured) sum_injured,
  SUM(killed) sum_killed
FROM ROADEVENTS_STAR
WHERE day_date=TO_DATE('20170812','YYYYMMDD')
GROUP BY class_name, category_name, event_name
ORDER BY class_name, category_name, event_name;

-- dice
SELECT event_name, segment_voivodeship,
  SUM(occurrence) occurrence_in_201708
FROM ROADEVENTS_STAR
WHERE
  month_of_year=8 and year_name='CY2017' and
  category_name='traffic rules' and
  segment_voivodeship in ('Masovian','Subcarpathian','Lesser Poland')
GROUP BY event_name, segment_voivodeship
ORDER BY event_name, segment_voivodeship;

-- pivot
SELECT
    *
FROM
(
  SELECT
    event_name,
    segment_voivodeship,
    SUM(occurrence) occurrence_in_201708
  FROM
    ROADEVENTS_STAR
  WHERE
    month_of_year = 8 AND year_name = 'CY2017'
    AND category_name = 'traffic rules'
    AND segment_voivodeship IN ( 'Masovian', 'Subcarpathian', 'Lesser Poland' )
  GROUP BY event_name, segment_voivodeship
  ORDER BY event_name, segment_voivodeship
) PIVOT (
    SUM ( occurrence_in_201708 )
    FOR ( segment_voivodeship )
    IN (
      'Masovian' as masovian,
      'Subcarpathian' as subcarpathian,
      'Lesser Poland' as lesser_poland
    )
)
