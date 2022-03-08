//
//  UrlData.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 07/03/22.
//

import Foundation

struct UrlData: Decodable {
    let colors: [String]
    let questions: [QuestionModel]
}

