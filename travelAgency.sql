DROP VIEW IF EXISTS payment_pending, client_list, transport_list, happy_customers, top_spenders, best_rated_trips, revenue_per_destination, clients_with_reservation_or_review, clients_without_reservation, most_expensive_trip_per_destination;
DROP SEQUENCE accommodation_id_seq, client_id_seq, destination_id_seq, payment_id_seq, reservation_id_seq, review_id_seq, transport_id_seq, trip_id_seq;

--odstránenie tabuliek a enum mnozin
DROP TABLE IF EXISTS
review,
trip_accommodation,
accommodation,
trip_transport,
transport,
payment,
reservation,
trip,
destination,
client;

DROP TYPE trip_status;
DROP TYPE reservation_status;
DROP TYPE payment_status;
DROP TYPE payment_method;
DROP TYPE transport_type;
DROP TYPE accommodation_type;

-- vlastné enum množiny
CREATE TYPE trip_status AS ENUM ('available', 'not available');
CREATE TYPE reservation_status AS ENUM ('pending', 'confirmed', 'cancelled', 'paid');
CREATE TYPE payment_status  AS ENUM ('completed', 'refunded', 'pending');
CREATE TYPE payment_method AS ENUM ('card', 'bank_transfer');
CREATE TYPE transport_type AS ENUM ('plane', 'bus', 'train', 'own', 'ship');
CREATE TYPE accommodation_type AS ENUM ('hotel', 'hostel', 'apartment', 'resort', 'motel', 'campsite', 'villa');

-- Tabuľka klientov
CREATE TABLE client (
    client_id  INT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(16) NOT NULL
);

-- Tabuľka destinácií
CREATE TABLE destination (
    destination_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    region VARCHAR(50),
    description TEXT
);

-- Tabuľka zájazdov
CREATE TABLE trip (
    trip_id INT PRIMARY KEY,
    destination_id INT NOT NULL REFERENCES destination(destination_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'EUR',
    capacity INT NOT NULL,
    status trip_status DEFAULT 'available'
);

-- Tabuľka rezervácií
CREATE TABLE reservation (
    reservation_id INT PRIMARY KEY,
    client_id INT NOT NULL REFERENCES client(client_id) ON DELETE CASCADE,
    trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE,
    number_of_people INT NOT NULL,
    reservation_date TIMESTAMP NOT NULL DEFAULT NOW(),
    total_price NUMERIC(10,2),
    status reservation_status DEFAULT 'pending',
    notes TEXT
);

-- Tabuľka platieb
CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES reservation(reservation_id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    payment_method payment_method,
    payment_status payment_status DEFAULT 'pending'
);

-- Tabuľka dopravných prostriedkov
CREATE TABLE transport (
    transport_id INT PRIMARY KEY,
    type transport_type NOT NULL,
    company VARCHAR(50) NOT NULL,
    transport_number VARCHAR(20) NOT NULL UNIQUE,
    departure_datetime TIMESTAMP NOT NULL,
    arrival_datetime TIMESTAMP NOT NULL,
    departure_location VARCHAR(100),
    arrival_location VARCHAR(100)
);

-- M:N vzťah medzi zájazdom a dopravným prostriedkom
CREATE TABLE trip_transport (
    trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE,
    transport_id INT NOT NULL REFERENCES transport(transport_id) ON DELETE CASCADE,
    PRIMARY KEY (trip_id, transport_id)
);

-- Tabuľka ubytovaní
CREATE TABLE accommodation (
    accommodation_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    price_per_night NUMERIC(10,2) NOT NULL,
    type accommodation_type,
    capacity INT,
    rating INT CHECK (rating BETWEEN 1 AND 5)
);

-- M:N vzťah medzi zájazdom a ubytovaním
CREATE TABLE trip_accommodation (
    trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE,
    accommodation_id INT NOT NULL REFERENCES accommodation(accommodation_id) ON DELETE CASCADE,
    PRIMARY KEY (trip_id, accommodation_id)
);

-- Tabuľka recenzií
CREATE TABLE review (
    review_id INT PRIMARY KEY,
    client_id INT NOT NULL REFERENCES client(client_id) ON DELETE CASCADE,
    trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ====== TRIGGERS ======

-- CLIENT
CREATE SEQUENCE client_id_seq START 1;

CREATE OR REPLACE FUNCTION set_client_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.client_id IS NULL THEN
        NEW.client_id := nextval('client_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_client_id
    BEFORE INSERT ON client
    FOR EACH ROW
EXECUTE FUNCTION set_client_id();

-- DESTINATION
CREATE SEQUENCE destination_id_seq START 1;

CREATE OR REPLACE FUNCTION set_destination_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.destination_id IS NULL THEN
        NEW.destination_id := nextval('destination_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_destination_id
    BEFORE INSERT ON destination
    FOR EACH ROW
EXECUTE FUNCTION set_destination_id();

-- TRIP
CREATE SEQUENCE trip_id_seq START 1;

CREATE OR REPLACE FUNCTION set_trip_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.trip_id IS NULL THEN
        NEW.trip_id := nextval('trip_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_trip_id
    BEFORE INSERT ON trip
    FOR EACH ROW
EXECUTE FUNCTION set_trip_id();

-- RESERVATION
CREATE SEQUENCE reservation_id_seq START 1;

CREATE OR REPLACE FUNCTION set_reservation_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_id IS NULL THEN
        NEW.reservation_id := nextval('reservation_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_reservation_id
    BEFORE INSERT ON reservation
    FOR EACH ROW
EXECUTE FUNCTION set_reservation_id();

-- PAYMENT
CREATE SEQUENCE payment_id_seq START 1;

CREATE OR REPLACE FUNCTION set_payment_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_id IS NULL THEN
        NEW.payment_id := nextval('payment_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_payment_id
    BEFORE INSERT ON payment
    FOR EACH ROW
EXECUTE FUNCTION set_payment_id();

-- TRANSPORT
CREATE SEQUENCE transport_id_seq START 1;

CREATE OR REPLACE FUNCTION set_transport_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transport_id IS NULL THEN
        NEW.transport_id := nextval('transport_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_transport_id
    BEFORE INSERT ON transport
    FOR EACH ROW
EXECUTE FUNCTION set_transport_id();

-- ACCOMMODATION
CREATE SEQUENCE accommodation_id_seq START 1;

CREATE OR REPLACE FUNCTION set_accommodation_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.accommodation_id IS NULL THEN
        NEW.accommodation_id := nextval('accommodation_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_accommodation_id
    BEFORE INSERT ON accommodation
    FOR EACH ROW
EXECUTE FUNCTION set_accommodation_id();

-- REVIEW
CREATE SEQUENCE review_id_seq START 1;

CREATE OR REPLACE FUNCTION set_review_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.review_id IS NULL THEN
        NEW.review_id := nextval('review_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_review_id
    BEFORE INSERT ON review
    FOR EACH ROW
EXECUTE FUNCTION set_review_id();

-- automaticke nastavenie ceny pri vkladani rezervacie
CREATE OR REPLACE FUNCTION set_total_price_for_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    SELECT t.price INTO STRICT NEW.total_price
    FROM trip t
    WHERE t.trip_id = NEW.trip_id;

    NEW.total_price := NEW.total_price * NEW.number_of_people;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_total_price
    BEFORE INSERT ON reservation
    FOR EACH ROW
EXECUTE FUNCTION set_total_price_for_reservation();




INSERT INTO client (first_name, last_name, email, phone) VALUES
('Kelly', 'Gibson', 'johnlarson@azet.sk', '+421 908 425 408'),
('Michael', 'Mann', 'beckerteresa@centrum.sk', '+421 938 395 719'),
('Jennifer', 'Jordan', 'dbrown@atlas.sk', '+421 934 942 415'),
('Jason', 'Gonzalez', 'johnsontommy@centrum.sk', '+421 910 760 145'),
('Tyler', 'Aguilar', 'fnorman@chello.sk', '+421 911 371 447'),
('Charles', 'Parrish', 'waltonalexis@pobox.sk', '+421 951 590 412'),
('Susan', 'Evans', 'angelica39@gmail.com', '+421 931 939 181'),
('Wendy', 'Jenkins', 'smueller@zoznam.sk', '+421 938 979 358'),
('Erica', 'Macias', 'wallaceamanda@chello.sk', '+421 931 727 922'),
('Megan', 'Cervantes', 'nichole68@chello.sk', '+421 979 418 638');

INSERT INTO destination (name, country, region, description) VALUES
('Bratislava', 'Slovensko', 'Bratislavský kraj', 'Hlavné mesto Slovenska s bohatou históriou.'),
('Košice', 'Slovensko', 'Košický kraj', 'Druhé najväčšie mesto Slovenska s gotickou katedrálou.'),
('Viedeň', 'Rakúsko', 'Dolné Rakúsko', 'Hlavné mesto Rakúska, známe kultúrou a hudbou.'),
('Praha', 'Česko', 'Stredné Čechy', 'Historické hlavné mesto Českej republiky s Karlovým mostom.'),
('Budapešť', 'Maďarsko', 'Stredné Maďarsko', 'Hlavné mesto Maďarska s krásnymi kúpeľmi a Dunajom.'),
('Krakov', 'Poľsko', 'Malopoľské vojvodstvo', 'Historické mesto s kráľovským hradom Wawel.'),
('Brno', 'Česko', 'Juhomoravský kraj', 'Druhé najväčšie mesto Česka s modernou architektúrou.'),
('Salzburg', 'Rakúsko', 'Salzbursko', 'Mesto známe ako rodisko Mozarta a jeho barokovou architektúrou.'),
('Eger', 'Maďarsko', 'Severné Maďarsko', 'Historické mesto známe termálnymi kúpeľmi a vínom.'),
('Zakopané', 'Poľsko', 'Malopoľské vojvodstvo', 'Horské mesto pod Tatrami, obľúbené na lyžovanie.');

INSERT INTO trip (destination_id, start_date, end_date, price, currency, capacity, status) VALUES
(9,  '10-OCT-2024', '17-OCT-2024',  307.33, 'EUR', 48, 'available'),
(10, '26-DEC-2024', '29-DEC-2024', 1023.33, 'EUR', 49, 'available'),
(4,  '18-MAR-2024', '21-MAR-2024',  719.11, 'EUR', 28, 'available'),
(7,  '01-OCT-2024', '05-OCT-2024', 1162.66, 'EUR', 23, 'available'),
(2,  '18-JAN-2025', '22-JAN-2025',  143.54, 'EUR', 18, 'available'),
(9,  '12-FEB-2025', '26-FEB-2025', 1288.34, 'EUR', 34, 'available'),
(3,  '05-MAY-2024', '14-MAY-2024', 1388.43, 'EUR', 33, 'available'),
(5,  '05-AUG-2024', '13-AUG-2024',  414.45, 'EUR', 44, 'available'),
(8,  '22-FEB-2025', '27-FEB-2025',  782.01, 'EUR', 50, 'available'),
(10, '01-DEC-2024', '12-DEC-2024', 1132.73, 'EUR', 40, 'available');


INSERT INTO reservation (client_id, trip_id, number_of_people, reservation_date, status, notes) VALUES
(4, 6, 1, '2025-01-02 19:00:02',  'paid', 'Zaplatená celá sume predom'),
(9, 2, 3, '2025-01-15 03:23:50',  'confirmed', 'Záloha už bola uhradená'),
(1, 9, 1, '2025-02-16 03:57:11',  'paid', 'Zaplatená celá suma'),
(1, 7, 5, '2025-01-27 18:07:08', 'paid', 'Zaplatená celá suma'),
(7, 8, 5, '2025-02-06 16:14:42',  'pending', 'Očakávaná posledná splátka'),
(4, 8, 4, '2025-01-21 05:45:56',  'paid', 'Zaplatená celá sume predom'),
(2, 6, 4, '2025-01-15 08:40:48',  'cancelled', 'Rezervácia bola zrušená bez udania dôvodu do 24h'),
(10, 4, 1, '2025-01-14 20:28:23', 'confirmed', 'Platba v hotovosti 23.4.25'),
(6, 2, 3, '2025-02-15 05:58:39',  'cancelled', 'Rezervácia zrušená týždeň pred odchodom(účtovanie 50% zo sumy)'),
(9, 3, 2, '2025-02-10 05:40:51',  'pending', 'Peniaze boli odoslané z účtu zákazníka');


INSERT INTO payment (reservation_id, amount, payment_date, payment_method, payment_status) VALUES
(8, 417.19, '2025-01-10 21:16:20', 'bank_transfer', 'pending'),
(8, 1935.89, '2025-01-24 13:24:25', 'bank_transfer', 'completed'),
(10, 923.68, '2025-02-04 22:07:55', 'card', 'completed'),
(3, 1034.07, '2025-01-06 03:36:01', 'card', 'pending'),
(1, 1278.49, '2025-02-10 10:58:26', 'card', 'pending'),
(4, 710.92, '2025-02-28 04:01:15', 'bank_transfer', 'completed'),
(1, 1470.58, '2025-01-02 19:05:08', 'bank_transfer', 'pending'),
(1, 1819.34, '2025-01-21 22:58:26', 'bank_transfer', 'pending'),
(10, 626.67, '2025-01-21 09:55:52', 'bank_transfer', 'completed'),
(3, 543.63, '2025-01-04 17:46:39', 'bank_transfer', 'refunded');

INSERT INTO transport (type, company, transport_number, departure_datetime, arrival_datetime, departure_location, arrival_location) VALUES
('own', 'Brooks', 'WYFsN-14825', '2025-03-02 10:02:31', '2025-03-02 19:02:31', 'Kamenica nad Cirochou', 'Predajná'),
('plane', 'Mullins Hoffman k.s.', 'luXsF-05391', '2025-02-16 23:10:21', '2025-02-17 06:10:21', 'Medovarce', 'Ľuboreč'),
('bus', 'Taylor k.s.', 'UuGLC-18672', '2025-02-08 23:56:53', '2025-02-09 00:56:53', 'Lopašov', 'Keť'),
('train', 'Kirby s.r.o.', 'YXRcU-08340', '2025-01-03 23:25:06', '2025-01-04 02:25:06', 'Slančík', 'Rovensko'),
('plane', 'Dorsey Arnold k.s.', 'AJYYN-34597', '2025-01-22 02:35:22', '2025-01-22 03:35:22', 'Legnava', 'Podolie'),
('bus', 'Tyler', 'VEmYk-81127', '2025-02-05 15:55:10', '2025-02-06 00:55:10', 'Bojničky', 'Suchá Dolina'),
('train', 'Ellis', 'hMPJj-29663', '2025-01-22 10:13:51', '2025-01-22 16:13:51', 'Turčiansky Ďur', 'Lipové'),
('train', 'Anderson', 'QbDYZ-23576', '2025-02-20 18:20:45', '2025-02-21 03:20:45', 'Vozokany', 'Tepličky'),
('ship', 'Gonzalez', 'MoiVz-29385', '2025-01-31 12:22:22', '2025-01-31 15:22:22', 'Vislanka', 'Krásnohorské Podhradie'),
('train', 'Carr', 'jXeWv-12853', '2025-01-23 15:54:40', '2025-01-23 23:54:40', 'Vavrinec', 'Dolný Harmanec');

INSERT INTO trip_transport (trip_id, transport_id) VALUES
(1, 1),
(1, 3),
(2, 2),
(2, 4),
(3, 5),
(3, 7),
(4, 6),
(4, 8),
(5, 9),
(5, 10),
(6, 1),
(6, 2),
(7, 3),
(7, 5),
(8, 4),
(8, 6),
(9, 7),
(9, 9),
(10, 8),
(10, 10);


INSERT INTO accommodation (name, address, price_per_night, type, capacity, rating) VALUES
('Harris', 'Bottova 1094 35 Tehla', 109.51, 'motel', 29, 4),
('Crawford Johnson k.s.', 'Májkova 5021 51 Udiča', 185.66, 'hotel', 5, 4),
('Griffin v.o.s.', 'Búdkova cesta 937969 08 Horný Hričov', 84.36, 'campsite', 5, 5),
('Morgan k.s.', 'Vetvárska 80823 82 Harichovce', 123.02, 'motel', 16, 3),
('Shaffer Munoz v.o.s.', 'Belehradská 92966 30 Smrečany', 36.51, 'motel', 93, 4),
('Rice', 'Mošovského 582825 91 Lipníky', 207.91, 'apartment', 32, 5),
('Lee Phillips s.r.o.', 'Sreznevského 6879 07 Tarnov', 110.76, 'hotel', 16, 1),
('Murphy', 'Turnianska 5954 34 Iňačovce', 53.01, 'hostel', 95, 1),
('Singh', 'Suchohradská 8804 20 Šarovce', 179.8, 'apartment', 26, 3),
('Maddox', 'Klenová 980875 10 Hrišovce', 60.25, 'campsite', 59, 4);

INSERT INTO trip_accommodation (trip_id, accommodation_id) VALUES
(1, 2),
(1, 5),
(2, 3),
(2, 6),
(3, 1),
(3, 7),
(4, 4),
(4, 8),
(5, 2),
(5, 9),
(6, 5),
(6, 10),
(7, 6),
(7, 1),
(8, 3),
(8, 7),
(9, 2),
(9, 4),
(10, 5),
(10, 8);


INSERT INTO review (client_id, trip_id, rating, comment, review_date) VALUES
(2, 9, 2, 'Asperiores itaque inventore nulla atque deserunt.', '2025-02-11 15:11:15'),
(9, 6, 4, 'Ad laudantium odit tenetur blanditiis quam.', '2025-02-17 04:00:19'),
(9, 1, 1, 'Explicabo eligendi fugit dolorum ducimus.', '2025-02-07 08:39:52'),
(10, 1, 2, 'Animi voluptas ipsum ipsam.', '2025-02-11 05:09:48'),
(4, 5, 4, 'Dolorem animi laboriosam sapiente itaque.', '2025-02-12 08:27:30'),
(1, 1, 4, 'Quasi commodi qui ullam cum ex.', '2025-02-14 02:15:01'),
(3, 8, 2, 'Amet quas cupiditate alias ratione.', '2025-01-30 13:08:00'),
(1, 7, 2, 'Magnam aut ad. Delectus in perspiciatis nemo.', '2025-03-03 11:33:52'),
(5, 10, 3, 'At ex corporis tempore a.', '2025-01-08 05:41:17'),
(10, 5, 5, 'Fugit est error eveniet atque dignissimos.', '2025-01-12 02:00:39');


-- vypise vsetkych klientov, ktorych meno je Michael alebo priezvisko Gonzalez
CREATE VIEW client_list AS
    SELECT client_id, first_name, last_name, phone, email
FROM client WHERE first_name = 'Michael' OR last_name = 'Gonzalez';

-- vypise vsetkych klientov, ktory cestuju vlakom
CREATE VIEW transport_list AS
    SELECT
        transport_id, type AS transport_type, company, transport_number,
        departure_datetime, arrival_datetime, departure_location, arrival_location
FROM transport WHERE type = 'train';

-- vypise vsetkych klientov, ktorych platba nebola zrealizovana
CREATE VIEW payment_pending AS
    SELECT
        c.first_name, c.last_name,
        p.amount, p.payment_date, p.payment_method, p.payment_status
FROM client c
    JOIN reservation r ON c.client_id = r.client_id
    JOIN payment p ON r.reservation_id = p.reservation_id
WHERE p.payment_status = 'pending' ORDER BY p.payment_date DESC;

-- vypise zakaznikov, ktory ohodnotili vylet minimalne s hodnotou 4
CREATE VIEW happy_customers AS
    SELECT DISTINCT ON (c.client_id)
        c.first_name, c.last_name,
        r.comment,
        a.name,
        t.type, t.company
FROM client c
    JOIN review r ON c.client_id = r.client_id
    JOIN trip x on r.trip_id = x.trip_id
    JOIN trip_accommodation ta on x.trip_id = ta.trip_id
    JOIN trip_transport tt on x.trip_id = tt.trip_id
    JOIN accommodation a on ta.accommodation_id = a.accommodation_id
    JOIN transport t on tt.transport_id = t.transport_id
WHERE r.rating >= 4;

-- vypise klientov, ktory minuly najviac penazi zoradenych od najvacsej sumy
CREATE VIEW top_spenders AS
SELECT
    c.first_name, c.last_name,
    SUM(p.amount) AS total_spent,
    COUNT(p.payment_id) AS total_payments
FROM client c
         JOIN reservation r ON c.client_id = r.client_id
         JOIN payment p ON r.reservation_id = p.reservation_id
WHERE p.payment_status = 'completed'
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- vypise top 5 hodnotenych zajazdov
CREATE VIEW best_rated_trips AS
SELECT
    t.trip_id,
    d.name AS destination_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM review r
         JOIN trip t ON r.trip_id = t.trip_id
         JOIN destination d ON t.destination_id = d.destination_id
GROUP BY t.trip_id, d.name
HAVING COUNT(r.review_id) > 0
ORDER BY avg_rating DESC, total_reviews DESC LIMIT 5;

-- vypise, kolko zarobil jednotliv vylet
CREATE VIEW revenue_per_destination AS
SELECT
    d.name AS destination_name,
    COALESCE(SUM(r.total_price), 0) AS total_revenue,
    CASE
        WHEN COALESCE(SUM(r.total_price), 0) >= 5000 THEN 'Nadpriemer'
        WHEN COALESCE(SUM(r.total_price), 0) >= 500 THEN 'Priemer'
        ELSE 'Podpriemer'
        END AS revenue_category
FROM destination d
         FULL OUTER JOIN trip t ON d.destination_id = t.destination_id
         FULL OUTER JOIN reservation r ON t.trip_id = r.trip_id AND r.status = 'paid'
GROUP BY d.destination_id, d.name
ORDER BY total_revenue DESC;

-- final odovzdavka

-- klienti, ktorí buď spravili rezerváciu alebo napísali recenziu
CREATE OR REPLACE VIEW clients_with_reservation_or_review AS
SELECT DISTINCT c.client_id, c.first_name, c.last_name, 'reservation' AS activity
FROM client c
WHERE c.client_id IN (SELECT r.client_id FROM reservation r)

UNION

SELECT DISTINCT c.client_id, c.first_name, c.last_name, 'review' AS activity
FROM client c
WHERE c.client_id IN (SELECT rv.client_id FROM review rv);

-- klienti, ktorí nemajú žiadnu rezerváciu
CREATE OR REPLACE VIEW clients_without_reservation AS
SELECT c.client_id, c.first_name, c.last_name
FROM client c
WHERE NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.client_id = c.client_id
);

-- najdrahší zájazd pre každú destináciu
CREATE OR REPLACE VIEW most_expensive_trip_per_destination AS
SELECT t.trip_id, t.destination_id, t.price
FROM trip t
WHERE t.price = (
    SELECT MAX(t2.price)
    FROM trip t2
    WHERE t2.destination_id = t.destination_id
);

CREATE OR REPLACE FUNCTION insert_into_client_view()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.activity = 'reservation' THEN
        -- Vložíme rezerváciu s 1 osobou a výplňovými hodnotami
        INSERT INTO reservation (client_id, trip_id, number_of_people)
        VALUES (NEW.client_id, 1, 1);  -- trip_id musíš nahradiť platným ID alebo získať inak

    ELSIF NEW.activity = 'review' THEN
        -- Vložíme recenziu s výplňovými údajmi
        INSERT INTO review (client_id, trip_id, rating)
        VALUES (NEW.client_id, 1, 5); -- opäť trip_id treba získať reálne

    ELSE
        RAISE EXCEPTION 'Neznáma aktivita: %', NEW.activity;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_into_client_view
    INSTEAD OF INSERT ON clients_with_reservation_or_review
    FOR EACH ROW
EXECUTE FUNCTION insert_into_client_view();


-- storovana procedura
CREATE OR REPLACE PROCEDURE make_reservation(
    p_client_id INT,
    p_trip_id INT,
    p_number_of_people INT,
    p_notes TEXT DEFAULT NULL
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC(10,2);
    v_total NUMERIC(10,2);
BEGIN
    -- Získaj cenu zájazdu
    SELECT price INTO v_price
    FROM trip
    WHERE trip_id = p_trip_id;

    -- Vypočítaj celkovú cenu
    v_total := v_price * p_number_of_people;

    -- Vlož rezerváciu
    INSERT INTO reservation (client_id, trip_id, number_of_people, total_price, notes)
    VALUES (p_client_id, p_trip_id, p_number_of_people, v_total, p_notes);
END;
$$;

-- funkcia vrati hodnotenie
CREATE OR REPLACE FUNCTION get_avg_rating_for_trip(p_trip_id INT)
    RETURNS NUMERIC(3,2)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_avg NUMERIC(3,2);
BEGIN
    SELECT AVG(rating)::NUMERIC(3,2)
    INTO v_avg
    FROM review
    WHERE trip_id = p_trip_id;

    RETURN COALESCE(v_avg, 0.00);  -- ak nie sú recenzie, vráť 0.00
END;
$$;

-- ****TESTOVACIA SEKCIA****

CALL make_reservation(2, 7, 4);

-- ODSTRANENIE UDAJOV PRED TESTOVANIM
TRUNCATE TABLE
    review,
    trip_accommodation,
    trip_transport,
    accommodation,
    transport,
    payment,
    reservation,
    trip,
    destination,
    client
    RESTART IDENTITY CASCADE;


-- 1) TEST auto-inkrementácie
INSERT INTO client (first_name, last_name, email, phone)
VALUES ('Test', 'Sequence', 'seq@test.sk', '+421000000000');
-- Očakávame, že client_id bude pridelené sekvenciou:
SELECT * FROM client WHERE email = 'seq@test.sk';

-- 2) TEST triggera set_total_price_for_reservation
-- Vložíme rezerváciu na existujúci trip_id (napr. 1) s 2 osobami
INSERT INTO reservation (client_id, trip_id, number_of_people)
VALUES (1, 1, 2);
-- Trigger by mal pred vložením vypočítať total_price = cena_tripu * 2
SELECT reservation_id, client_id, trip_id, number_of_people, total_price
FROM reservation
WHERE reservation_date > now() - interval '1 minute';

-- 3) TEST INSTEAD OF triggera na view clients_with_reservation_or_review
-- Vložíme do view novú aktivitu „review“ (napr. klient_id = 3)
INSERT INTO clients_with_reservation_or_review (client_id, first_name, last_name, activity)
VALUES (3, 'Jennifer', 'Jordan', 'review');
-- Trigger by mal vytvoriť nový záznam v review, skontrolujeme ho:
SELECT * FROM review
WHERE client_id = 3 AND review_date > now() - interval '1 minute';

-- 4) TEST uloženej procedúry make_reservation
CALL make_reservation(2, 2, 3, 'Test procedure call');
-- Skontrolujeme, že pribudla rezervácia so správnym total_price
SELECT reservation_id, client_id, trip_id, number_of_people, total_price, notes
FROM reservation
WHERE client_id = 2 AND notes = 'Test procedure call';

-- 5) TEST funkcie get_avg_rating_for_trip
-- Najprv vložíme 2-3 testovacie recenzie na trip_id = 5
INSERT INTO review (client_id, trip_id, rating) VALUES (1,5,5),(2,5,4),(3,5,3);
-- Teraz zavoláme funkciu
SELECT get_avg_rating_for_trip(5) AS avg_rating;
-- Očakávame (5+4+3)/3 = 4.00

