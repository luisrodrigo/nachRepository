//
//  DataManager.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 07/03/22.
//

import Foundation

protocol urlDataDelegate{
    func getQuestions(content: UrlData)
    func didFailWithError(error: Error)
}

struct DataManager {
    
    let baseURL = "https://us-central1-bibliotecadecontenido.cloudfunctions.net/helloWorld"
    
    var delegate: urlDataDelegate?
    
    func performaRequest(){
        if let url = URL(string: baseURL){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                    delegate?.didFailWithError(error: error!)
                }
                if let safeData = data{
                    if let content = parseJSON(urlData: safeData){
                        self.delegate?.getQuestions(content: content)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(urlData: Data) -> UrlData?{
        let decoder = JSONDecoder()
        do{
            let dataDecoder = try decoder.decode(UrlData.self, from: urlData)
            let json = dataDecoder
                return json
            }catch{
            print(error)
                return nil
        }
    }

}
