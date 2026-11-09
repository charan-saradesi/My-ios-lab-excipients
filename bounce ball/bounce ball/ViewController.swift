import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        UIView.animate(withDuration: 1, animations: {
            // 1. Move the ball up by 200 points
            self.imageView.frame.origin.y -= 200
        }) { _ in
            // 2. Once the first move is done, start the bouncing/repeating animation
            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                self.imageView.frame.origin.y += 200
            }, completion: nil)
        }
    }

}
