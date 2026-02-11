//
//  ApiService.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import Foundation

enum NetworkError: Error {
    case urlInvalida
    case errorServidor
    case errorDatos
}

class ApiService {
    func obtenerPersonajes() async throws -> [Personaje] {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character")
        else {
            throw NetworkError.errorServidor  //Luego cambiaremos a (statusCode: 0)
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw NetworkError.errorServidor
        }
        do {
            let respuesta = try JSONDecoder().decode(RespuestaAPI.self, from: data)
            return respuesta.results
        } catch {
            print("Error decodificando: \(error)")
            throw NetworkError.errorDatos
        }
    }
}
