from sqlalchemy.orm import Session
from sqlalchemy import select
from app.database import get_engine
from app.models import Celda


def seed():
    motos = [(f"M{i:02d}", "MOTO") for i in range(1, 11)]
    carros = [(f"C{i:02d}", "CARRO") for i in range(1, 71)]
    todas = motos + carros

    print(f"Total a procesar: {len(todas)} celdas.")

    creadas = 0
    actualizadas = 0
    existentes = 0

    with Session(get_engine()) as session:
        for codigo, tipo in todas:
            celda = session.scalar(select(Celda).where(Celda.codigo == codigo))
            if celda is None:
                nueva_celda = Celda(codigo=codigo, tipo=tipo)
                session.add(nueva_celda)
                creadas += 1
            else:
                if celda.tipo != tipo:
                    celda.tipo = tipo
                    actualizadas += 1
                else:
                    existentes += 1
        session.commit()

    print(f"Proceso completado:")
    print(f" - Creadas: {creadas}")
    print(f" - Actualizadas: {actualizadas}")
    print(f" - Existían previamente: {existentes}")
    print(f" - Total procesadas: {creadas + actualizadas + existentes}")


if __name__ == "__main__":
    seed()
