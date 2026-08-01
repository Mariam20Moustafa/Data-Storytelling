use telecom_clean;
--  Database Overview
SELECT 
    'telecom_clean' AS Database_Name,
    6 AS Total_Tables,
    40 AS Total_INSERT_Statements,
    28230 AS Total_Data_Rows;

--  Demographics Summary
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male_Count,
    SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female_Count,
    AVG(Age) AS Average_Age,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age,
    SUM(CASE WHEN Under30 = 'Yes' THEN 1 ELSE 0 END) AS Under30_Count,
    SUM(CASE WHEN SeniorCitizen = 'Yes' THEN 1 ELSE 0 END) AS Senior_Count,
    SUM(CASE WHEN Married = 'Yes' THEN 1 ELSE 0 END) AS Married_Count,
    SUM(CASE WHEN Dependents = 'Yes' THEN 1 ELSE 0 END) AS Has_Dependents_Count
FROM Demographics;

--  Age Distribution
SELECT 
    CASE 
        WHEN Age < 20 THEN 'Under 20'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 64 THEN '60-64'
        WHEN Age >= 65 THEN '65+'
    END AS Age_Group,
    COUNT(*) AS Customer_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM Demographics
GROUP BY 
    CASE 
        WHEN Age < 20 THEN 'Under 20'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 64 THEN '60-64'
        WHEN Age >= 65 THEN '65+'
    END
ORDER BY Customer_Count DESC;

--  Services Summary
SELECT 
    COUNT(DISTINCT Customer_ID) AS Total_Service_Customers,
    AVG(Tenure_in_Months) AS Avg_Tenure_Months,
    AVG(Monthly_Charge) AS Avg_Monthly_Charge,
    SUM(Total_Revenue) AS Total_Revenue,
    SUM(CASE WHEN Phone_Service = 'Yes' THEN 1 ELSE 0 END) AS Phone_Service_Count,
    SUM(CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END) AS Fiber_Optic_Count,
    SUM(CASE WHEN Internet_Type = 'DSL' THEN 1 ELSE 0 END) AS DSL_Count,
    SUM(CASE WHEN Contract = 'Month-to-Month' THEN 1 ELSE 0 END) AS MonthToMonth_Count,
    SUM(CASE WHEN Contract = 'One Year' THEN 1 ELSE 0 END) AS OneYear_Count,
    SUM(CASE WHEN Contract = 'Two Year' THEN 1 ELSE 0 END) AS TwoYear_Count
FROM services;

--  Churn Status Summary
SELECT 
    Customer_Status,
    COUNT(*) AS Customer_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage,
    AVG(Satisfaction_Score) AS Avg_Satisfaction,
    AVG(Churn_Score) AS Avg_Churn_Score,
    AVG(CLTV) AS Avg_CLTV
FROM status
GROUP BY Customer_Status
ORDER BY Customer_Count DESC;

--  Location Summary
SELECT 
    COUNT(DISTINCT City) AS Unique_Cities,
    COUNT(DISTINCT Zip_Code) AS Unique_Zip_Codes,
    AVG(Latitude) AS Avg_Latitude,
    AVG(Longitude) AS Avg_Longitude
FROM locations;

--  Population Summary
SELECT 
    COUNT(*) AS Total_Zip_Records,
    SUM(Population) AS Total_Population,
    AVG(Population) AS Avg_Population_Per_Zip,
    MIN(Population) AS Min_Population,
    MAX(Population) AS Max_Population
FROM population;

--  Cross-Table Customer Verification
SELECT 
    (SELECT COUNT(*) FROM customers) AS Customers_Table_Count,
    (SELECT COUNT(*) FROM Demographics) AS Demographics_Table_Count,
    (SELECT COUNT(*) FROM services) AS Services_Table_Count,
    (SELECT COUNT(*) FROM status) AS Status_Table_Count,
    (SELECT COUNT(*) FROM locations) AS Locations_Table_Count;

--  Revenue Analysis by Contract Type
SELECT 
    s.Contract,
    COUNT(*) AS Customer_Count,
    AVG(s.Monthly_Charge) AS Avg_Monthly_Charge,
    AVG(s.Total_Revenue) AS Avg_Total_Revenue,
    SUM(s.Total_Revenue) AS Total_Revenue,
    AVG(st.Satisfaction_Score) AS Avg_Satisfaction
FROM services s
JOIN status st ON s.Customer_ID = st.Customer_ID
GROUP BY s.Contract
ORDER BY Total_Revenue DESC;

--  Churn Analysis by Demographics
SELECT 
    d.Gender,
    CASE WHEN d.SeniorCitizen = 'Yes' THEN 'Senior' ELSE 'Non-Senior' END AS Senior_Status,
    st.Customer_Status,
    COUNT(*) AS Count,
    ROUND(AVG(st.Churn_Score), 2) AS Avg_Churn_Score,
    ROUND(AVG(s.Monthly_Charge), 2) AS Avg_Monthly_Charge
FROM Demographics d
JOIN status st ON d.CustomerID = st.Customer_ID
JOIN services s ON d.CustomerID = s.Customer_ID
GROUP BY d.Gender, d.SeniorCitizen, st.Customer_Status
ORDER BY Count DESC;
--حديد الـ Churn Rate الإجمالي والـ Revenue Lost (الخسارة المالية)
SELECT 
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(CASE WHEN st.ChurNo_Label = 'Yes' THEN 1 ELSE 0 END) AS Total_Churned,
    ROUND(CAST(SUM(CASE WHEN st.ChurNo_Label = 'Yes' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(c.Customer_ID) * 100, 2) AS Churn_Rate_Pct,
    SUM(CASE WHEN st.ChurNo_Label = 'Yes' THEN s.Total_Revenue ELSE 0 END) AS Revenue_Lost
FROM customers c
JOIN Status st ON c.Customer_ID = st.Customer_ID
JOIN Services s ON c.Customer_ID = s.Customer_ID;
--معرفة أعلى أنواع العقود (Contract Types) في التسرب
SELECT 
    s.Contract,
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(CASE WHEN st.ChurNo_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(CAST(SUM(CASE WHEN st.ChurNo_Label= 'Yes' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(c.Customer_ID) * 100, 2) AS Churn_Rate_Pct
FROM customers c
JOIN services s ON c.Customer_ID = s.Customer_ID
JOIN status st ON c.Customer_ID = st.Customer_ID
GROUP BY s.Contract
ORDER BY Churn_Rate_Pct DESC;
-- العلاقة بين درجة الرضا (Satisfaction Score) والتسرب
SELECT 
    st.Satisfaction_Score,
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(CASE WHEN st.ChurNO_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers
FROM Status st
JOIN customers c ON st.Customer_ID = c.Customer_ID
GROUP BY st.Satisfaction_Score
ORDER BY st.Satisfaction_Score ASC;
--أعلى 5 مدن من حيث نسبة التسرب (Geographic High-Risk Areas)
SELECT 
    l.City,
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(CASE WHEN st.ChurNO_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(CAST(SUM(CASE WHEN st.ChurNO_Label = 'Yes' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(c.Customer_ID) * 100, 2) AS Churn_Rate_Pct
FROM locations l
JOIN customers c ON l.Customer_ID = c.Customer_ID
JOIN status st ON c.Customer_ID = st.Customer_ID
GROUP BY l.City
HAVING COUNT(c.Customer_ID) > 30 -- عشان اضمن إن المدينة فيها عدد كافي من العملاء
ORDER BY Churn_Rate_Pct DESC limit 5;
-- المدن التي بها أكثر من 20 عميل ومعدل تسرب (Churn) مرتفع
SELECT 
    l.City,
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(CASE WHEN st.ChurNo_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    AVG(st.Satisfaction_Score) AS Avg_Satisfaction
FROM customers c
INNER JOIN locations l ON c.Customer_ID = l.Customer_ID
INNER JOIN status st ON c.Customer_ID = st.Customer_ID
GROUP BY l.City
HAVING COUNT(c.Customer_ID) > 20
ORDER BY Churned_Customers DESC;
--أنواع العقود والخدمات التي تتجاوز أرباحها الإجمالية $50,000
SELECT 
    s.Contract,
    s.Internet_Type,
    COUNT(c.Customer_ID) AS Total_Customers,
    SUM(s.Total_Revenue) AS Group_Total_Revenue,
    AVG(s.Monthly_Charge) AS Avg_Monthly_Charge
FROM customers c
INNER JOIN services s ON c.Customer_ID = s.Customer_ID
INNER JOIN status st ON c.Customer_ID = st.Customer_ID
GROUP BY s.Contract, s.Internet_Type
HAVING SUM(s.Total_Revenue) > 50000
ORDER BY Group_Total_Revenue DESC;
--الفئات العمرية (Demographics) التي يتجاوز متوسط استهلاكها للبيانات 30 GB ومتوسط تقييمها أقل من 3
SELECT 
    d.Gender,
    d.SeniorCitizen,
    COUNT(c.Customer_ID) AS Total_Customers,
    ROUND(AVG(s.Avg_Monthly_GB_Download), 2) AS Avg_GB_Usage,
    ROUND(AVG(st.Satisfaction_Score), 2) AS Avg_Satisfaction_Score
FROM customers c
INNER JOIN demographics d ON c.Customer_ID = d.CustomerID
INNER JOIN services s ON c.Customer_ID = s.Customer_ID
INNER JOIN status st ON c.Customer_ID = st.Customer_ID
GROUP BY d.Gender, d.SeniorCitizen
HAVING COUNT(c.Customer_ID) > 10;