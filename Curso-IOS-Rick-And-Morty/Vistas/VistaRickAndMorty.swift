//
//  ContentView.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import SwiftUI

struct VistaRickAndMorty: View {
    @State private var personajes: [Personaje] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    private let apiService = ApiService()
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Carga interdimensional...")
                        .controlSize(.large)
                } else if let errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    Button("Reintentar") {
                        Task {
                            await cargarDatos()
                        }
                    }
                } else {
                    List(personajes) {
                        personaje in
                        NavigationLink(
                            destination: VistaDetallePersonaje(
                                personaje: personaje
                            )
                        ) {
                            HStack {
                                //Carga de la imagen
                                AsyncImage(url: URL(string: personaje.image)) {
                                    imagen in
                                    imagen.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(personaje.name)
                                        .font(.headline)
                                    Text(personaje.species)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(personaje.status)
                                        .font(.subheadline)
                                }
                                Spacer()
                                //Si está vivo se pone en verde, si está muerto en rojo
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(
                                        personaje.status == "Alive"
                                            ? .green : .red
                                    )
                            }
                        }
                    }
                }

            }
            .navigationTitle("Rick and Morty API").task {
                await cargarDatos()
            }

        }
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

#Preview {
    VistaRickAndMorty()
}
