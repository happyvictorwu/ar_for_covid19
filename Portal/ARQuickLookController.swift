import QuickLook
import UIKit

class ARQuickLookController: UIViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let modelNames = ["COVID-19-1", "COVID-19-2", "COVID-19-struct"]
    var modelImages = [UIImage]()
    var modelIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Store Images
        for modelName in modelNames {
            if let modelImage = UIImage(named: "\(modelName).jpg") {
                modelImages.append(modelImage)
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryReusableCell")! as! GalleryTableViewCell
        
        cell.modelImage.image = modelImages[indexPath.row]
        cell.modelName.text = modelNames[indexPath.row] + " model"
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelIndex = indexPath.row
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        present(previewController, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 2
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = Bundle.main.url(forResource: modelNames[modelIndex], withExtension: "usdz")!
        return url as QLPreviewItem
    }
}
