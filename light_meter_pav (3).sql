-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 23 2024 г., 03:52
-- Версия сервера: 8.0.30
-- Версия PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `light_meter_pav`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`root`@`%` PROCEDURE `HP1` (IN `id_meter_devise` INT)   BEGIN
    DECLARE count_kids INT;
    DECLARE count_pensioners INT;
    DECLARE kids_benefit varchar(20);
    DECLARE pens_benefit varchar(20);
    
    -- Подсчет несовершеннолетних (младше 18 лет)
    SELECT COUNT(*)
    INTO count_kids
    FROM residents
    WHERE TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) < 18
    AND id_devise = id_meter_devise;
    
    -- Подсчет пенсионеров (старше 55 лет)
    SELECT COUNT(*)
    INTO count_pensioners
    FROM residents
    WHERE TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) > 55
    AND id_devise = id_meter_devise;
    
    IF count_kids >= 3 THEN
        SELECT title INTO kids_benefit
        FROM type_of_benefits
        WHERE id = 1; 
    END IF;

    IF count_pensioners > 0 THEN
        SELECT title INTO pens_benefit
        FROM type_of_benefits
        WHERE id = 2; 
    END IF;

    
    -- Вывод результатов
    SELECT kids_benefit AS kids_benefits, pens_benefit AS pens_benefits;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `HP2` (IN `device_id` INT)   BEGIN
    DECLARE last_reading_date DATETIME;
    DECLARE days_after_reading INT;
    
    -- Вычичсление дапы последних показаний
    SELECT MAX(date_time) INTO last_reading_date
    FROM meter_readings
    WHERE id_devise = id;
    
    -- Вычисление количества дней с последней даты показаний, при их наличии
    IF last_reading_date IS NOT NULL THEN
        SET days_after_reading = DATEDIFF(CURRENT_DATE(), last_reading_date);
        SELECT days_after_reading AS days_after_reading;
    ELSE
        SELECT 'Readings not found' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `HP3` (IN `device_id` INT, IN `current_reading` DECIMAL(10,2))   BEGIN
    DECLARE last_reading DECIMAL(10,2);
    DECLARE difference DECIMAL(10,2);
    
    -- Найдем последнее показание счетчика
    SELECT readings INTO last_reading
    FROM meter_readings
    WHERE id_devise = device_id
    ORDER BY date_time DESC
    LIMIT 1;
    
    -- Вычислим разницу, с последнего показания
    IF last_reading IS NOT NULL THEN
        SET difference = current_reading - last_reading;
        SELECT difference AS difference_between_readings;
    ELSE
        SELECT 'предыдущие показания отсутствуют' AS message;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `meter_devise`
--

CREATE TABLE `meter_devise` (
  `id` int NOT NULL,
  `number` varchar(30) NOT NULL,
  `adres` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `meter_devise`
--

INSERT INTO `meter_devise` (`id`, `number`, `adres`) VALUES
(1, 'f4658', 'Москва, ул. Ломоносова, 44, 12'),
(2, '36f4g', 'Люберцы, ул. Волковская, 53, 31'),
(3, '2ck57', 'Москва, Красный Казанец, 33. 19'),
(4, 'dh3u8', 'г. Санкт-Петербург, ул Звонарева, д. 46, кв. 52');

-- --------------------------------------------------------

--
-- Структура таблицы `meter_readings`
--

CREATE TABLE `meter_readings` (
  `id` int NOT NULL,
  `date_time` date NOT NULL,
  `readings` int NOT NULL,
  `summa` int NOT NULL,
  `id_tarif` int NOT NULL,
  `id_devise` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `meter_readings`
--

INSERT INTO `meter_readings` (`id`, `date_time`, `readings`, `summa`, `id_tarif`, `id_devise`) VALUES
(1, '2024-03-12', 123, 5500, 2, 2),
(2, '2024-04-05', 111, 5000, 1, 1),
(3, '2024-03-26', 1234, 6000, 1, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `residents`
--

CREATE TABLE `residents` (
  `id` int NOT NULL,
  `surname` varchar(30) NOT NULL,
  `name` varchar(20) NOT NULL,
  `patronumic` varchar(30) NOT NULL,
  `birth_date` date NOT NULL,
  `id_devise` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `residents`
--

INSERT INTO `residents` (`id`, `surname`, `name`, `patronumic`, `birth_date`, `id_devise`) VALUES
(1, 'Орлов', 'Сергей', 'Викторович', '1990-03-12', 3),
(2, 'Орлов', 'Александр', 'Сергеевич', '2012-05-01', 3),
(3, 'Орлова', 'Ангелина', 'Сергеевна', '2016-09-26', 3),
(4, 'Орлова', 'Евгения', 'Сергеевна', '2018-11-14', 3),
(5, 'Орлова', 'Вероника', 'Степановна', '1992-02-13', 3),
(6, 'Мечников', 'Аркадий', 'Николаевич', '1957-06-27', 1),
(7, 'Пименова', 'Юлия', 'Аркадьевна', '1983-10-07', 1),
(8, 'Пименов', 'Юрий', 'Витальевич', '1982-08-25', 1),
(9, 'Пименов', 'Арсений', 'Юрьевич', '2006-06-14', 1),
(10, 'Петров', 'Степан', 'Юрьевич', '1946-04-12', 4);

-- --------------------------------------------------------

--
-- Структура таблицы `taken_benefits`
--

CREATE TABLE `taken_benefits` (
  `id` int NOT NULL,
  `id_benefis` int NOT NULL,
  `id_readings` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `taken_benefits`
--

INSERT INTO `taken_benefits` (`id`, `id_benefis`, `id_readings`) VALUES
(1, 2, 2),
(2, 1, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `tarif`
--

CREATE TABLE `tarif` (
  `id` int NOT NULL,
  `title` varchar(20) NOT NULL,
  `size` decimal(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `tarif`
--

INSERT INTO `tarif` (`id`, `title`, `size`) VALUES
(1, 'ночной', '4.31'),
(2, 'дневной', '6.72');

-- --------------------------------------------------------

--
-- Структура таблицы `type_of_benefits`
--

CREATE TABLE `type_of_benefits` (
  `id` int NOT NULL,
  `title` varchar(20) NOT NULL,
  `size` decimal(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `type_of_benefits`
--

INSERT INTO `type_of_benefits` (`id`, `title`, `size`) VALUES
(1, 'многодетные', '0.70'),
(2, 'пенсионер', '0.60');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `meter_devise`
--
ALTER TABLE `meter_devise`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `meter_readings`
--
ALTER TABLE `meter_readings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_devise` (`id_devise`),
  ADD KEY `id_tarif` (`id_tarif`);

--
-- Индексы таблицы `residents`
--
ALTER TABLE `residents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_devise` (`id_devise`),
  ADD KEY `id_devise_2` (`id_devise`);

--
-- Индексы таблицы `taken_benefits`
--
ALTER TABLE `taken_benefits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_benefis` (`id_benefis`),
  ADD KEY `id_readings` (`id_readings`);

--
-- Индексы таблицы `tarif`
--
ALTER TABLE `tarif`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `type_of_benefits`
--
ALTER TABLE `type_of_benefits`
  ADD PRIMARY KEY (`id`);

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `meter_readings`
--
ALTER TABLE `meter_readings`
  ADD CONSTRAINT `meter_readings_ibfk_1` FOREIGN KEY (`id_devise`) REFERENCES `meter_devise` (`id`),
  ADD CONSTRAINT `meter_readings_ibfk_2` FOREIGN KEY (`id_tarif`) REFERENCES `tarif` (`id`);

--
-- Ограничения внешнего ключа таблицы `residents`
--
ALTER TABLE `residents`
  ADD CONSTRAINT `residents_ibfk_1` FOREIGN KEY (`id_devise`) REFERENCES `meter_devise` (`id`);

--
-- Ограничения внешнего ключа таблицы `taken_benefits`
--
ALTER TABLE `taken_benefits`
  ADD CONSTRAINT `taken_benefits_ibfk_1` FOREIGN KEY (`id_benefis`) REFERENCES `type_of_benefits` (`id`),
  ADD CONSTRAINT `taken_benefits_ibfk_2` FOREIGN KEY (`id_readings`) REFERENCES `meter_readings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
