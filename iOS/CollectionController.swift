import UIKit

class CollectionController: UICollectionViewController {
    var photos = Photo.constructElements()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.registerClass(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.Identifier)
    }
}

extension CollectionController {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCell.Identifier, forIndexPath: indexPath) as! PhotoCell
        if let photo = self.photos[indexPath.row] as? Photo {
            cell.text = String(photo.id)
            cell.image = photo.image
        }

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let existingCell = collectionView.cellForItemAtIndexPath(indexPath) {
            existingCell.alpha = 0

            guard let window = UIApplication.sharedApplication().delegate?.window?! else { return }

            let overlayView = UIView(frame: UIScreen.mainScreen().bounds)
            overlayView.backgroundColor = UIColor.blackColor()
            overlayView.alpha = 0
            overlayView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            window.addSubview(overlayView)

            let convertedRect = window.convertRect(existingCell.frame, fromView: self.collectionView!)
            let transformedCell = UIImageView(frame: convertedRect)
            transformedCell.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            transformedCell.contentMode = .ScaleAspectFill
            transformedCell.clipsToBounds = true

            if let photo = self.photos[indexPath.row] as? Photo {
                transformedCell.image = photo.image
                window.addSubview(transformedCell)

                let screenBound = UIScreen.mainScreen().bounds
                let scaleFactor = transformedCell.image!.size.width / screenBound.size.width
                let finalImageViewFrame = CGRectMake(0, (screenBound.size.height/2) - ((transformedCell.image!.size.height / scaleFactor)/2), screenBound.size.width, transformedCell.image!.size.height / scaleFactor)

                UIView.animateWithDuration(0.3, animations: {
                    overlayView.alpha = 1.0
                    transformedCell.frame = finalImageViewFrame
                    }, completion: { finished in
                        let viewerController = ViewerController(pageIndex: indexPath.row)
                        viewerController.controllerDelegate = self
                        viewerController.controllerDataSource = self
                        self.presentViewController(viewerController, animated: false, completion: {
                            transformedCell.removeFromSuperview()
                            overlayView.removeFromSuperview()
                        })
                })
            }
        }
    }
}

extension CollectionController: ViewerControllerDataSource {
    func viewerItemsForViewerController(viewerController: ViewerController) -> [ViewerItem] {
        return self.photos
    }
}

extension CollectionController: ViewerControllerDelegate {
    func viewerController(viewerController: ViewerController, didChangeIndexPath indexPath: NSIndexPath) {
    }

    func viewerControllerDidDismiss(viewerController: ViewerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
