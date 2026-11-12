show databases;
create database project;
use project;
SELECT VERSION() AS mysql_server_version;

CREATE TABLE movies (
  movie_id INT NOT NULL AUTO_INCREMENT,
  title VARCHAR(100) NOT NULL,
  genre VARCHAR(30) NOT NULL,
  language VARCHAR(20) NOT NULL,
  duration INT NOT NULL COMMENT 'Running time in minutes',
  CONSTRAINT pk_movies PRIMARY KEY (movie_id),
  CONSTRAINT chk_movie_duration CHECK (duration BETWEEN 60 AND 240)
) ENGINE=InnoDB;

CREATE TABLE shows (
  show_id INT NOT NULL AUTO_INCREMENT,
  movie_id INT NOT NULL,
  screen_number INT NOT NULL,
  show_datetime DATETIME NOT NULL,
  ticket_price DECIMAL(10,2) NOT NULL COMMENT 'Base price per regular seat, INR',
  CONSTRAINT pk_shows PRIMARY KEY (show_id),
  CONSTRAINT fk_shows_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
  CONSTRAINT chk_show_screen CHECK (screen_number BETWEEN 1 AND 3),
  CONSTRAINT chk_show_price CHECK (ticket_price > 0)
) ENGINE=InnoDB;

CREATE TABLE customers (
  customer_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  email VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  CONSTRAINT pk_customers PRIMARY KEY (customer_id),
  CONSTRAINT uq_customer_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE bookings (
  booking_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  show_id INT NOT NULL,
  booking_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'Confirmed',
  CONSTRAINT pk_bookings PRIMARY KEY (booking_id),
  CONSTRAINT fk_bookings_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_bookings_show FOREIGN KEY (show_id) REFERENCES shows(show_id),
  CONSTRAINT chk_booking_status CHECK (status IN ('Confirmed', 'Cancelled'))
) ENGINE=InnoDB;

CREATE TABLE tickets (
  ticket_id INT NOT NULL AUTO_INCREMENT,
  booking_id INT NOT NULL,
  seat_number VARCHAR(3) NOT NULL,
  price_paid DECIMAL(10,2) NOT NULL COMMENT 'Original ticket amount after discounts, INR',
  CONSTRAINT pk_tickets PRIMARY KEY (ticket_id),
  CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  CONSTRAINT uq_booking_seat UNIQUE (booking_id, seat_number),
  CONSTRAINT chk_ticket_seat CHECK (seat_number REGEXP '^[A-J](0[1-9]|1[0-2])$'),
  CONSTRAINT chk_ticket_price CHECK (price_paid > 0)
) ENGINE=InnoDB;

SHOW TABLES;
DESCRIBE movies;
DESCRIBE shows;
DESCRIBE customers;
DESCRIBE bookings;
DESCRIBE tickets;
SHOW CREATE TABLE bookings;

-- imported csv into tables

select count(*) from customers;
select * from movies;
select count(*) from bookings;
select count(*) from tickets;
select count(*) from shows;

SELECT status, COUNT(*) AS bookings FROM bookings GROUP BY status ORDER BY status;

SELECT COUNT(*) AS invalid_tickets
FROM tickets t LEFT JOIN bookings b ON b.booking_id = t.booking_id
WHERE b.booking_id IS NULL;

SELECT COUNT(*) AS confirmed_tickets, SUM(t.price_paid) AS net_ticket_revenue_inr
FROM tickets t JOIN bookings b ON b.booking_id = t.booking_id
WHERE b.status = 'Confirmed';

SELECT DISTINCT genre FROM movies ORDER BY genre;

SELECT movie_id, title, genre, language FROM movies WHERE language = 'Hindi';
SELECT title AS movie_title, duration AS duration_minutes
FROM movies ORDER BY duration desc LIMIT 5;
SELECT title, genre FROM movies WHERE genre = 'Comedy' OR genre = 'Animation';
SELECT title, genre FROM movies WHERE NOT genre = 'Horror';
SELECT customer_id, name FROM customers WHERE name LIKE 'S%' ORDER BY customer_id LIMIT 10;
SELECT title FROM movies WHERE title LIKE '%Stars';
SELECT show_id, ticket_price FROM shows
WHERE ticket_price BETWEEN 200 AND 250 ORDER BY show_id LIMIT 10;
SELECT show_id, show_datetime FROM shows
WHERE show_datetime >= '2026-07-01' AND show_datetime < '2026-08-01'
ORDER BY show_datetime, show_id LIMIT 10;
SELECT customer_id, UPPER(name) AS uppercase_name, LOWER(email) AS lowercase_email,
CONCAT('Customer: ', name) AS customer_label,
CHAR_LENGTH(name) AS name_length, SUBSTRING(name, 1, 5) AS first_five_characters,
REPLACE(name, ' ', '_') AS username_label, TRIM('  SQL Project  ') AS trimmed_text
FROM customers ORDER BY customer_id LIMIT 5;

INSERT INTO customers (name, email, phone)
VALUES ('Harsh Mehta', 'horsebhai@rmsi.com', '9087654389');
SET @demo_customer_id = LAST_INSERT_ID();
SELECT customer_id, name, email FROM customers WHERE customer_id = @demo_customer_id;
UPDATE customers SET name = 'Sudeep Sarkar' where name = 'Harsh Mehta';
select * from customers where customer_id=301;

DELETE FROM customers WHERE customer_id = @demo_customer_id;
ROLLBACK;
SELECT COUNT(*) AS demo_customer_remaining FROM customers WHERE customer_id = @demo_customer_id;
CREATE TABLE notes (
  note_id INT AUTO_INCREMENT PRIMARY KEY,
  note_text VARCHAR(100) NULL,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
insert into notes(note_text) values('hi');
select * from notes;

ALTER TABLE notes ADD COLUMN category VARCHAR(20) NOT NULL DEFAULT 'Practice';
INSERT INTO notes (note_text) VALUES ('Committed demonstration note'), (NULL);
SELECT note_id, COALESCE(note_text, 'No note supplied') AS note_text, category, created_at
FROM notes ORDER BY note_id;
SELECT note_id FROM notes WHERE note_text IS NULL;
UPDATE notes SET category = 'Reviewed' WHERE note_id = 1;
select * from notes;
DELETE FROM notes WHERE note_id = 2;
rollback;
ALTER TABLE notes DROP COLUMN category;
desc notes;
TRUNCATE TABLE notes;
SELECT COUNT(*) AS notes_after_truncate FROM notes;
DROP TABLE notes;
commit;

-- Booking Demo

INSERT INTO movies (title, genre, language, duration)
VALUES ('SQL Demo Premiere', 'Drama', 'Hindi', 120);
SET @demo_movie_id = LAST_INSERT_ID();
INSERT INTO shows (movie_id, screen_number, show_datetime, ticket_price)
VALUES (@demo_movie_id, 1, TIMESTAMP(DATE(NOW() + INTERVAL 7 DAY), '18:30:00'), 220.00);
SET @demo_show_id = LAST_INSERT_ID();
SELECT @demo_movie_id AS demo_movie_id, @demo_show_id AS demo_show_id;
SELECT * FROM shows WHERE show_id = @demo_show_id;
select * from bookings;
insert into bookings values(1001,58,181,'2026-12-03 16:55:00','Confirmed');
SELECT 'movies' AS table_name, COUNT(*) AS row_count FROM movies
UNION ALL SELECT 'shows', COUNT(*) FROM shows
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'tickets', COUNT(*) FROM tickets;
select count(*) from bookings where status = 'Cancelled';
SELECT COUNT(*) AS active_seats
FROM bookings b
INNER JOIN shows s
    ON b.show_id = s.show_id
WHERE b.status = 'Confirmed'
AND s.show_datetime > NOW();
SELECT SUM(t.price_paid) AS revenue_inr FROM tickets t JOIN bookings b ON b.booking_id = t.booking_id
WHERE b.status = 'Confirmed';