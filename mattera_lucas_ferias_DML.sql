-- 1. Obtenga el nombre y apellido de los usuarios que no están relacionados con ninguna feria ordenados por nombre.
SELECT DISTINCT(nombre, apellido), nombre, apellido 
FROM "user"
LEFT JOIN user_feria ON "user".id = user_feria.user_id
ORDER BY nombre;

-- 2. Obtenga el nombre y apellido de los usuarios que están relacionados con SOLAMENTE 1 feria ordenados por apellido.
SELECT nombre, apellido
FROM "user"
WHERE id IN (   SELECT user_id
                FROM user_feria
                GROUP BY user_id
                HAVING COUNT(user_id) = 1)
ORDER BY apellido;    

-- 3. Obtenga el nombre y apellido de los usuarios que no están relacionados con más de una feria.
SELECT nombre, apellido
FROM "user"
WHERE id IN (   SELECT user_id
                FROM user_feria
                GROUP BY user_id
                HAVING COUNT(user_id) <= 1)
ORDER BY apellido;    

/* 
4. Obtenga el precio por kilo promediado por mes de cada producto, ordenados por tipo de producto ascendente, por especie y variedad del mismo 
y por precio por kilo descendente.
*/
SELECT producto_declarado_id, EXTRACT(MONTH FROM fecha), AVG(precio_por_bulto / peso_por_bulto)
FROM declaracion_individual
WHERE precio_por_bulto IS NOT NULL
GROUP BY producto_declarado_id, EXTRACT(MONTH FROM fecha)
ORDER BY producto_declarado_id;

-- 5. Seleccione qué ferias están registradas pero no tienen ninguna declaración.
SELECT *
FROM feria
WHERE feria.id NOT IN ( SELECT feria_id
                        FROM declaracion);

-- 6. Seleccione el nombre, apellido y correo electrónico de los usuarios que hicieron declaraciones de ferias con las que no están relacionados.
SELECT nombre, apellido, email
FROM declaracion 
JOIN "user" ON "user".id = declaracion.user_autor_id
WHERE declaracion.user_autor_id NOT IN (   SELECT user_id
                                           FROM user_feria);

-- 7. Selecciones aquellas frutas cuyo precio promedio por kilo historico no supere los 50 pesos.
SELECT id , tipo_id, especie, variedad, activo
FROM(   SELECT producto.id , tipo_id, especie, variedad, activo
        FROM producto
        JOIN producto_tipo ON producto.tipo_id = producto_tipo.id
        WHERE producto_tipo.nombre = 'Fruta') AS frutas
JOIN(   SELECT producto_declarado_id, AVG(precio_por_bulto / peso_por_bulto) 
        FROM declaracion_individual 
        GROUP BY producto_declarado_id
        HAVING AVG(precio_por_bulto / peso_por_bulto) < 50
) AS promedios ON frutas.id = promedios.producto_declarado_id;

/* 
8. Obtenga, ordenados alfabéticamente, el nombre y apellido de los usuarios que sólo frutas tienen en sus 
declaraciones (de acuerdo al tipo de producto).
*/
CREATE VIEW frutas_ids AS -- se obtienen los ids de productos que son frutas
SELECT producto.id 
FROM producto
JOIN producto_tipo ON producto.tipo_id = producto_tipo.id
WHERE producto_tipo.nombre = 'Fruta';

CREATE VIEW frutas_decl_ids AS -- se obtienen los id de los productos declarados que son frutas
SELECT DISTINCT(producto_declarado_id ) 
FROM declaracion_individual
JOIN frutas_ids ON frutas_ids.id = declaracion_individual.producto_declarado_id;

CREATE VIEW usr_decl_fruta AS -- se obtienen los ids de los usuarios que declararon frutas
SELECT DISTINCT (user_autor_id) 
FROM declaracion
JOIN frutas_decl_ids ON declaracion.user_autor_id = frutas_decl_ids.producto_declarado_id;

SELECT nombre, apellido
FROM "user"
JOIN usr_decl_fruta ON "user".id = usr_decl_fruta.user_autor_id;

-- 9. Obtenga un listado que muestre la cantidad de ferias por zona, ordenados descendentemente por cantidad.
SELECT zona, COUNT(zona)
FROM feria 
WHERE zona IS NOT NULL
GROUP BY zona
ORDER BY COUNT(zona) DESC;

/* 
10. Obtenga un listado que muestre la cantidad de ferias por zona, ordenados descendentemente
 (el listado debe excluir a las ferias sin declaraciones).
*/
SELECT zona, COUNT(zona)
FROM feria 
JOIN declaracion ON feria.id = declaracion.feria_id
WHERE zona IS NOT NULL
GROUP BY zona
ORDER BY COUNT(zona) DESC;

/* 
11. Obtenga un listado que muestre la cantidad de ferias por zona, ordenados descendentemente 
(el listado debe incluir a las ferias sin declaraciones).
*/
SELECT zona, COUNT(zona)
FROM feria 
WHERE zona IS NOT NULL
GROUP BY zona
ORDER BY COUNT(zona) DESC;

/* 
12. Obtenga un listado que muestre, 
de cada localidad donde haya usuarios registrados, 
el promedio de kilos por bulto, 
el máximo de kilos por bulto y 
el mínimo de kilos por bulto de naranjas ofrecidos en ferias de ese distrito.
*/
CREATE VIEW decl_join_decl_ind AS -- se joinea declaracion con declaracion individual
SELECT user_autor_id, precio_por_bulto, peso_por_bulto, producto_declarado_id
FROM declaracion 
JOIN declaracion_individual ON declaracion.id = declaracion_individual.declaracion_id;

CREATE VIEW VIEW_A AS -- se obtienen los atributos necesarios
SELECT user_feria.feria_id, user_feria.user_id, precio_por_bulto, peso_por_bulto 
FROM user_feria
JOIN decl_join_decl_ind ON user_feria.user_id = decl_join_decl_ind.user_autor_id;

CREATE VIEW avg_kgXbto_en_loc AS --se agrupa por promerdio de kgs x bulto
SELECT DISTINCT(localidad), AVG(precio_por_bulto / peso_por_bulto) AS prom_kg_bulto 
FROM feria
JOIN VIEW_A ON VIEW_A.feria_id = feria.id
GROUP BY localidad;

CREATE VIEW max_kdXbto_en_loc AS -- se agrupa por maximo de kgs x bulto
SELECT DISTINCT(localidad), MAX(precio_por_bulto / peso_por_bulto) as max_kg_bulto 
FROM feria
JOIN VIEW_A ON VIEW_A.feria_id = feria.id
GROUP BY localidad;

CREATE VIEW avg_kgXbto_join_max_kdXbto_en_loc AS
SELECT * 
FROM avg_kgXbto_en_loc
NATURAL JOIN max_kdXbto_en_loc;

CREATE VIEW usr_naranja AS
SELECT *
FROM decl_join_decl_ind
JOIN producto ON decl_join_decl_ind.producto_declarado_id = producto.id
WHERE producto.especie = 'NARANJA';

CREATE VIEW VIEW_B AS -- se obtienen los atributos necesarios
SELECT user_feria.feria_id, user_feria.user_id, precio_por_bulto, peso_por_bulto 
FROM user_feria
JOIN usr_naranja ON user_feria.user_id = usr_naranja.user_autor_id;

CREATE VIEW min_kgXbto_naran_distr AS -- se agrupa por minimo de kgs x bulto
SELECT DISTINCT(localidad), MIN(precio_por_bulto / peso_por_bulto) 
FROM feria
JOIN VIEW_B ON VIEW_B.feria_id = feria.id
GROUP BY localidad;

SELECT * 
FROM avg_kgXbto_join_max_kdXbto_en_loc
NATURAL JOIN min_kgXbto_naran_distr;

/* 
13. En la tabla de productos conocemos su PK, pero es necesario impedir que pueda repetirse especie y variedad. 
Explique cómo lo haría e impleméntelo.

Utilizaria la funcion UNIQUE para decir establecer que no se deben repetir estos dos atributos. De todos modos se que
esto es parte de DDL y no DML pero lo coloco aca con fines practicos.
*/
ALTER TABLE producto 
ADD CONSTRAINT unique_esp_var
UNIQUE (especie, variedad);

/* 
14. Cree una vista (view) con 
    la información de correo del usuario, 
    nombre, 
    ubicación de todas las ferias con las que está relacionado. 
Dicho listado debe incluir a los usuarios que no tienen ferias asociadas.
*/
CREATE VIEW ejercicio_14 as
SELECT "user".id AS id_usr, email AS email_usr, password AS password_usr, "user".nombre AS nombre_usr, apellido AS apellido_usr, localidad AS loc_feria, domicilio AS dom_feria, zona AS zona_feria
FROM "user"
JOIN(   SELECT *
        FROM user_feria
        JOIN feria ON user_feria.feria_id = feria.id
) AS ferias_user ON "user".id = ferias_user.user_id;

--15. Obtenga un listado con el precio promedio, precios máximos y mínimo por producto en la semana actual.
SELECT producto_declarado_id AS id_prod, AVG(precio_por_bulto) AS precio_avg, MAX(precio_por_bulto) AS precio_max, MIN(precio_por_bulto) AS precio_min
FROM declaracion_individual
WHERE EXTRACT (WEEK FROM fecha) = extract (WEEK FROM current_date)
GROUP BY producto_declarado_id;

/* 
16. Obtenga el precio promedio por producto y por zona en la semana anterior a la actual.
Tenes una forma de saber el número de semana de una fecha en un año
Creo que era extract (week from fecha)
Si la fecha es el 1 de enero de 2020 retorna 1
Si la fecha es el 8 de enero de 2020 retorna 2
*/
SELECT AVG(precio_por_bulto)
FROM declaracion_individual
JOIN(   SELECT declaracion.id AS id_decl, zona
        FROM declaracion
        JOIN feria ON declaracion.feria_id = feria.id
) AS decl_feria ON declaracion_individual.declaracion_id = decl_feria.id_decl
WHERE EXTRACT(WEEK FROM fecha) = EXTRACT (WEEK FROM CURRENT_DATE)
GROUP BY producto_declarado_id, zona;

/* 
17. Con el uso del sistema se identificaron muchísimas consultas buscando productos por su especie y variedad en la condición, 
cree un índice adecuado para dicha búsqueda.
*/
SELECT *
FROM producto
NATURAL JOIN(   SELECT especie, variedad
                FROM producto
                GROUP BY especie, variedad
) AS a;

/*
18. Obtenga las 3 ferias con 
    mas usuarios que no hayan  declaraciones o 
    que sólo las hayan  en ferias con menos de 50 puestos.

Aclaracion de Daniel Palazzo:
Aca tienen que 
        buscar las ferias y 
        contar cuantos usuarios asociados tieene q no tienen declaraciones 
        o solo las hicieron en ferias con menos de 50 puestos, 
de esas solo interesan las 3 con mas cantidad de
usuarios asociados q cumplan esas condiciones
*/
SELECT feria.id, nombre, cuit, cantidad_puestos, localidad, domicilio, zona, COUNT(user_autor_id)
FROM feria
JOIN declaracion ON feria.id = declaracion.feria_id
WHERE cantidad_puestos < 50 OR declaracion.user_autor_id NOT IN(SELECT user_autor_id from declaracion)
GROUP BY feria.id
ORDER BY COUNT(user_autor_id) DESC
LIMIT 3;