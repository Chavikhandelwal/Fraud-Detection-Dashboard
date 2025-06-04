CREATE DATABASE fraud_detection;
USE fraud_detection;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    join_date DATE,
    region VARCHAR(100),
    account_type VARCHAR(20),
    risk_score FLOAT
);

CREATE TABLE devices (
    device_id VARCHAR(100) PRIMARY KEY,
    user_id INT,
    registered_on DATE,
    last_used_ip VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE blacklisted_ips (
    ip_address VARCHAR(45) PRIMARY KEY,
    reason TEXT,
    added_on DATE
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    txn_time DATETIME,
    amount FLOAT,
    merchant_type VARCHAR(50),
    txn_type VARCHAR(30),
    device VARCHAR(100),
    location VARCHAR(100),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM users LIMIT 5;
SELECT * FROM devices LIMIT 5;
SELECT * FROM  blacklisted_ips LIMIT 5;
SELECT * FROM transactions LIMIT 5;

DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    txn_time DATETIME,
    amount FLOAT,
    merchant_type VARCHAR(50),
    txn_type VARCHAR(30),
    device VARCHAR(100),
    location VARCHAR(100),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT 
    t.txn_id,
    t.user_id,
    t.txn_time,
    t.amount,
    t.ip_address
FROM transactions t
JOIN blacklisted_ips b
  ON t.ip_address = b.ip_address;

SELECT COUNT(*) FROM blacklisted_ips;

SELECT COUNT(*) 
FROM transactions 
WHERE ip_address IN (SELECT ip_address FROM blacklisted_ips);

UPDATE transactions
SET ip_address = (SELECT ip_address FROM blacklisted_ips LIMIT 1)
LIMIT 5;

SELECT 
    t.txn_id, t.user_id, t.txn_time, t.amount, t.ip_address
FROM transactions t
JOIN blacklisted_ips b ON t.ip_address = b.ip_address;

SELECT 
    txn_id,
    user_id,
    txn_time,
    amount,
    txn_type,
    merchant_type
FROM transactions
WHERE txn_type = 'international' AND amount > 10000;

SELECT 
    t.txn_id,
    t.user_id,
    t.device,
    t.txn_time,
    t.amount
FROM transactions t
LEFT JOIN devices d
  ON t.device = d.device_id AND t.user_id = d.user_id
WHERE d.device_id IS NULL;

SELECT *
FROM (
    SELECT 
        txn_id,
        user_id,
        txn_time,
        amount,
        COUNT(*) OVER (
            PARTITION BY user_id 
            ORDER BY txn_time 
            RANGE BETWEEN INTERVAL 5 MINUTE PRECEDING AND CURRENT ROW
        ) AS txn_count_in_5min
    FROM transactions
) t
WHERE txn_count_in_5min >= 5;

SELECT 
    ip_address,
    COUNT(DISTINCT user_id) AS user_count
FROM transactions
GROUP BY ip_address
HAVING user_count >= 3;

SELECT *
FROM transactions
WHERE ip_address IN (
    SELECT ip_address
    FROM transactions
    GROUP BY ip_address
    HAVING COUNT(DISTINCT user_id) >= 3
);

CREATE OR REPLACE VIEW fraud_blacklisted_ip AS
SELECT 
    txn_id, user_id, txn_time, amount, 'Blacklisted IP' AS fraud_reason
FROM transactions
WHERE ip_address IN (SELECT ip_address FROM blacklisted_ips);


CREATE OR REPLACE VIEW fraud_high_value_international AS
SELECT 
    txn_id, user_id, txn_time, amount, 'High-Value International' AS fraud_reason
FROM transactions
WHERE txn_type = 'international' AND amount > 10000;


CREATE OR REPLACE VIEW fraud_unregistered_device AS
SELECT 
    t.txn_id, t.user_id, t.txn_time, t.amount, 'Unregistered Device' AS fraud_reason
FROM transactions t
LEFT JOIN devices d 
  ON t.device = d.device_id AND t.user_id = d.user_id
WHERE d.device_id IS NULL;


CREATE OR REPLACE VIEW fraud_rapid_spending AS
SELECT txn_id, user_id, txn_time, amount, 'Rapid Spending' AS fraud_reason
FROM (
    SELECT 
        txn_id,
        user_id,
        txn_time,
        amount,
        COUNT(*) OVER (
            PARTITION BY user_id 
            ORDER BY txn_time 
            RANGE BETWEEN INTERVAL 5 MINUTE PRECEDING AND CURRENT ROW
        ) AS txn_count
    FROM transactions
) temp
WHERE txn_count >= 5;


CREATE OR REPLACE VIEW fraud_shared_ip AS
SELECT 
    txn_id, user_id, txn_time, amount, 'Shared IP' AS fraud_reason
FROM transactions
WHERE ip_address IN (
    SELECT ip_address
    FROM transactions
    GROUP BY ip_address
    HAVING COUNT(DISTINCT user_id) >= 3
);


CREATE OR REPLACE VIEW fraud_alerts_view AS
SELECT * FROM fraud_blacklisted_ip
UNION
SELECT * FROM fraud_high_value_international
UNION
SELECT * FROM fraud_unregistered_device
UNION
SELECT * FROM fraud_rapid_spending
UNION
SELECT * FROM fraud_shared_ip;


SELECT * FROM fraud_alerts_view;

CREATE TABLE alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    txn_id INT,
    user_id INT,
    txn_time DATETIME,
    amount FLOAT,
    fraud_reason VARCHAR(100),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (txn_id) REFERENCES transactions(txn_id)
);

INSERT INTO alerts (txn_id, user_id, txn_time, amount, fraud_reason)
SELECT txn_id, user_id, txn_time, amount, fraud_reason
FROM fraud_alerts_view;

SELECT * FROM alerts WHERE resolved = FALSE;

UPDATE alerts SET resolved = TRUE WHERE alert_id = 5;

SELECT * FROM alerts;

SET SQL_SAFE_UPDATES = 0;

UPDATE alerts
SET resolved = FALSE;

CREATE TEMPORARY TABLE temp_resolved_ids
SELECT alert_id
FROM alerts
ORDER BY RAND()
LIMIT 300; 

UPDATE alerts
SET resolved = TRUE
WHERE alert_id IN (SELECT alert_id FROM temp_resolved_ids);

SELECT resolved, COUNT(*) 
FROM alerts 
GROUP BY resolved;
