import random
import string
from sqlalchemy.orm import Session
from sqlalchemy import select
from app.database import get_engine
from app.models import Vehiculo


def generate_plate(existing_plates: set[str]) -> str:
    while True:
        letters = "".join(random.choices(string.ascii_uppercase, k=3))
        digits = "".join(random.choices(string.digits, k=3))
        plate = f"{letters}{digits}"
        if plate not in existing_plates:
            existing_plates.add(plate)
            return plate


def seed(count: int = 100):
    random.seed(42)  # Semilla para consistencia

    colores = [
        "Blanco",
        "Negro",
        "Gris",
        "Plata",
        "Rojo",
        "Azul",
        "Blanco Perla",
        "Gris Plomo",
        "Vino Tinto",
    ]

    marcas_autos = [
        "Chevrolet",
        "Renault",
        "Mazda",
        "Toyota",
        "Kia",
        "Nissan",
        "Ford",
        "Hyundai",
        "Volkswagen",
        "Suzuki",
    ]
    marcas_motos = [
        "Yamaha",
        "Honda",
        "Suzuki",
        "Bajaj",
        "AKT",
        "Kawasaki",
        "KTM",
        "BMW",
    ]

    with Session(get_engine()) as session:
        existing_plates = set(session.scalars(select(Vehiculo.placa)).all())
        print(f"Vehículos existentes antes de insertar: {len(existing_plates)}")

        nuevos_vehiculos = []
        for _ in range(count):
            placa = generate_plate(existing_plates)
            tipo = random.choices(["AUTOMOVIL", "CAMIONETA", "MOTO"], weights=[50, 30, 20])[0]

            if tipo == "MOTO":
                marca = random.choice(marcas_motos)
            else:
                marca = random.choice(marcas_autos)

            color = random.choice(colores)
            modelo = random.randint(2010, 2025)

            vehiculo = Vehiculo(
                placa=placa,
                color=color,
                modelo=modelo,
                marca=marca,
                tipo=tipo,
            )
            nuevos_vehiculos.append(vehiculo)

        session.add_all(nuevos_vehiculos)
        session.commit()

        print(f"Se crearon e insertaron exitosamente {len(nuevos_vehiculos)} vehículos.")


if __name__ == "__main__":
    seed(100)
