USE status;

UPDATE status_cleaning SET churn_label = 'Yes' WHERE churn_label IN ('YES','yes','Y','y');
UPDATE status_cleaning SET churn_label = 'No' WHERE churn_label IN ('NO','no','N','n');

UPDATE status_cleaning SET customer_status = 'Unknown' WHERE customer_status = '' OR customer_status IS NULL;

UPDATE status_cleaning SET satisfaction_score = NULL WHERE satisfaction_score < 1 OR satisfaction_score > 5;

UPDATE status_cleaning SET cltv = NULL WHERE cltv < 0;

UPDATE status_cleaning SET satisfaction_score = 3 WHERE satisfaction_score IS NULL;
UPDATE status_cleaning SET cltv = 4401 WHERE cltv IS NULL;

UPDATE status_cleaning SET churn_label = 'Unknown' WHERE churn_label IS NULL;

DELETE t1 FROM status_cleaning AS t1
INNER JOIN status_cleaning AS t2
WHERE t1.customer_id = t2.customer_id
  AND t1.status_id > t2.status_id;

SELECT * FROM status_cleaning LIMIT 50;