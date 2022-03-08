//
//  Questions.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 07/03/22.
//

import Foundation

struct QuestionModel: Decodable{
    let total: Int
    let text: String
    let chartData : [ChartModel]
}

struct ChartModel: Decodable{
    let text: String
    let percetnage: Int
}
