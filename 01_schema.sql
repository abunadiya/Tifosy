-- =============================================================================
-- Projet   : Tifosi — restaurant de street-food italien
-- Fichier  : 01_schema.sql
-- Objet    : création de la base, de l'utilisateur et du schéma physique
-- SGBD     : MySQL 8 / MariaDB 10.4+
-- Encodage : UTF-8 (utf8mb4)
--
-- Exécution : en tant qu'administrateur (root), par exemple :
--   mysql -u root -p < 01_schema.sql
--   ou via l'onglet SQL de phpMyAdmin / HeidiSQL / MySQL Workbench
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- -----------------------------------------------------------------------------
-- 1. Base de données
-- -----------------------------------------------------------------------------
-- Recréation volontaire : le script est idempotent pour les rejeux de test.
DROP DATABASE IF EXISTS tifosi;

CREATE DATABASE tifosi
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tifosi;


-- -----------------------------------------------------------------------------
-- 2. Utilisateur d'administration de la base
-- -----------------------------------------------------------------------------
-- Compte dédié à l'application : droits limités à la base tifosi (pas de
-- privilèges globaux). Mot de passe conforme à la politique MySQL 8
-- (majuscule, minuscule, chiffre, caractère spécial).
-- À changer si le dépôt est public et que le serveur n'est plus un poste local.
DROP USER IF EXISTS 'tifosi'@'localhost';

CREATE USER 'tifosi'@'localhost'
    IDENTIFIED BY 'Tifosi2026!';

GRANT ALL PRIVILEGES
    ON tifosi.*
    TO 'tifosi'@'localhost';

FLUSH PRIVILEGES;


-- -----------------------------------------------------------------------------
-- 3. Passage du MCD au MLD (organisation physique)
-- -----------------------------------------------------------------------------
-- Entités        -> tables : ingredient, focaccia, marque, boisson, client, menu
-- Associations 1,n / 0,n identifiées (FK unique) :
--   appartient     :  marque (0,n) --- (1,1) boisson   =>  boisson.id_marque
--   est constitué  : focaccia (0,n) --- (1,1) menu     =>  menu.id_focaccia
-- Associations N:N (table d'association + attributs éventuels) :
--   comprend : focaccia (1,n) --- (0,n) ingredient  + quantite
--   contient :     menu (1,n) --- (0,n) boisson
--   achete   :   client (0,n) --- (0,n) menu        + date_achat
--
-- Le MCD orthographie l'entité « foccacia » : la table est nommée focaccia
-- (orthographe usuelle, alignée sur les fichiers Excel et les requêtes).
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- 4. Tables d'entités (sans clé étrangère)
-- -----------------------------------------------------------------------------

CREATE TABLE ingredient (
    id_ingredient INT          NOT NULL AUTO_INCREMENT,
    nom           VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_ingredient PRIMARY KEY (id_ingredient),
    CONSTRAINT uq_ingredient_nom UNIQUE (nom)
) ENGINE = InnoDB;


CREATE TABLE focaccia (
    id_focaccia INT            NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(50)    NOT NULL,
    prix        DECIMAL(5, 2)  NOT NULL,
    CONSTRAINT pk_focaccia PRIMARY KEY (id_focaccia),
    CONSTRAINT uq_focaccia_nom UNIQUE (nom),
    CONSTRAINT ck_focaccia_prix CHECK (prix >= 0)
) ENGINE = InnoDB;


CREATE TABLE marque (
    id_marque INT          NOT NULL AUTO_INCREMENT,
    nom       VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_marque PRIMARY KEY (id_marque),
    CONSTRAINT uq_marque_nom UNIQUE (nom)
) ENGINE = InnoDB;


CREATE TABLE client (
    id_client   INT           NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(50)   NOT NULL,
    email       VARCHAR(150)  NOT NULL,
    code_postal INT           NOT NULL,
    CONSTRAINT pk_client PRIMARY KEY (id_client),
    CONSTRAINT uq_client_email UNIQUE (email),
    CONSTRAINT ck_client_cp CHECK (code_postal BETWEEN 1000 AND 99999)
) ENGINE = InnoDB;


-- -----------------------------------------------------------------------------
-- 5. Tables d'entités avec clé étrangère (associations binaires 1,n)
-- -----------------------------------------------------------------------------

-- appartient : une boisson a exactement une marque (1,1)
CREATE TABLE boisson (
    id_boisson INT          NOT NULL AUTO_INCREMENT,
    nom        VARCHAR(50)  NOT NULL,
    id_marque  INT          NOT NULL,
    CONSTRAINT pk_boisson PRIMARY KEY (id_boisson),
    CONSTRAINT uq_boisson_nom UNIQUE (nom),
    CONSTRAINT fk_boisson_marque
        FOREIGN KEY (id_marque)
        REFERENCES marque (id_marque)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- est constitué : un menu est composé d'exactement une focaccia (1,1)
CREATE TABLE menu (
    id_menu     INT            NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(50)    NOT NULL,
    prix        DECIMAL(5, 2)  NOT NULL,
    id_focaccia INT            NOT NULL,
    CONSTRAINT pk_menu PRIMARY KEY (id_menu),
    CONSTRAINT uq_menu_nom UNIQUE (nom),
    CONSTRAINT ck_menu_prix CHECK (prix >= 0),
    CONSTRAINT fk_menu_focaccia
        FOREIGN KEY (id_focaccia)
        REFERENCES focaccia (id_focaccia)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- -----------------------------------------------------------------------------
-- 6. Tables d'association (relations N:N)
-- -----------------------------------------------------------------------------

-- comprend : une focaccia a au moins un ingrédient (1,n) ;
--            un ingrédient peut n'appartenir à aucune focaccia (0,n).
CREATE TABLE comprend (
    id_focaccia   INT NOT NULL,
    id_ingredient INT NOT NULL,
    quantite      INT NOT NULL COMMENT 'Quantité en grammes',
    CONSTRAINT pk_comprend PRIMARY KEY (id_focaccia, id_ingredient),
    CONSTRAINT ck_comprend_quantite CHECK (quantite > 0),
    CONSTRAINT fk_comprend_focaccia
        FOREIGN KEY (id_focaccia)
        REFERENCES focaccia (id_focaccia)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_comprend_ingredient
        FOREIGN KEY (id_ingredient)
        REFERENCES ingredient (id_ingredient)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- contient : un menu contient au moins une boisson (1,n) ;
--            une boisson peut n'être dans aucun menu (0,n).
CREATE TABLE contient (
    id_menu    INT NOT NULL,
    id_boisson INT NOT NULL,
    CONSTRAINT pk_contient PRIMARY KEY (id_menu, id_boisson),
    CONSTRAINT fk_contient_menu
        FOREIGN KEY (id_menu)
        REFERENCES menu (id_menu)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_contient_boisson
        FOREIGN KEY (id_boisson)
        REFERENCES boisson (id_boisson)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- achete : un client peut acheter 0 à n menus ; un menu peut être acheté 0 à n fois.
-- Clé primaire étendue à la date pour autoriser plusieurs achats du même menu
-- par le même client à des dates différentes.
CREATE TABLE achete (
    id_client  INT  NOT NULL,
    id_menu    INT  NOT NULL,
    date_achat DATE NOT NULL,
    CONSTRAINT pk_achete PRIMARY KEY (id_client, id_menu, date_achat),
    CONSTRAINT fk_achete_client
        FOREIGN KEY (id_client)
        REFERENCES client (id_client)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_achete_menu
        FOREIGN KEY (id_menu)
        REFERENCES menu (id_menu)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- Fin du script de schéma
-- =============================================================================
