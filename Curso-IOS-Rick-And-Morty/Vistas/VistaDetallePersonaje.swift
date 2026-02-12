//
//  VistaDetallePersonaje.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import SwiftUI

struct VistaDetallePersonaje: View {
    let personaje: Personaje
    @State private var detalle: PersonajeDetalle?
    @State private var isLoading = true

    private let apiService = ApiService()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: personaje.image)) {
                    img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .overlay(alignment: .bottom) {
                    Text(personaje.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                }
                if isLoading {
                    ProgressView("Descargando datos...")
                }
            }
        }
        .task {
            await cargarDatosCompletos()
        }
    }
    func cargarDatosCompletos() async {
        do {
            let datosDetalle = try await apiService.obtenerDetallePersonaje(
                id: personaje.id
            )
            self.detalle = datosDetalle
            
            isLoading = false
        } catch {
            print("Error cargando detalles del personaje: \(error)")
        }
    }
}

#Preview {
    let personaje = Personaje(
        id: 1,
        name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
    )
    VistaDetallePersonaje(personaje: personaje)
}
