import { Celda } from './celda';
import { Vehiculo } from './vehiculo';

export interface EntradaCrear {
  placa: string;
  celda_id: number;
  operador_id: number;
}
export interface SalidaCrear {
  placa: string;
  operador_id: number;
}
export interface Estancia {
  id: number;
  vehiculo_id: number;
  celda_id: number;
  entrada: string;
  salida: string | null;
  operador_entrada_id: number;
  operador_salida_id: number | null;
}
export interface EstadoVehiculo {
  vehiculo: Vehiculo;
  esta_dentro: boolean;
  estancia: (Estancia & { celda: Celda }) | null;
}

export interface EstanciaOcupada extends Estancia {
  vehiculo: Vehiculo;
  celda: Celda;
}

export interface MovimientoDia {
  id: number;
  placa: string;
  celda: string;
  fecha: string;
}

export interface MovimientosDia {
  entradas: MovimientoDia[];
  salidas: MovimientoDia[];
}
