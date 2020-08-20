import UIKit

class GalleryTableViewCell: UITableViewCell {
  @IBOutlet weak var modelImage: UIImageView!
  @IBOutlet weak var modelName: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
