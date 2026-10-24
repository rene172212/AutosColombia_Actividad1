-- Modelo físico de Autos Colombia para PostgreSQL.
-- DDL equivalente a las revisiones Alembic 0001 y 0002.
-- Este archivo solo define el esquema; no inserta datos.

BEGIN;

CREATE TABLE vehiculo (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa TEXT NOT NULL,
    color TEXT NOT NULL,
    modelo INTEGER NOT NULL,
    marca TEXT NOT NULL,
    tipo TEXT NOT NULL,
    CONSTRAINT uq_vehiculo_placa UNIQUE (placa),
    CONSTRAINT ck_vehiculo_placa_no_vacia CHECK (placa ~ '[^[:space:]]'),
    CONSTRAINT ck_vehiculo_placa_normalizada CHECK (
        placa = upper(regexp_replace(placa, '^[[:space:]]+|[[:space:]]+$', '', 'g'))
    ),
    CONSTRAINT ck_vehiculo_color_no_vacio CHECK (color ~ '[^[:space:]]'),
    CONSTRAINT ck_vehiculo_marca_no_vacia CHECK (marca ~ '[^[:space:]]'),
    CONSTRAINT ck_vehiculo_modelo_anio CHECK (modelo BETWEEN 1 AND 9999),
    CONSTRAINT ck_vehiculo_tipo CHECK (tipo IN ('MOTO', 'AUTOMOVIL', 'CAMIONETA'))
);

CREATE TABLE celda (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo TEXT NOT NULL,
    tipo TEXT NOT NULL,
    CONSTRAINT uq_celda_codigo UNIQUE (codigo),
    CONSTRAINT ck_celda_codigo_no_vacio CHECK (codigo ~ '[^[:space:]]'),
    CONSTRAINT ck_celda_codigo_normalizado CHECK (
        codigo = upper(regexp_replace(codigo, '^[[:space:]]+|[[:space:]]+$', '', 'g'))
    ),
    CONSTRAINT ck_celda_tipo_no_vacio CHECK (tipo ~ '[^[:space:]]')
);

CREATE TABLE operador (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    telefono TEXT NOT NULL,
    CONSTRAINT ck_operador_nombre_no_vacio CHECK (nombre ~ '[^[:space:]]'),
    CONSTRAINT ck_operador_telefono_no_vacio CHECK (telefono ~ '[^[:space:]]')
);

CREATE TABLE estancia (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL,
    celda_id BIGINT NOT NULL,
    entrada TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    salida TIMESTAMP WITH TIME ZONE,
    operador_entrada_id BIGINT NOT NULL,
    operador_salida_id BIGINT,
    CONSTRAINT fk_estancia_vehiculo FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculo (id) ON DELETE RESTRICT,
    CONSTRAINT fk_estancia_celda FOREIGN KEY (celda_id)
        REFERENCES celda (id) ON DELETE RESTRICT,
    CONSTRAINT fk_estancia_operador_entrada FOREIGN KEY (operador_entrada_id)
        REFERENCES operador (id) ON DELETE RESTRICT,
    CONSTRAINT fk_estancia_operador_salida FOREIGN KEY (operador_salida_id)
        REFERENCES operador (id) ON DELETE RESTRICT,
    CONSTRAINT ck_estancia_orden_fechas CHECK (salida >= entrada),
    CONSTRAINT ck_estancia_cierre_completo CHECK (
        (salida IS NULL) = (operador_salida_id IS NULL)
    )
);

-- Una estancia abierta por vehículo y por celda como máximo.
CREATE UNIQUE INDEX uq_estancia_vehiculo_abierta
    ON estancia (vehiculo_id)
    WHERE salida IS NULL;

CREATE UNIQUE INDEX uq_estancia_celda_abierta
    ON estancia (celda_id)
    WHERE salida IS NULL;

CREATE INDEX ix_estancia_vehiculo_entrada
    ON estancia (vehiculo_id, entrada);

COMMIT;
