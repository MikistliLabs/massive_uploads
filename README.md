# Version laravel y passport
"laravel/framework": "^9.19",
"laravel/passport": "11.0",
# Configuración para trabajar con load data local infile en MySQL 

Habilitar de la siguiente forma en el archivo de configuración de MySQL (my.ini o my.cnf)
local_infile=1
Deberá estar como en el siguiente fragmento 

[mysqld]
port=3306
datadir="C:/xampp/mysql/data"
socket="C:/xampp/mysql/mysql.sock"
local_infile=1

# En a configuracion de database debera esta configurada de la siguiente form 
'options' => extension_loaded('pdo_mysql') ? array_filter([
    PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
    PDO::MYSQL_ATTR_LOCAL_INFILE => true, // Habilitar LOCAL INFILE
]) : [],

# Configuración para tabajar con Oauth2
Se debera ejecutar el siguiente comando para poder generas las claves del cliente para las solicitudes del token Oauth2
composer requiere laravel/passport:^11.0
php artisan passport:install

# StoreProcedure de disperción de datos estos se ejecutaran solo si se ejecutan las migraciones, si se decide usar el dump no será necesario
DELIMITER //

CREATE PROCEDURE DisperseTemporalPersonData()
BEGIN
    DECLARE person_id INT;

    -- Insertar personas únicas, evitando nombres vacíos
    INSERT INTO person (nombre, paterno, materno)
    SELECT DISTINCT nombre, paterno, materno
    FROM temporal_person
    WHERE nombre IS NOT NULL AND nombre != ''
      AND paterno IS NOT NULL AND paterno != ''
      AND materno IS NOT NULL AND materno != ''
      AND NOT EXISTS (
          SELECT 1
          FROM person
          WHERE person.nombre = temporal_person.nombre
            AND person.paterno = temporal_person.paterno
            AND person.materno = temporal_person.materno
      );

    -- Insertar teléfonos únicos, evitando valores vacíos
    INSERT INTO phone (phone, person_id)
    SELECT DISTINCT t.telefono, p.id
    FROM temporal_person t
    INNER JOIN person p
      ON p.nombre = t.nombre
      AND p.paterno = t.paterno
      AND p.materno = t.materno
    WHERE t.telefono IS NOT NULL AND t.telefono != ''
      AND NOT EXISTS (
          SELECT 1
          FROM phone ph
          WHERE ph.phone = t.telefono
            AND ph.person_id = p.id
      );

    -- Insertar direcciones únicas, evitando valores vacíos
    INSERT INTO address (calle, numero_exterior, numero_interior, colonia, cp, person_id)
    SELECT DISTINCT t.calle, t.numero_exterior, t.numero_interior, t.colonia, t.cp, p.id
    FROM temporal_person t
    INNER JOIN person p
      ON p.nombre = t.nombre
      AND p.paterno = t.paterno
      AND p.materno = t.materno
    WHERE t.calle IS NOT NULL AND t.calle != ''
      AND t.colonia IS NOT NULL AND t.colonia != ''
      AND t.cp IS NOT NULL AND t.cp != ''
      AND NOT EXISTS (
          SELECT 1
          FROM address a
          WHERE a.calle = t.calle
            AND a.numero_exterior = t.numero_exterior
            AND a.numero_interior = t.numero_interior
            AND a.colonia = t.colonia
            AND a.cp = t.cp
            AND a.person_id = p.id
      );

    -- Limpiar la tabla temporal
    TRUNCATE TABLE temporal_person;
END;
//

DELIMITER ;

# StoreProcedure de consulta
DELIMITER //

CREATE PROCEDURE SP_GetPeople(
    IN startIndex INT,
    IN pageSize INT
)
BEGIN
    SELECT 
        p.id, 
        p.nombre, 
        p.paterno, 
        p.materno
    FROM person p
    LIMIT startIndex, pageSize;

    SELECT 
        COUNT(*) AS totalRecords
    FROM person;
END //

DELIMITER ;

# Creación de tablas de la base de datos
Se pueden ejecutar las migraciones configuradas en el proyecto, de igual forma se adjunta un dump de la base de datos que se ocupo en pruebas.

# usuarios 
En caso de ejecutar las migraciones, no se tendria un usuario creado por default, se creo un endpoint de creación de usuarios 

enpoint: api/singup
x-www-form-urlencoded
name:Carlos Sanchez
email:csanchez@mikistlilabs.com
password:123456789
password_confirmation:123456789
user_type:1 // el tipo de usuario 1 es para admin quien podra cargar el excel y el usuario 2 solo podra visualizar la informacion de las personas



# usuarios configurados en el dump
admin
email: Alberto@example.com
contraseña: password

usuario de consulta
email: grillo@mikistlilabs.com
contraseña: 123456789
