-- Se selecciona la base de datos postgres
\c postgres

-- En caso de existir se eliminan las tabals en orden para evitar errores de FK
DROP TABLE IF EXISTS Car_Ownership;
DROP TABLE IF EXISTS Cars;
DROP TABLE IF EXISTS Models;
DROP TABLE IF EXISTS Makers;
DROP TABLE IF EXISTS Phone_Ownership;
DROP TABLE IF EXISTS Phones;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Countries;

-- Tabla para almacenar los paises en el sistema

CREATE TABLE Countries (
   ID SERIAL PRIMARY KEY,
   name varchar(40) NOT NULL,
   branch_amount int,
   phone_extension varchar(40) NOT NULL
);

-- Tabla para almacenar los usuarios

CREATE TABLE Users (
   ID SERIAL PRIMARY KEY,
   name varchar(40) NOT NULL,
   second_name varchar(40),
   age int NOT NULL,
   country_ID int NOT NULL,
   email varchar(40) NOT NULL,
   CONSTRAINT fk_UserCountry FOREIGN KEY (country_ID) REFERENCES Countries (ID) -- FK al pais al que pertenece el usuario
);

-- Tabla para almacenar numeros de telefono

CREATE TABLE Phones (
   ID SERIAL PRIMARY KEY,
   number varchar(40),
   country_ID int NOT NULL,
   CONSTRAINT fk_PhoneCountry FOREIGN KEY (country_ID) REFERENCES Countries (ID), -- FK al pais para mantener el formato numerico
   UNIQUE (number, country_ID) -- Hace que el numero sea unico
);

-- Tabla relacional entre telefono-usuario

CREATE TABLE Phone_Ownership (
   owner_ID int NOT NULL,
   number_ID int NOT NULL,
   CONSTRAINT fk_PhoneOwner FOREIGN KEY (owner_ID) REFERENCES Users (ID), -- FK al usuario
   CONSTRAINT fk_PhoneNumber FOREIGN KEY (number_ID) REFERENCES Phones (ID), -- FK al telegono
   PRIMARY KEY (owner_ID, number_ID)
);

-- Almacena fabricantes del vehiculo

CREATE TABLE Makers (
   ID SERIAL PRIMARY KEY,
   name varchar(40) NOT NULL UNIQUE
);

-- Almacena el modelo del vehiculo

CREATE TABLE Models (
   ID SERIAL PRIMARY KEY,
   maker_ID int NOT NULL,
   name varchar(40) NOT NULL UNIQUE,
   CONSTRAINT fk_ModelMaker FOREIGN KEY (maker_ID) REFERENCES Makers (ID) -- FK al modelador
);

-- Almacena los vehiculos

CREATE TABLE Cars (
   plate varchar(40) PRIMARY KEY,
   model_ID int NOT NULL,
   year int,
   country_ID int NOT NULL,
   CONSTRAINT fk_CarModel FOREIGN KEY (model_ID) REFERENCES Models (ID), -- FK al modelo
   CONSTRAINT fk_CarCountry FOREIGN KEY (country_ID) REFERENCES Countries (ID) -- FK al pais
);

-- Tabla relacional entre carro-usuario

CREATE TABLE Car_Ownership (
   owner_ID int NOT NULL,
   car_plate varchar(40) NOT NULL,
   CONSTRAINT fk_CarOwner FOREIGN KEY (owner_ID) REFERENCES Users (ID), -- FK al usuario
   CONSTRAINT fk_CarPlate FOREIGN KEY (car_plate) REFERENCES Cars (plate), -- FK al carro
   PRIMARY KEY (owner_ID, car_plate)
);




----------------------- Se introducen los datos -----------------------





INSERT INTO Countries (name, branch_amount, phone_extension)
VALUES
('Uzbekistan', 42, '998'),
('Kyrgyzstan', 17, '996'),
('Georgia', 63, '995'),
('Azerbaijan', 28, '994'),
('Turkmenistan', 55, '993'),
('Tajikistan', 34, '992'),
('Nepal', 88, '977'),
('Mongolia', 21, '976'),
('Bhutan', 73, '975'),
('Qatar', 19, '974'),
('Bahrain', 67, '973'),
('Israel', 45, '972'),
('Palestine', 52, '970'),
('United Arab Emirates', 90, '971'),
('Oman', 36, '968'),
('Yemen', 12, '967'),
('Saudi Arabia', 77, '966'),
('Kuwait', 25, '965'),
('Iraq', 61, '964'),
('Syria', 14, '963'),
('Jordan', 83, '962'),
('Lebanon', 39, '961'),
('Maldives', 58, '960'),

('Myanmar', 46, '95'),
('Sri Lanka', 72, '94'),
('Afghanistan', 31, '93'),
('Pakistan', 64, '92'),
('India', 99, '91'),
('Turkey', 53, '90'),

('Taiwan', 27, '886'),
('Bangladesh', 84, '880'),
('Liliput', 41, '876'),

('China', 93, '86'),
('Cambodia', 38, '855'),
('Laos', 22, '856'),
('Macau', 59, '853'),
('Hong Kong', 75, '852'),
('North Korea', 18, '850'),
('Vietnam', 66, '84'),
('South Korea', 81, '82'),
('Japan', 47, '81'),

('Russia', 70, '7'),
('Kazakhstan', 29, '7'),

('Marshall Islands', 13, '692'),
('Micronesia', 57, '691'),
('Tokelau', 24, '690'),
('French Polynesia', 91, '689'),
('Tuvalu', 44, '688'),
('New Caledonia', 62, '687'),
('Kiribati', 16, '686'),
('Samoa', 85, '685'),
('American Samoa', 33, '684'),
('Niue', 60, '683'),
('Cook Islands', 78, '682'),
('Wallis and Futuna', 26, '681'),
('Palau', 51, '680'),

('Fiji', 11, '679'),
('Vanuatu', 69, '678'),
('Solomon Islands', 35, '677'),
('Tonga', 87, '676'),
('Papua New Guinea', 20, '675'),
('Nauru', 49, '674'),
('Brunei', 94, '673'),
('Timor-Leste', 37, '670'),

('Thailand', 65, '66'),
('Singapore', 23, '65'),
('New Zealand', 76, '64'),
('Philippines', 40, '63'),
('Indonesia', 82, '62'),
('Australia', 96, '61'),
('Malaysia', 54, '60'),

('Curaçao', 32, '599'),
('Caribbean Netherlands', 71, '599'),
('Uruguay', 15, '598'),
('Suriname', 89, '597'),
('Martinique', 43, '596'),
('Paraguay', 68, '595'),
('French Guiana', 30, '594'),
('Ecuador', 97, '593'),
('Guyana', 56, '592'),
('Bolivia', 79, '591'),
('Guadeloupe', 48, '590'),
('Saint Martin', 74, '590'),
('Saint Barthélemy', 92, '590'),

('Venezuela', 50, '58'),
('Colombia', 86, '57'),
('Chile', 19, '56'),
('Brazil', 100, '55'),
('Argentina', 52, '54'),
('Cuba', 61, '53'),
('Mexico', 34, '52'),
('Peru', 80, '51'),

('Haiti', 21, '509'),
('Saint Pierre and Miquelon', 66, '508'),
('Panama', 39, '507'),
('Costa Rica', 88, '506'),
('Nicaragua', 27, '505'),
('Honduras', 72, '504'),
('El Salvador', 45, '503'),
('Guatemala', 83, '502'),
('Belize', 14, '501'),

('Germany', 58, '49'),
('Poland', 93, '48'),
('Norway', 25, '47'),
('Sweden', 64, '46'),
('Denmark', 11, '45'),
('United Kingdom', 77, '44'),
('Austria', 36, '43'),
('Switzerland', 90, '41'),
('Romania', 28, '40'),
('Italy', 69, '39'),
('Vatican City', 12, '39'),

('United States', 95, '1'),
('Canada', 53, '1'),
('Bahamas', 41, '1'),
('Barbados', 62, '1'),
('Jamaica', 17, '1'),
('Trinidad and Tobago', 74, '1'),
('Dominican Republic', 29, '1'),
('Puerto Rico', 85, '1');





INSERT INTO Makers (name) 
VALUES
('Toyota'),
('Volkswagen'),
('Ford'),
('Honda'),
('Chevrolet'),
('Mercedes-Benz'),
('BMW'),
('Audi'),
('Hyundai'),
('Nissan'),
('Kia'),
('Peugeot'),
('Renault'),
('Ferrari'),
('Lamborghini'),
('Porsche'),
('Mitsubishi'),
('Jaguar'),
('Land Rover'),
('Volvo'),
('Subaru'),
('Mazda'),
('Tesla'),
('Alfa Romeo'),
('Fiat'),
('Citroën'),
('Chrysler'),
('Dodge'),
('Jeep'),
('Bentley'),
('Rolls-Royce'),
('Aston Martin'),
('Bugatti'),
('McLaren'),
('Suzuki'),
('Maserati'),
('Seat'),
('Skoda'),
('Mini'),
('Infiniti'),
('Acura'),
('Cadillac'),
('Lincoln'),
('Ram'),
('Genesis'),
('Saab'),
('Opel');





INSERT INTO Models (maker_ID, name)
VALUES
-- 1 Toyota
(1, 'Corolla'),
(1, 'Camry'),
(1, 'RAV4'),

-- 2 Volkswagen
(2, 'Golf'),
(2, 'Passat'),
(2, 'Tiguan'),

-- 3 Ford
(3, 'F-150'),
(3, 'Mustang'),
(3, 'Explorer'),

-- 4 Honda
(4, 'Civic'),
(4, 'Accord'),
(4, 'CR-V'),

-- 5 Chevrolet
(5, 'Camaro'),
(5, 'Silverado'),
(5, 'Malibu'),

-- 6 Mercedes-Benz
(6, 'C-Class'),
(6, 'E-Class'),
(6, 'S-Class'),

-- 7 BMW
(7, '3 Series'),
(7, '5 Series'),
(7, 'X5'),

-- 8 Audi
(8, 'A3'),
(8, 'A4'),
(8, 'Q5'),

-- 9 Hyundai
(9, 'Elantra'),
(9, 'Sonata'),
(9, 'Tucson'),

-- 10 Nissan
(10, 'Altima'),
(10, 'Sentra'),
(10, 'Rogue'),

-- 11 Kia
(11, 'Rio'),
(11, 'Sportage'),
(11, 'Sorento'),

-- 12 Peugeot
(12, '208'),
(12, '308'),
(12, '3008'),

-- 13 Renault
(13, 'Clio'),
(13, 'Megane'),
(13, 'Captur'),

-- 14 Ferrari
(14, '488 GTB'),
(14, 'F8 Tributo'),
(14, 'Portofino'),

-- 15 Lamborghini
(15, 'Huracán'),
(15, 'Aventador'),
(15, 'Urus'),

-- 16 Porsche
(16, '911'),
(16, 'Cayenne'),
(16, 'Panamera'),

-- 17 Mitsubishi
(17, 'Lancer'),
(17, 'Outlander'),
(17, 'Pajero'),

-- 18 Jaguar
(18, 'XE'),
(18, 'XF'),
(18, 'F-PACE'),

-- 19 Land Rover
(19, 'Range Rover'),
(19, 'Discovery'),
(19, 'Defender'),

-- 20 Volvo
(20, 'XC90'),
(20, 'XC60'),
(20, 'S60'),

-- 21 Subaru
(21, 'Impreza'),
(21, 'Forester'),
(21, 'Outback'),

-- 22 Mazda
(22, 'Mazda3'),
(22, 'Mazda6'),
(22, 'CX-5'),

-- 23 Tesla
(23, 'Model S'),
(23, 'Model 3'),
(23, 'Model X'),

-- 24 Alfa Romeo
(24, 'Giulia'),
(24, 'Stelvio'),
(24, '4C'),

-- 25 Fiat
(25, '500'),
(25, 'Panda'),
(25, 'Punto'),

-- 26 Citroën
(26, 'C3'),
(26, 'C4'),
(26, 'C5 Aircross'),

-- 27 Chrysler
(27, '300'),
(27, 'Pacifica'),
(27, 'Voyager'),

-- 28 Dodge
(28, 'Challenger'),
(28, 'Charger'),
(28, 'Durango'),

-- 29 Jeep
(29, 'Wrangler'),
(29, 'Grand Cherokee'),
(29, 'Renegade'),

-- 30 Bentley
(30, 'Continental GT'),
(30, 'Flying Spur'),
(30, 'Bentayga'),

-- 31 Rolls-Royce
(31, 'Phantom'),
(31, 'Ghost'),
(31, 'Cullinan'),

-- 32 Aston Martin
(32, 'DB11'),
(32, 'Vantage'),
(32, 'DBX'),

-- 33 Bugatti
(33, 'Chiron'),
(33, 'Veyron'),
(33, 'Divo'),

-- 34 McLaren
(34, '720S'),
(34, 'GT'),
(34, 'P1'),

-- 35 Suzuki
(35, 'Swift'),
(35, 'Vitara'),
(35, 'Jimny'),

-- 36 Maserati
(36, 'Ghibli'),
(36, 'Quattroporte'),
(36, 'Levante'),

-- 37 Seat
(37, 'Ibiza'),
(37, 'Leon'),
(37, 'Ateca'),

-- 38 Skoda
(38, 'Octavia'),
(38, 'Superb'),
(38, 'Kodiaq'),

-- 39 Mini
(39, 'Cooper'),
(39, 'Countryman'),
(39, 'Clubman'),

-- 40 Infiniti
(40, 'Q50'),
(40, 'Q60'),
(40, 'QX50'),

-- 41 Acura
(41, 'TLX'),
(41, 'MDX'),
(41, 'RDX'),

-- 42 Cadillac
(42, 'Escalade'),
(42, 'CTS'),
(42, 'XT5'),

-- 43 Lincoln
(43, 'Navigator'),
(43, 'MKZ'),
(43, 'Corsair'),

-- 44 Ram
(44, '1500'),
(44, '2500'),
(44, '3500'),

-- 45 Genesis
(45, 'G70'),
(45, 'G80'),
(45, 'GV80'),

-- 46 Saab
(46, '9-3'),
(46, '9-5'),
(46, '9-4X'),

-- 47 Opel
(47, 'Astra'),
(47, 'Corsa'),
(47, 'Insignia');





INSERT INTO Users (name, second_name, age, country_ID, email) 
VALUES
('Liam', 'Anderson', 34, 12, 'liam.anderson34@gmail.com'),
('Emma', 'Martinez', 27, 45, 'emma.martinez27@yahoo.com'),
('Noah', 'Thompson', 52, 78, 'noah.thompson52@outlook.com'),
('Olivia', 'Garcia', 19, 33, 'olivia.garcia19@gmail.com'),
('Ava', 'Hernandez', 41, 67, 'ava.hernandez41@hotmail.com'),
('Elijah', 'Lopez', 63, 21, 'elijah.lopez63@yahoo.com'),
('Sophia', 'Gonzalez', 25, 89, 'sophia.gonzalez25@gmail.com'),
('James', 'Wilson', 70, 54, 'james.wilson70@outlook.com'),
('Isabella', 'Moore', 31, 10, 'isabella.moore31@gmail.com'),
('Benjamin', 'Taylor', 44, 95, 'benjamin.taylor44@yahoo.com'),
('Mia', 'Anderson', 12, 102, 'mia.anderson12@gmail.com'),
('Lucas', 'Thomas', 58, 6, 'lucas.thomas58@hotmail.com'),
('Charlotte', 'Jackson', 23, 17, 'charlotte.jackson23@gmail.com'),
('Henry', 'White', 36, 60, 'henry.white36@yahoo.com'),
('Amelia', 'Harris', 29, 48, 'amelia.harris29@gmail.com'),
('Alexander', 'Martin', 65, 111, 'alexander.martin65@outlook.com'),
('Evelyn', 'Lee', 40, 73, 'evelyn.lee40@gmail.com'),
('Daniel', 'Perez', 51, 39, 'daniel.perez51@yahoo.com'),
('Harper', 'Clark', 7, 82, 'harper.clark7@gmail.com'),
('Michael', 'Lewis', 88, 27, 'michael.lewis88@outlook.com'),
('Abigail', 'Robinson', 14, 9, 'abigail.robinson14@gmail.com'),
('Matthew', 'Walker', 60, 116, 'matthew.walker60@yahoo.com'),
('Emily', 'Young', 38, 22, 'emily.young38@gmail.com'),
('Joseph', 'Allen', 46, 58, 'joseph.allen46@hotmail.com'),
('Ella', 'King', 20, 75, 'ella.king20@gmail.com'),
('Samuel', 'Wright', 72, 3, 'samuel.wright72@yahoo.com'),
('Scarlett', 'Scott', 9, 68, 'scarlett.scott9@gmail.com'),
('David', 'Torres', 55, 91, 'david.torres55@outlook.com'),
('Victoria', 'Nguyen', 33, 14, 'victoria.nguyen33@gmail.com'),
('Carter', 'Hill', 28, 100, 'carter.hill28@yahoo.com'),
('Aria', 'Flores', 16, 35, 'aria.flores16@gmail.com'),
('Wyatt', 'Green', 61, 119, 'wyatt.green61@hotmail.com'),
('Luna', 'Adams', 5, 50, 'luna.adams5@gmail.com'),
('John', 'Nelson', 80, 44, 'john.nelson80@yahoo.com'),
('Grace', 'Baker', 42, 13, 'grace.baker42@gmail.com'),
('Owen', 'Hall', 24, 77, 'owen.hall24@outlook.com'),
('Chloe', 'Rivera', 37, 56, 'chloe.rivera37@gmail.com'),
('Jack', 'Campbell', 48, 8, 'jack.campbell48@yahoo.com'),
('Penelope', 'Mitchell', 26, 97, 'penelope.mitchell26@gmail.com'),
('Luke', 'Carter', 66, 19, 'luke.carter66@hotmail.com'),
('Riley', 'Roberts', 11, 84, 'riley.roberts11@gmail.com'),
('Gabriel', 'Gomez', 53, 30, 'gabriel.gomez53@yahoo.com'),
('Zoey', 'Phillips', 18, 64, 'zoey.phillips18@gmail.com'),
('Isaac', 'Evans', 39, 107, 'isaac.evans39@outlook.com'),
('Nora', 'Turner', 22, 52, 'nora.turner22@gmail.com'),
('Anthony', 'Diaz', 74, 25, 'anthony.diaz74@yahoo.com'),
('Lily', 'Parker', 8, 70, 'lily.parker8@gmail.com'),
('Julian', 'Cruz', 47, 90, 'julian.cruz47@hotmail.com'),
('Hannah', 'Edwards', 30, 11, 'hannah.edwards30@gmail.com'),
('Levi', 'Collins', 62, 41, 'levi.collins62@yahoo.com'),
('Addison', 'Stewart', 15, 118, 'addison.stewart15@gmail.com'),
('Christopher', 'Sanchez', 85, 36, 'christopher.sanchez85@outlook.com'),
('Aubrey', 'Morris', 21, 59, 'aubrey.morris21@gmail.com'),
('Joshua', 'Rogers', 49, 66, 'joshua.rogers49@yahoo.com'),
('Ellie', 'Reed', 13, 104, 'ellie.reed13@gmail.com'),
('Andrew', 'Cook', 57, 2, 'andrew.cook57@hotmail.com'),
('Stella', 'Morgan', 35, 79, 'stella.morgan35@gmail.com'),
('Ryan', 'Bell', 68, 28, 'ryan.bell68@yahoo.com'),
('Natalie', 'Murphy', 17, 99, 'natalie.murphy17@gmail.com'),
('Jaxon', 'Bailey', 43, 15, 'jaxon.bailey43@outlook.com'),
('Zoe', 'Rivera', 10, 63, 'zoe.rivera10@gmail.com'),
('Nathan', 'Cooper', 54, 86, 'nathan.cooper54@yahoo.com'),
('Hazel', 'Richardson', 6, 72, 'hazel.richardson6@gmail.com'),
('Aaron', 'Cox', 77, 109, 'aaron.cox77@hotmail.com'),
('Violet', 'Howard', 32, 24, 'violet.howard32@gmail.com'),
('Eli', 'Ward', 45, 92, 'eli.ward45@yahoo.com'),
('Aurora', 'Peterson', 3, 38, 'aurora.peterson3@gmail.com'),
('Caleb', 'Gray', 59, 117, 'caleb.gray59@outlook.com'),
('Savannah', 'Ramirez', 28, 7, 'savannah.ramirez28@gmail.com'),
('Christian', 'James', 71, 88, 'christian.james71@yahoo.com'),
('Audrey', 'Watson', 26, 55, 'audrey.watson26@gmail.com'),
('Hunter', 'Brooks', 50, 101, 'hunter.brooks50@hotmail.com'),
('Brooklyn', 'Kelly', 19, 16, 'brooklyn.kelly19@gmail.com'),
('Connor', 'Sanders', 64, 43, 'connor.sanders64@yahoo.com'),
('Bella', 'Price', 27, 120, 'bella.price27@gmail.com'),
('Evan', 'Bennett', 56, 20, 'evan.bennett56@outlook.com'),
('Claire', 'Wood', 18, 93, 'claire.wood18@gmail.com'),
('Jason', 'Barnes', 83, 5, 'jason.barnes83@yahoo.com'),
('Skylar', 'Ross', 2, 87, 'skylar.ross2@gmail.com'),
('Jhonathalie', 'Doughdodoo', 0, 1, 'jenerig@email.com');





INSERT INTO Phones (number, country_ID)
VALUES
('83472615', 12),
('59281734', 87),
('76192834', 45),
('38472915', 103),
('91827364', 56),
('47283916', 29),
('65182739', 78),
('29485716', 4),
('83726194', 65),
('72619483', 110),
('91837465', 22),
('37482915', 95),
('56273849', 31),
('84726195', 67),
('29384716', 8),
('76193825', 54),
('38472619', 73),
('91827345', 2),
('67283914', 99),
('48271639', 41),
('93726184', 60),
('28473916', 115),
('76192845', 19),
('83746521', 33),
('59281746', 101),
('47382915', 77),
('91837462', 6),
('26473819', 84),
('83726195', 47),
('76192834', 118),
('38472916', 25),
('91827364', 13),
('56273840', 91),
('84726193', 52),
('29384765', 36),
('76193827', 66),
('38472618', 72),
('91827346', 5),
('67283917', 104),
('48271630', 58),
('93726185', 21),
('28473917', 111),
('76192846', 9),
('83746522', 44),
('59281747', 97),
('47382916', 70),
('91837463', 14),
('26473810', 88),
('83726196', 62),
('76192835', 119),
('38472917', 27),
('91827365', 3),
('56273841', 90),
('84726194', 50),
('29384766', 38),
('76193828', 68),
('38472617', 71),
('91827347', 7),
('67283918', 106),
('48271631', 57),
('93726186', 24),
('28473918', 113),
('76192847', 11),
('83746523', 42),
('59281748', 98),
('47382917', 75),
('91837464', 16),
('26473811', 86),
('83726197', 61),
('76192836', 120),
('38472918', 26),
('91827366', 1),
('56273842', 92),
('84726195', 51),
('29384767', 39),
('76193829', 69),
('38472616', 74),
('91827348', 10),
('67283919', 107),
('48271632', 59),
('93726187', 23),
('28473919', 114),
('76192848', 15),
('83746524', 43),
('59281749', 96),
('47382918', 76),
('91837465', 18),
('26473812', 85),
('83726198', 63),
('76192837', 117),
('38472919', 28),
('91827367', 20),
('56273843', 93),
('84726196', 53),
('29384768', 40),
('76193830', 64),
('38472615', 79),
('91827349', 17),
('67283920', 108),
('48271633', 55);





INSERT INTO Phone_Ownership (owner_ID, number_ID)  
VALUES
(12, 34),
(45, 78),
(3, 12),
(78, 91),
(21, 56),
(67, 23),
(34, 88),
(9, 45),
(56, 67),
(80, 10),
(14, 99),
(62, 5),
(27, 72),
(71, 41),
(5, 63),
(48, 18),
(19, 84),
(77, 27),
(30, 59),
(11, 36),
(65, 2),
(2, 94),
(53, 50),
(40, 13),
(23, 75),
(74, 6),
(18, 81),
(69, 22),
(7, 97),
(58, 40),
(36, 14),
(1, 68),
(42, 30),
(25, 90),
(60, 55),
(16, 8),
(73, 71),
(28, 26),
(52, 47),
(10, 64),
(64, 11),
(6, 83),
(79, 37),
(33, 92),
(44, 19),
(22, 61),
(68, 4),
(4, 76),
(59, 53),
(20, 21),
(75, 95),
(13, 17),
(46, 39),
(31, 66),
(8, 7),
(70, 89),
(24, 44),
(57, 28),
(15, 73),
(63, 1),
(35, 82),
(76, 24),
(17, 60),
(50, 33),
(29, 98),
(72, 52),
(26, 16),
(66, 70),
(41, 9),
(54, 57),
(32, 85),
(47, 3),
(38, 93),
(61, 25),
(43, 62),
(55, 15),
(37, 79),
(49, 20),
(51, 86),
(39, 31),
(68, 96),
(18, 42),
(12, 74),
(27, 58),
(73, 6),
(9, 80),
(64, 35),
(6, 100),
(78, 29),
(21, 54),
(30, 43),
(11, 87),
(52, 65),
(25, 38),
(60, 69),
(16, 46),
(74, 77),
(28, 48),
(5, 32),
(67, 91),
(34, 18),
(19, 83),
(45, 27),
(8, 70),
(70, 12),
(2, 56),
(57, 94),
(13, 41),
(63, 99),
(26, 22),
(48, 75),
(36, 5),
(79, 88),
(1, 34),
(58, 63),
(22, 17),
(41, 90),
(75, 52),
(17, 11),
(66, 78);




INSERT INTO Cars (plate, model_ID, year, country_ID)
VALUES
('A9X3K7L', 12, 2005, 45),
('ZX81PLM2', 87, 1999, 12),
('QWERTY9', 34, 2015, 78),
('MN45OPQRS', 120, 1988, 3),
('JKL789ASD', 56, 2020, 67),
('P0IUYTRE', 99, 1975, 89),
('ASD123ZX', 3, 2018, 23),
('LKJHGF12', 141, 2001, 56),
('ZXCVBNM9', 45, 1993, 91),
('PLMOKNI8', 77, 2010, 34),
('AA11BB22', 14, 2008, 100),
('CC33DD44', 65, 1965, 44),
('EE55FF66', 23, 2022, 5),
('GG77HH88', 88, 1997, 76),
('II99JJ00', 102, 2003, 66),
('KK11LL22', 11, 1980, 2),
('MM33NN44', 37, 2016, 87),
('OO55PP66', 54, 1990, 55),
('QQ77RR88', 121, 2007, 98),
('SS99TT00', 73, 2019, 19),
('UV12WX34', 6, 2004, 60),
('YZ56AB78', 91, 1972, 118),
('CD90EF12', 40, 2011, 73),
('GH34IJ56', 135, 2023, 25),
('KL78MN90', 27, 1985, 41),
('OP12QR34', 64, 2006, 84),
('ST56UV78', 18, 1998, 9),
('WX90YZ12', 110, 2017, 112),
('AB34CD56', 79, 2002, 70),
('EF78GH90', 2, 2021, 33),
('IJ12KL34', 58, 1994, 101),
('MN56OP78', 96, 2009, 52),
('QR90ST12', 44, 1978, 6),
('UV34WX56', 139, 2014, 27),
('YZ78AB90', 31, 2000, 88),
('CD12EF34', 85, 2012, 63),
('GH56IJ78', 17, 1996, 47),
('KL90MN12', 100, 1983, 119),
('OP34QR56', 52, 2024, 15),
('ST78UV90', 9, 2007, 94),
('WX12YZ34', 70, 1991, 36),
('AB56CD78', 132, 2013, 68),
('EF90GH12', 26, 2005, 71),
('IJ34KL56', 111, 1989, 79),
('MN78OP90', 38, 2018, 17),
('QR12ST34', 63, 2006, 108),
('UV56WX78', 20, 1995, 22),
('YZ90AB12', 140, 2025, 64),
('CD34EF56', 75, 2001, 53),
('GH78IJ90', 7, 2010, 11),
('KL12MN34', 94, 1987, 97),
('OP56QR78', 49, 2008, 43),
('ST90UV12', 116, 1992, 80),
('WX34YZ56', 29, 2016, 58),
('AB78CD90', 83, 2003, 69),
('EF12GH34', 13, 1979, 4),
('IJ56KL78', 104, 2022, 82),
('MN90OP12', 60, 1999, 30),
('QR34ST56', 21, 2015, 120),
('UV78WX90', 137, 2004, 35),
('YZ12AB34', 47, 1993, 95),
('CD56EF78', 90, 2006, 62),
('GH90IJ12', 5, 2019, 24),
('KL34MN56', 112, 1982, 106),
('OP78QR90', 67, 2000, 72),
('ST12UV34', 1, 2023, 18),
('WX56YZ78', 130, 1997, 85),
('AB90CD12', 36, 2009, 46),
('EF34GH56', 98, 1986, 57),
('IJ78KL90', 25, 2011, 74),
('MN12OP34', 141, 2005, 92),
('QR56ST78', 53, 1998, 61),
('UV90WX12', 115, 2017, 109),
('YZ34AB56', 42, 2002, 16),
('CD78EF90', 78, 2020, 26),
('GH12IJ34', 8, 1994, 96),
('KL56MN78', 101, 2007, 54),
('OP90QR12', 33, 1981, 83),
('ST34UV56', 124, 2014, 37),
('WX78YZ90', 68, 2008, 48);





INSERT INTO Car_Ownership (owner_ID, car_plate) 
VALUES
(80, 'A9X3K7L'),
(35, 'ZX81PLM2'),
(60, 'QWERTY9'),
(5, 'MN45OPQRS'),
(44, 'JKL789ASD'),
(10, 'P0IUYTRE'),
(72, 'ASD123ZX'),
(28, 'LKJHGF12'),
(14, 'ZXCVBNM9'),
(1, 'PLMOKNI8'),
(66, 'AA11BB22'),
(18, 'CC33DD44'),
(54, 'EE55FF66'),
(7, 'GG77HH88'),
(63, 'II99JJ00'),
(20, 'KK11LL22'),
(58, 'MM33NN44'),
(3, 'OO55PP66'),
(47, 'QQ77RR88'),
(69, 'SS99TT00'),
(8, 'UV12WX34'),
(75, 'YZ56AB78'),
(22, 'CD90EF12'),
(39, 'GH34IJ56'),
(64, 'KL78MN90'),
(6, 'OP12QR34'),
(70, 'ST56UV78'),
(15, 'WX90YZ12'),
(52, 'AB34CD56'),
(24, 'EF78GH90'),
(68, 'IJ12KL34'),
(9, 'MN56OP78'),
(57, 'QR90ST12'),
(13, 'UV34WX56'),
(71, 'YZ78AB90'),
(2, 'CD12EF34'),
(77, 'GH56IJ78'),
(26, 'KL90MN12'),
(50, 'OP34QR56'),
(11, 'ST78UV90'),
(62, 'WX12YZ34'),
(4, 'AB56CD78'),
(73, 'EF90GH12'),
(29, 'IJ34KL56'),
(41, 'MN78OP90'),
(12, 'QR12ST34'),
(67, 'UV56WX78'),
(16, 'YZ90AB12'),
(55, 'CD34EF56'),
(23, 'GH78IJ90'),
(74, 'KL12MN34'),
(30, 'OP56QR78'),
(46, 'ST90UV12'),
(19, 'WX34YZ56'),
(78, 'AB78CD90'),
(31, 'EF12GH34'),
(65, 'IJ56KL78'),
(21, 'MN90OP12'),
(59, 'QR34ST56'),
(25, 'UV78WX90'),
(76, 'YZ12AB34'),
(33, 'CD56EF78'),
(61, 'GH90IJ12'),
(17, 'KL34MN56'),
(53, 'OP78QR90'),
(27, 'ST12UV34'),
(79, 'WX56YZ78'),
(34, 'AB90CD12'),
(56, 'EF34GH56'),
(38, 'IJ78KL90'),
(45, 'MN12OP34'),
(36, 'QR56ST78'),
(43, 'UV90WX12'),
(48, 'YZ34AB56'),
(40, 'CD78EF90'),
(51, 'GH12IJ34'),
(37, 'KL56MN78'),
(42, 'OP90QR12'),
(49, 'ST34UV56'),
(32, 'WX78YZ90'),
(3, 'A9X3K7L'),
(47, 'ZX81PLM2'),
(62, 'QWERTY9'),
(11, 'MN45OPQRS'),
(74, 'JKL789ASD'),
(25, 'P0IUYTRE'),
(53, 'ASD123ZX'),
(19, 'LKJHGF12'),
(80, 'ZXCVBNM9'),
(44, 'PLMOKNI8'),
(57, 'AA11BB22'),
(6, 'CC33DD44'),
(70, 'EE55FF66'),
(15, 'GG77HH88'),
(52, 'II99JJ00'),
(24, 'KK11LL22'),
(68, 'MM33NN44'),
(9, 'OO55PP66'),
(41, 'QQ77RR88'),
(12, 'SS99TT00'),
(67, 'UV12WX34'),
(16, 'YZ56AB78'),
(55, 'CD90EF12'),
(23, 'GH34IJ56'),
(74, 'KL78MN90'),
(30, 'OP12QR34'),
(46, 'ST56UV78'),
(19, 'WX90YZ12'),
(78, 'AB34CD56'),
(31, 'EF78GH90'),
(65, 'IJ12KL34'),
(21, 'MN56OP78'),
(59, 'QR90ST12'),
(25, 'UV34WX56'),
(76, 'YZ78AB90'),
(33, 'CD12EF34'),
(61, 'GH56IJ78'),
(17, 'KL90MN12'),
(53, 'OP34QR56'),
(27, 'ST78UV90');