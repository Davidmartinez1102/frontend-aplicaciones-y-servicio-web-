CREATE TABLE usuario (
    email NVARCHAR(200) PRIMARY KEY,
    contrasena NVARCHAR(200) NOT NULL,
    debe_cambiar_contrasena BIT DEFAULT 0 
);

CREATE TABLE rol (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL
);

CREATE TABLE rol_usuario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fkemail NVARCHAR(200) REFERENCES usuario(email),
    fkidrol INT REFERENCES rol(id)
);

CREATE TABLE ruta (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ruta NVARCHAR(200) NOT NULL,
    descripcion NVARCHAR(MAX) DEFAULT ''
);

CREATE TABLE rutarol (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fkidrol INT REFERENCES rol(id),
    fkidruta INT REFERENCES ruta(id)
);
GO