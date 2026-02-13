//
//  ContentView.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import SwiftUI

struct VistaRickAndMorty: View {
    @State private var viewModel = RickAndMortyViewModel()
    @State private var path = NavigationPath()

    // @Binding private var path: NavigationPath("")

  //  @State private var path = NavigationPath()
    //@State private var path2 = NavigationPath("/rickandmorty")
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Carga interdimensional...")
                        .controlSize(.large)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    Button("Reintentar") {
                        Task {
                            await viewModel.cargarDatos()
                        }
                    }
                } else {
                    List(viewModel.personajes) {
                        personaje in
                        NavigationLink(value: personaje) {
                            //NavigationLink(destination: VistaDetallePersonaje(personaje: personaje)) {
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
            .navigationTitle("Rick and Morty API")
            .navigationDestination(
                for: Personaje.self,
                destination: {
                    personajes in
                    VistaDetallePersonaje(personaje: personajes, path: $path)
                }
            )
            .task {
                await viewModel.cargarDatos()
            }

        }
    }
}

#Preview {
    VistaRickAndMorty()
}
