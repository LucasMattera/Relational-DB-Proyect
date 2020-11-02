CREATE DATABASE tp_mattera; 
\c tp_mattera;

CREATE TABLE feria (
    id int PRIMARY KEY,
    nombre varchar(255) NOT NULL,
    cuit varchar(13) NOT NULL,
    cantidad_puestos int check (cantidad_puestos <= 99999999999),
    localidad varchar(255),
    domicilio varchar(255),
    zona varchar(255) 
);

CREATE TABLE producto_tipo (
    id int PRIMARY KEY,
    nombre varchar(255) NOT NULL,
    descripcion varchar(255)
);

CREATE TABLE producto (
    id int PRIMARY KEY,
    tipo_id integer NOT NULL,
    especie varchar(255) NOT NULL,
    variedad varchar(255) ,
    activo boolean NOT NULL,
    CONSTRAINT fk_tipo_id FOREIGN KEY (tipo_id) REFERENCES producto_tipo(id)
    ON UPDATE NO ACTION 
    ON DELETE NO ACTION
);

CREATE TABLE "user" (
    id int PRIMARY KEY,
    email varchar(180) NOT NULL,
    password varchar(25) NOT NULL,
    nombre varchar(255),
    apellido varchar(255) 
);

CREATE TABLE declaracion (
    id int PRIMARY KEY,
    fecha_generacion timestamp NOT NULL,
    feria_id integer NOT NULL,
    user_autor_id integer,
    CONSTRAINT fk_declaracion_feria_id FOREIGN KEY (feria_id) REFERENCES feria(id),
    CONSTRAINT fk_declaracion_user_autor_id FOREIGN KEY (user_autor_id) REFERENCES "user"(id) 
    ON UPDATE NO ACTION 
    ON DELETE NO ACTION
);

CREATE TABLE declaracion_individual (
    id int PRIMARY KEY,
    producto_declarado_id integer NOT NULL,
    declaracion_id integer NOT NULL,
    fecha date NOT NULL,
    precio_por_bulto decimal(12,2) ,
    comercializado boolean DEFAULT '1',
    peso_por_bulto decimal(5,2),
    CONSTRAINT fk_producto_declarado_id FOREIGN KEY (producto_declarado_id) REFERENCES producto(id),
    CONSTRAINT fk_declaracion_id FOREIGN KEY (declaracion_id) REFERENCES declaracion(id)
    ON UPDATE NO ACTION 
    ON DELETE NO ACTION
);

CREATE TABLE user_feria (
    user_id integer NOT NULL,
    feria_id integer NOT NULL,
    CONSTRAINT pk_user_feria PRIMARY KEY (user_id, feria_id),
    CONSTRAINT fk_user_feria_user_id FOREIGN KEY (user_id) REFERENCES "user"(id),
    CONSTRAINT fk_user_feria_feria_id FOREIGN KEY (feria_id) REFERENCES feria(id)
    ON UPDATE NO ACTION 
    ON DELETE NO ACTION
);