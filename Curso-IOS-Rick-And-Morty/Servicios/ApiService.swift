//
//  ApiService.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import Foundation

enum NetworkError: Error {
    case urlInvalida
    case errorServidor(statusCode: Int)
    case errorDatos(detalle: String, errorOriginal: Error?)

    var description: String {
        switch self {
        case .urlInvalida:
            return "URL inválida"
        case .errorServidor(let statusCode):
            return "Error del servidor. Código de estado: \(statusCode)"
        case .errorDatos(let detalle, let errorOriginal):
            if let error = errorOriginal {
                return
                    "\(detalle). Error original: \(error.localizedDescription)"
            }
            return detalle
        }
    }
}

class ApiService {

    // Convertimos la clase a Singleton
    static let instancia = ApiService()
    private init(){
        
    }

    func obtenerPersonajes() async throws -> [Personaje] {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character")
        else {
            throw NetworkError.urlInvalida  //Luego cambiaremos a (statusCode: 0)
        }
        //Descargamos datos
        let (data, response) = try await URLSession.shared.data(from: url)

        //Comprobar si el servidor estaba activo
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.errorServidor(statusCode: 0)
        }
        // Comprobar si el estado es OK (200)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw NetworkError.errorServidor(
                statusCode: httpResponse.statusCode
            )
        }

        //Decodificación
        do {
            let respuesta = try JSONDecoder().decode(
                RespuestaAPI.self,
                from: data
            )
            return respuesta.results
        } catch {
            print("Error decodificando: \(error)")
            throw NetworkError.errorServidor(statusCode: 0)
        }
    }
    func obtenerDetallePersonaje(id: Int) async throws -> PersonajeDetalle {
        guard
            let url = URL(
                string: "https://rickandmortyapi.com/api/character/\(id)"
            )
        else {
            throw NetworkError.urlInvalida
        }

        //Descargamos datos
        let (data, response) = try await URLSession.shared.data(from: url)

        //Comprobar si el servidor estaba activo
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.errorServidor(statusCode: 0)
        }
        // Comprobar si el estado es OK (200)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw NetworkError.errorServidor(
                statusCode: httpResponse.statusCode
            )
        }

        //Decodificación
        do {
            let respuesta = try JSONDecoder().decode(
                PersonajeDetalle.self,
                from: data
            )
            return respuesta
        } catch {
            print("Error decodificando: \(error)")
            throw NetworkError.errorDatos(
                detalle:
                    "No se ha podido interpretar la respuesta del servidor.",
                errorOriginal: error
            )
        }
    }
    func obtenerEpisodios(urls: [String]) async throws -> [Episodio] {
        guard !urls.isEmpty else { return [] }

        // 1º Extraer los IDs de las URLs
        // Convertir "https://../episode/10" -> "10"
        // TODO: eliminar
        let ids = urls.compactMap { urlString -> String? in
            return urlString.split(separator: "/").last?.description
        }.joined(separator: ",")  // Resultado: ids = 10,11,15

        guard
            let url = URL(
                string: "https://rickandmortyapi.com/api/episode/\(ids)"
            )
        else {
            throw NetworkError.urlInvalida
        }

        //Descargamos datos
        let (data, response) = try await URLSession.shared.data(from: url)

        //Comprobar si el servidor estaba activo
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.errorServidor(statusCode: 0)
        }
        // Comprobar si el estado es OK (200)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw NetworkError.errorServidor(
                statusCode: httpResponse.statusCode
            )
        }
        // 3º Decodificacion
        if let variosEpisodios = try? JSONDecoder().decode(
            [Episodio].self,
            from: data
        ) {
            return variosEpisodios
        }
        // A veces un personaje aparece en un solo episodio y la API devuelve un objeto, no un array.
        else if let unEpisodio = try? JSONDecoder().decode(
            Episodio.self,
            from: data
        ) {
            return [unEpisodio]
        }
        throw NetworkError.errorDatos(
            detalle: "Formato no reconocido",
            errorOriginal: nil
        )
    }
    func obtenerPersonajesPorIds(ids: [Int]) async throws -> [Personaje] {
        guard !ids.isEmpty else { return [] }

        let idsString = ids.map {
            String($0)
        }.joined(separator: ",")

        guard
            let url = URL(
                string: "https://rickandmortyapi.com/api/character/\(idsString)"
            )
        else {
            throw NetworkError.urlInvalida
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // return []
        //Comprobar si el servidor estaba activo
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.errorServidor(statusCode: 0)
        }
        // Comprobar si el estado es OK (200)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw NetworkError.errorServidor(
                statusCode: httpResponse.statusCode
            )
        }

        // 3º Decodificacion
        if let variosPersonajes = try? JSONDecoder().decode(
            [Personaje].self,
            from: data
        ) {
            return variosPersonajes
        }
        // A veces un personaje aparece en un solo episodio y la API devuelve un objeto, no un array.
        else if let unPersonaje = try? JSONDecoder().decode(
            Personaje.self,
            from: data
        ) {
            return [unPersonaje]
        }
        throw NetworkError.errorDatos(
            detalle: "Formato no reconocido",
            errorOriginal: nil
        )
    }

}
