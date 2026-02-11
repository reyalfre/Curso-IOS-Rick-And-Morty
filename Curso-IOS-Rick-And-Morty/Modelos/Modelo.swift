//
//  Modelo.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import Foundation

struct Personaje: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
}

//La API nos devuelve los personajes en un array de Personajes, dado que la API contiene el objeto results"
struct RespuestaAPI: Codable {
    let results: [Personaje]
}
