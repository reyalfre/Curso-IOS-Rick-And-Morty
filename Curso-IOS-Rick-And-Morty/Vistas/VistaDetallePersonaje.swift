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
    @State private var episodios: [Episodio] = []
    @State private var personajesRelacionados: [Personaje] = []

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
                        .frame(maxWidth: .infinity)
                } else if let detalle = detalle {
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
                        Text("Apariciones: \(episodios.count)")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        ForEach(episodios) {
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

                    if !personajesRelacionados.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Personajes relacionados")
                                .font(.title2.bold())
                                .padding(.horizontal)
                                .padding(.top)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(personajesRelacionados) {
                                        personaje in
                                        NavigationLink(
                                            destination: VistaDetallePersonaje(
                                                personaje: personaje
                                            )
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
                                                    .multilineTextAlignment(.center)
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
    let personaje = Personaje(
        id: 1,
        name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
    )
    VistaDetallePersonaje(personaje: personaje)
}
