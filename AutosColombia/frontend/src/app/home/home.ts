import { ApiService } from '../services/api.service';
import { Component, computed, DestroyRef, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

import { timeout } from 'rxjs';
import { EstanciaOcupada, MovimientosDia, MovimientoDia } from '../models/estancia';
import { EstanciasService } from '../services/estancias.service';

@Component({
  imports: [],
  selector: 'app-home',
  styleUrl: './home.css',
  templateUrl: './home.html',
})
export class Home {
  private readonly destroyRef = inject(DestroyRef);
  private readonly estancias = inject(EstanciasService);

  protected readonly connectionState = signal<'checking' | 'available' | 'unavailable'>('checking');
  protected readonly occupancyState = signal<'loading' | 'loaded' | 'unavailable'>('loading');
  protected readonly occupiedSpaces = signal<EstanciaOcupada[]>([]);
  protected readonly movementState = signal<'loading' | 'loaded' | 'unavailable'>('loading');
  protected readonly todayMovements = signal<MovimientosDia>({ entradas: [], salidas: [] });
  protected readonly connectionMessage = computed(() => {
    switch (this.connectionState()) {
      case 'available':
        return 'Servicio disponible';
      case 'unavailable':
        return 'No se pudo conectar con el servicio';
      default:
        return 'Comprobando conexión…';
    }
  });

  constructor() {
    inject(ApiService)
      .health()
      .pipe(timeout(5000), takeUntilDestroyed())
      .subscribe({
        next: (response) =>
          this.connectionState.set(response?.status === 'ok' ? 'available' : 'unavailable'),
        error: () => this.connectionState.set('unavailable'),
      });
    this.loadOccupiedSpaces();
    this.loadTodayMovements();
  }

  protected loadOccupiedSpaces(): void {
    this.occupancyState.set('loading');
    this.estancias
      .abiertas()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (items) => {
          this.occupiedSpaces.set(items);
          this.occupancyState.set('loaded');
        },
        error: () => this.occupancyState.set('unavailable'),
      });
  }

  protected loadTodayMovements(): void {
    this.movementState.set('loading');
    this.estancias
      .movimientosHoy()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (movements) => {
          this.todayMovements.set(movements);
          this.movementState.set('loaded');
        },
        error: () => this.movementState.set('unavailable'),
      });
  }

  protected hora(value: string): string {
    return new Intl.DateTimeFormat('es-CO', {
      timeZone: 'America/Bogota',
      hour: '2-digit',
      minute: '2-digit',
    }).format(new Date(value));
  }

  protected etiquetaMovimiento(item: MovimientoDia): string {
    return `${item.placa} · Celda ${item.celda} · ${this.hora(item.fecha)}`;
  }
}
