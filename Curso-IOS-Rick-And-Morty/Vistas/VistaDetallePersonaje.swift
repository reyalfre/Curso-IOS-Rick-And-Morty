//
//  VistaDetallePersonaje.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import SwiftUI

struct VistaDetallePersonaje: View {
    
    @Binding var path: NavigationPath
    @State private var viewModel: DetallePersonajeViewModel
    
    init(personaje: Personaje, path: Binding<NavigationPath>){
        self._path = path
        self._viewModel = State(initialValue: DetallePersonajeViewModel(personaje: personaje))
    }


    // private let apiService = ApiService()    //Lo hemos comentado porque en la Clase Apiservice lo hemos convertido a Singleton y ahora es ApiService.instancia y en la clase Apiservice es ahora: static let instancia = ApiService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: viewModel.personaje.image)) {
                    img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .overlay(alignment: .bottom) {
                    Text(viewModel.personaje.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                }
                if viewModel.isLoading {
                    ProgressView("Descargando datos...")
                        .frame(maxWidth: .infinity)
                } else if let detalle = viewModel.detalle {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Expediente #\(detalle.id)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Divider()

                        GridInfo(
                            titulo: "Especie",
                            valor: detalle.species,
                            icono: "cat.circle"
                        )
                        GridInfo(
                            titulo: "Género",
                            valor: detalle.gender,
                            icono: "person.fill.questionmark"
                        )
                        GridInfo(
                            titulo: "Origen",
                            valor: detalle.origin.name,
                            icono: "globe"
                        )
                        GridInfo(
                            titulo: "Ubicación",
                            valor: detalle.location.name,
                            icono: "mappin.and.ellipse"
                        )
                        GridInfo(
                            titulo: "Estado",
                            valor: detalle.status,
                            icono: "checkmark.circle"
                        )
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    //Lista de episodios
                    VStack(alignment: .leading) {
                        Text("Apariciones: \(viewModel.episodios.count)")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        ForEach(viewModel.episodios) {
                            episodio in
                            HStack {
                                Text(episodio.episode)
                                    .font(.caption)
                                    .padding(5)
                                    .background(.blue.opacity(0.2))
                                    .cornerRadius(5)
                                Text(episodio.name).font(.body)

                                Spacer()

                                Text(episodio.air_date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal)

                            Divider().padding(.horizontal)
                        }
                    }
                    // Lista de personajes relacionados

                    if !viewModel.personajesRelacionados.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Personajes relacionados")
                                .font(.title2.bold())
                                .padding(.horizontal)
                                .padding(.top)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.personajesRelacionados) {
                                        personaje in
                                        NavigationLink(
                                            value: personaje
                                                //           destination: VistaDetallePersonaje(
                                                //               personaje: personaje)
                                        ) {
                                            VStack {
                                                AsyncImage(
                                                    url: URL(
                                                        string: personaje.image
                                                    )
                                                ) {
                                                    img in
                                                    img.resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Color.gray.opacity(0.3)
                                                }
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .shadow(radius: 3)

                                                Text(personaje.name)
                                                    .font(.caption)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(
                                                        .center
                                                    )
                                                    .frame(width: 80)
                                                    .foregroundStyle(.primary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    //Resetea el Navigation path y vuelve a la vista principal
                    path = NavigationPath()
                } label: {
                    Image(systemName: "house.fill")
                }
            }
        }
        .task {
            await viewModel.cargarDatosCompletos()
        }
    }
}
struct GridInfo: View {
    let titulo: String
    let valor: String
    let icono: String

    var body: some View {
        HStack {
            Label(titulo, systemImage: icono)
                .foregroundStyle(.blue)
                .frame(width: 120, alignment: .leading)

            Text(valor)
                .bold()
        }
    }
}

#Preview {

    struct ContenedorPrevisualizacion: View {
        @State private var path = NavigationPath()
        let personaje = Personaje(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
        )

        var body: some View {
            NavigationStack(path: $path) {
                VistaDetallePersonaje(personaje: personaje, path: $path)
                    .navigationDestination(for: Personaje.self) {
                        personaje in
                        VistaDetallePersonaje(personaje: personaje, path: $path)
                    }
            }
        }
    }
    return ContenedorPrevisualizacion()
    //   VistaDetallePersonaje(personaje: personaje)
}
