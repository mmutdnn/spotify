-- Создание схемы (базы данных)
-- Примечание: в DBeaver лучше сначала создать базу через интерфейс (ПКМ по БД -> Create Database), 
-- либо раскомментировать строку ниже (если вы подключены к postgres):
-- CREATE DATABASE spotify_db;
-- \c spotify_db

-- Удаляем старые таблицы, если они есть (для чистоты эксперимента)
DROP TABLE IF EXISTS playlist_tracks CASCADE;
DROP TABLE IF EXISTS listens CASCADE;
DROP TABLE IF EXISTS playlists CASCADE;
DROP TABLE IF EXISTS tracks CASCADE;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS artists CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Таблица пользователей
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    birth_date DATE,
    country VARCHAR(50),
    registration_date DATE NOT NULL,
    subscription_id INT
);

-- 2. Таблица подписок
CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    price INT NOT NULL,
    duration_months INT NOT NULL
);

-- 3. Таблица артистов
CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    formed_year INT,
    bio TEXT
);

-- 4. Таблица альбомов
CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    release_date DATE,
    album_type VARCHAR(50),
    artist_id INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- 5. Таблица треков
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    duration_sec INT NOT NULL,
    track_number INT,
    explicit BOOLEAN DEFAULT FALSE,
    play_count INT DEFAULT 0,
    album_id INT NOT NULL,
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE CASCADE
);

-- 6. Таблица плейлистов
CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    created_at DATE NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 7. Таблица связи треков и плейлистов (Многие-ко-многим)
CREATE TABLE playlist_tracks (
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    position INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE
);

-- 8. Таблица прослушиваний (История)
CREATE TABLE listens (
    listen_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    track_id INT NOT NULL,
    listened_at TIMESTAMP NOT NULL,
    device VARCHAR(50),
    seconds_played INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE
);

-- Добавляем связь для users -> subscriptions (так как таблица users создана раньше)
ALTER TABLE users 
ADD CONSTRAINT fk_user_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE SET NULL;