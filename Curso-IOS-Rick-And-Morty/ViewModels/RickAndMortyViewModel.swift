//
//  VistaRickAndMortyViewModel.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 13/2/26.
//

import Observation
import SwiftUI

@Observable
class RickAndMortyViewModel {
    var personajes: [Personaje] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    //private let apiService = ApiService()
    private let apiService: ApiService

    init(apiService: ApiService = ApiService.instancia) {
        self.apiService = apiService
    }
    func cargarDatos() async {
        isLoading = true
        errorMessage = nil
        do {
            personajes = try await apiService.obtenerPersonajes()
        } catch {
            errorMessage = "Error al cargar los personajes"
        }
        isLoading = false
    }

}
//miViewModel = RickAndMortyViewModel(apiService: )
