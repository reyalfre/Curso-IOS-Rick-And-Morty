//
//  Modelo.swift
//  Curso-IOS-Rick-And-Morty
//
//  Created by Equipo 8 on 11/2/26.
//

import Foundation

struct Personaje: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
}

struct LocationData: Codable {
    let name: String
    let url: String
}
struct PersonajeDetalle: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String

    let type: String
    let gender: String
    let origin: LocationData
    let location: LocationData
    let episode: [String]  //La api devuelve un array de URLs ["/ep1", "/ep2", ...]
}

struct Episodio: Codable, Identifiable {
    let id: Int
    let name: String
    let episode: String
    let air_date: String
    let characters: [String]  // URLs de los personajes que salen en el episodio

}

//La API nos devuelve los personajes en un array de Personajes, dado que la API contiene el objeto results"
struct RespuestaAPI: Codable {
    let results: [Personaje]
}
