-- ----------------------------------database--------------------------------------------------------------------
create database projectdb;
use projectdb;
drop database projectdb;
-- -------------------------------customer acccount table ---------------------------------------------
CREATE TABLE customer_account (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone BIGINT NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    pass_word VARCHAR(50) NOT NULL,
    createdat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- -------------------------------------driver account table------------------------------------------
CREATE TABLE driver_account (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone BIGINT NOT NULL UNIQUE,
    vehicleno VARCHAR(20) NOT NULL UNIQUE,
    pass_word VARCHAR(50) NOT NULL,
    availability ENUM('available', 'booked') NOT NULL DEFAULT 'available',
    createdat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- -------------------------------------login-------------------------------------------------------
CREATE TABLE  login
(username bigint unique,
pass_word varchar(10),
loginat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ------------------trigger to automatically insert login-----------------------------------------
DELIMITER $$

CREATE TRIGGER insert_customer_login
AFTER INSERT ON customer_account
FOR EACH ROW
BEGIN
    INSERT INTO login(username,pass_word)
    VALUES (NEW.phone, NEW.pass_word);
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER insert_driver_login
AFTER INSERT ON driver_account
FOR EACH ROW
BEGIN
    INSERT INTO login(username,pass_word)
    VALUES (NEW.phone, NEW.pass_word);
END $$
DELIMITER ;
-- -------------------------------bookings table-------------------------------------------------
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    cus_id INT NOT NULL,
    cus_name VARCHAR(50) NOT NULL,
    dri_id INT NOT NULL,
    pickup VARCHAR(50) NOT NULL,
    dropat VARCHAR(50) NOT NULL,
    payment DECIMAL(10,2) NOT NULL,
    status ENUM('booked','enroute', 'cancelled', 'completed') DEFAULT 'booked',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cus_id) REFERENCES customer_account(id),
    FOREIGN KEY (dri_id) REFERENCES driver_account(id)
);
ALTER TABLE bookings
ADD updated_at TIMESTAMP
DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;
-- -------------------------ride status-----------------------------------------------------------
CREATE TABLE ride_status (
    booking_id INT PRIMARY KEY,
    status ENUM('booked', 'enroute', 'completed', 'cancelled') NOT NULL DEFAULT 'booked',
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- --------------------------city distance----------------------------------------------------------

CREATE TABLE city_distance (
    source VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    km DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (source, destination)
);
-- --------------------manual insertion of source and destination------------------------------------
INSERT INTO city_distance (source, destination, km) VALUES
('TNAGAR','KODAMBAKKAM',3.5),('KODAMBAKKAM','TNAGAR',3.5),
('TNAGAR','GUINDY',6.0),('GUINDY','TNAGAR',6.0),
('TNAGAR','ADYAR',7.5),('ADYAR','TNAGAR',7.5),
('TNAGAR','THIRUVANMIYUR',10.0),('THIRUVANMIYUR','TNAGAR',10.0),

('VELACHERY','GUINDY',4.5),('GUINDY','VELACHERY',4.5),
('VELACHERY','ADYAR',6.0),('ADYAR','VELACHERY',6.0),
('VELACHERY','THIRUVANMIYUR',5.0),('THIRUVANMIYUR','VELACHERY',5.0),
('VELACHERY','OMR',8.5),('OMR','VELACHERY',8.5),

('ANNANAGAR','KOYAMBEDU',4.0),('KOYAMBEDU','ANNANAGAR',4.0),
('ANNANAGAR','KILPAUK',3.5),('KILPAUK','ANNANAGAR',3.5),
('ANNANAGAR','EGMORE',9.0),('EGMORE','ANNANAGAR',9.0),
('ANNANAGAR','GUINDY',12.0),('GUINDY','ANNANAGAR',12.0),

('AIRPORT','GUINDY',5.0),('GUINDY','AIRPORT',5.0),
('AIRPORT','VELACHERY',7.0),('VELACHERY','AIRPORT',7.0),
('AIRPORT','TNAGAR',12.0),('TNAGAR','AIRPORT',12.0),
('AIRPORT','OMR',15.0),('OMR','AIRPORT',15.0),

('CHENNAICENTRAL','TNAGAR',9.0),('TNAGAR','CHENNAICENTRAL',9.0),
('CHENNAICENTRAL','VELACHERY',17.0),('VELACHERY','CHENNAICENTRAL',17.0),
('CHENNAICENTRAL','GUINDY',14.0),('GUINDY','CHENNAICENTRAL',14.0),
('CHENNAICENTRAL','ADYAR',13.0),('ADYAR','CHENNAICENTRAL',13.0),

('GUINDY','ADYAR',6.0),('ADYAR','GUINDY',6.0),
('GUINDY','THIRUVANMIYUR',7.0),('THIRUVANMIYUR','GUINDY',7.0),
('OMR','THIRUVANMIYUR',4.0),('THIRUVANMIYUR','OMR',4.0),
('OMR','ADYAR',9.0),('ADYAR','OMR',9.0),

('TAMBARAM','GUINDY',18.0),('GUINDY','TAMBARAM',18.0),
('TAMBARAM','VELACHERY',14.0),('VELACHERY','TAMBARAM',14.0),
('TAMBARAM','AIRPORT',11.0),('AIRPORT','TAMBARAM',11.0),

('EGMORE','TNAGAR',6.5),('TNAGAR','EGMORE',6.5),
('EGMORE','VELACHERY',13.0),('VELACHERY','EGMORE',13.0),
('EGMORE','ADYAR',10.0),('ADYAR','EGMORE',10.0),

('PORUR','POONAMALLEE',8),('POONAMALLEE','PORUR',8),
('PORUR','AMBATTUR',10),('AMBATTUR','PORUR',10),
('PORUR','MADURAVOYAL',4),('MADURAVOYAL','PORUR',4),

('SHOLINGANALLUR','TAMBARAM',17),('TAMBARAM','SHOLINGANALLUR',17),
('PERUNGUDI','TAMBARAM',15),('TAMBARAM','PERUNGUDI',15),
('SIRUSERI','TAMBARAM',22),('TAMBARAM','SIRUSERI',22),

('ADYAR','NUNGAMBAKKAM',8),('NUNGAMBAKKAM','ADYAR',8),
('ASHOKNAGAR','KKNAGAR',2),('KKNAGAR','ASHOKNAGAR',2),
('KKNAGAR','PORUR',6),('PORUR','KKNAGAR',6),
('LITTLEMOUNT','SAIDAPET',2.5),
('SAIDAPET','LITTLEMOUNT',2.5);
INSERT INTO city_distance (source, destination, km) VALUES
('SAIDAPET','MOUNTROAD',2.0),
('MOUNTROAD','SAIDAPET',2.0),

('SAIDAPET','WESTMAMBALAM',3.0),
('WESTMAMBALAM','SAIDAPET',3.0),

('SAIDAPET','ALWARPET',2.5),
('ALWARPET','SAIDAPET',2.5),
('MYLAPORE','MANDAVELI',2.0),
('MANDAVELI','MYLAPORE',2.0),

('MYLAPORE','BESANTNAGAR',4.0),
('BESANTNAGAR','MYLAPORE',4.0),

('MYLAPORE','ADYAR',5.0),
('ADYAR','MYLAPORE',5.0),
('MOGAPPAIR','ANNANAGAR',3.5),
('ANNANAGAR','MOGAPPAIR',3.5),

('KORATTUR','AMBATTUR',4.0),
('AMBATTUR','KORATTUR',4.0);
-- ------------------------------update riding status----------------------------------
DELIMITER $$
CREATE TRIGGER after_booking_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    INSERT INTO ride_status (booking_id, status)
    VALUES (NEW.booking_id, NEW.status);
END$$
DELIMITER ;
-- -----------------------event to uodate booked to enroute--------------------------
set global event_scheduler= on;
DELIMITER $$
CREATE EVENT auto_update_booking_status
ON SCHEDULE EVERY 2 MINUTE
COMMENT 'Auto-transition booking statuses based on time'
DO
BEGIN
   UPDATE bookings 
   SET status = 'enroute',
       updated_at = NOW()
   WHERE status = 'booked'
   AND created_at <= NOW() - INTERVAL 5 MINUTE;

   UPDATE bookings 
   SET status = 'completed',
       updated_at = NOW()
   WHERE status = 'enroute'
   AND created_at <= NOW() - INTERVAL 30 MINUTE;
END$$
DELIMITER ;
 -- ---------------------trigger to update ridestatus--------------------------------
DELIMITER $$

CREATE TRIGGER update_ridestatus
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
IF NEW.status <> OLD.status THEN
update ride_status
    set status = NEW.status,last_update = NOW()
    WHERE booking_id = NEW.booking_id;
  END IF;
END $$

DELIMITER ;
select * from driver_account;
select * from customer_account;
select * from bookings;
select * from ride_status;
