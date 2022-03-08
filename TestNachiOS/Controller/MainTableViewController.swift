//
//  ViewController.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 07/03/22.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD


class MainTableViewController: UITableViewController {
    
    let textDescription = "Una gráfica o representación gráfica es un tipo de representación de datos, generalmente numéricos, mediante recursos visuales (líneas, vectores, superficies o símbolos), para que se manifieste visualmente la relación matemática o correlación estadística que guardan entre sí. También es el nombre de un conjunto de puntos que se plasman en coordenadas cartesianas y sirven para analizar el comportamiento de un proceso o un conjunto de elementos o signos que permiten la interpretación de un fenómeno. La representación gráfica permite establecer valores que no se han obtenido experimentalmente sino mediante la interpolación (lectura entre puntos) y la extrapolación (valores fuera del intervalo experimental)."
    
    var imagePicker = UIImagePickerController()
    var profilePic: UIImage?
    var urlStringProfilePic: String?
    let backgroundColorRef = Database.database().reference().child("backgroundColor")
    var userName: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNibs()
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundColorRef.observe(DataEventType.value, with: { snapshot in
            if let color = snapshot.value{
                self.view.backgroundColor = hexStringToUIColor(hex: color as? String ?? "#ffffff")
            }
        })
    }
    
    func registerNibs(){
        tableView.register(UINib(nibName: "TextFieldCell", bundle: Bundle.main), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "ProfilePicCell", bundle: Bundle.main), forCellReuseIdentifier: "ProfilePicCell")
        tableView.register(UINib(nibName: "ButtonCell", bundle: Bundle.main), forCellReuseIdentifier: "ButtonCell")
    }
    
    @objc func sendButton(_ sender: AnyObject) {
        if let name = self.userName, let _ = self.profilePic{
            if name != ""{
                self.uploadToStorage(userName: name)
                self.userName = nil
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "Debes ingresar tu nombre y fotografía", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeColor(_ sender: Any) {
        self.presentAlertController()
    }
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Color", message: "Introducir en hexadecimal (#ffffff)",preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "#ffffff"
        }
        let continueAction = UIAlertAction(title: "Cambiar color", style: .default) { [weak alertController] _ in
                guard let textFields = alertController?.textFields else { return }
                if let hexCode = textFields[0].text{
                    self.backgroundColorRef.setValue(hexCode)
                }
        }
        alertController.addAction(continueAction)
        self.present(alertController,
                     animated: true)
    }
    
}

extension MainTableViewController: UITextFieldDelegate{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.selectionStyle = .none
            cell.textField.delegate = self
            cell.textField.placeholder = "Ingresa tu nombre"
            return cell
        }else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePicCell
            cell.selectionStyle = .none
            cell.addButton.addTarget(self, action:#selector(PressedButton(_:)), for:.touchUpInside)
            if let pic = profilePic{
                cell.imagePic.layer.masksToBounds = false
                cell.imagePic.layer.cornerRadius = cell.imagePic.frame.height/2
                cell.imagePic.clipsToBounds = true
                cell.imagePic.image = pic
            }
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = self.textDescription
            cell.textLabel?.numberOfLines = 0
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            cell.sendButton.addTarget(self, action:#selector(sendButton(_:)), for:.touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 2){
            let vc = GraphicsViewController()
            self.navigationController?.show(vc, sender: nil)
        }
        
    }
    
    // MARK:- ---> Textfield Delegates

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called\(String(describing: textField.text))")
        self.userName = textField.text!
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z].*", options: [])
            if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                return false
            }
        }
        catch {
            print("ERROR")
        }
        return true;
    }
}

extension MainTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
    @objc func PressedButton(_ sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "Seleccionar imagen", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camara", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera(UIImagePickerController.SourceType.camera)
        }
        let gallaryAction = UIAlertAction(title: "Galería", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera(UIImagePickerController.SourceType.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        // Add the actions
        imagePicker.delegate = self as UIImagePickerControllerDelegate &    UINavigationControllerDelegate
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let profileImageFromPicker = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                self.profilePic = profileImageFromPicker
                self.tableView.reloadData()
    }
    
    func uploadToStorage(userName: String){
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageData = self.profilePic!.jpegData(compressionQuality: 0.05)
        
        let store = Storage.storage()
        let storeRef = store.reference().child("users/\(userName).jpg")
        ProgressHUD.show()
        let _ = storeRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            ProgressHUD.dismiss()
            if error != nil{
                print("error occurred: \(error.debugDescription)")
            }
            else
            {
                let alert = UIAlertController(title: "Exito", message: "Carga exitosa a Storage", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                storeRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                        self.urlStringProfilePic = profileImageUrl
                    }
                })
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerController cancel")
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


