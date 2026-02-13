//
//  DetallePersonajeViewModel.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 13/2/26.
//

import Observation
import SwiftUI

@Observable
class DetallePersonajeViewModel {
    let personaje: Personaje
    var detalle: PersonajeDetalle?
    var episodios: [Episodio] = []
    var personajesRelacionados: [Personaje] = []
    var isLoading = true

    private let apiService: ApiService

    init(personaje: Personaje, apiService: ApiService = ApiService.instancia) {
        self.personaje = personaje
        self.apiService = apiService
    }
    func cargarDatosCompletos() async {
        do {
            let datosDetalle = try await apiService.obtenerDetallePersonaje(
                id: personaje.id
            )
            self.detalle = datosDetalle

            if !datosDetalle.episode.isEmpty {
                self.episodios = try await apiService.obtenerEpisodios(
                    urls: datosDetalle.episode
                )
                print("Episodios cargados: \(episodios.count)")
            }

            if !episodios.isEmpty {
                try await cargarPersonajesRelacionados()
            }

            isLoading = false
        } catch {
            print("Error cargando detalles del personaje: \(error)")
        }
    }
    func cargarPersonajesRelacionados() async throws {
        //Vamos a usar el set para evitar personajes duplicados ya que salen en varios episodios
        var urlsPersonajes: Set<String> = Set()
        for episodio in episodios {
            for personajeUrl in episodio.characters {
                urlsPersonajes.insert(personajeUrl)
            }
        }
        //Nota: lo de arriba se puede hacer en una sola linea:
        //FlatMap coge todos los arrrays y los pone en un solo. Luego el set elimina duplicados
        //let urlsPersonajes2 = Set(episodios.flatMap {$0.characters})

        // Convertir
        let ids: [Int] = urlsPersonajes.compactMap {
            urlsString in
            guard let idString = urlsString.split(separator: "/").last else {
                return nil
            }
            return Int(idString)
        }.filter {
            id in
            //Quitamos el personaje actual (self.personaje) de la lista:
            return id != personaje.id
        }

        //Limitamos el número de personajes que solicitamos para mostrar
        // Además usamos shuffled() para que nos devuelva una lista aleatoria
        let idsLimitados = Array(ids.shuffled().prefix(10))

        self.personajesRelacionados =
            try await apiService.obtenerPersonajesPorIds(ids: idsLimitados)

        print("Cargados \(self.personajesRelacionados.count)")
    }

}
