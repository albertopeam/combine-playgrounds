/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Combine

class MainViewController: UIViewController {
  
    // MARK: - Outlets

    @IBOutlet weak var imagePreview: UIImageView! {
        didSet {
            imagePreview.layer.borderColor = UIColor.gray.cgColor
        }
    }
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!

    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let images = CurrentValueSubject<[UIImage], Never>([])

    // MARK: - View controller

    override func viewDidLoad() {
        super.viewDidLoad()
        let collageSize = imagePreview.frame.size
        images
            .handleEvents(receiveOutput: { [weak self] in self?.updateUI(photos: $0) }) // perform side effects
            .map({ UIImage.collage(images: $0, size: collageSize)})
            .assign(to: \.image, on: imagePreview)
            .store(in: &subscriptions)
    }

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    // MARK: - Actions

    @IBAction func actionClear() {
        images.value = []
    }

    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        let photoWritter = PhotoWriter()
        photoWritter
            .save(image)
            .sink(receiveCompletion: { [weak self] (completion) in
                guard let self = self else { return }
                if case let .failure(error) = completion {
                    self.showMessage("Error", description: error.localizedDescription)
                }
            }) {  [weak self] (id) in
                guard let self = self else { return }
                self.showMessage("Saved with id: \(id)")
            }.store(in: &subscriptions)
    }

    @IBAction func actionAdd() {
        if let viewController = storyboard?.instantiateViewController(identifier: String(describing: PhotosViewController.self)) as? PhotosViewController,
            let navigationController = navigationController {
            
            let selectedPhotos = viewController
                .selectedPhotos
                .print()
                .prefix(while: { [unowned self] _ in self.images.value.count < 6 }) // it will only let elements passthrough while the predicate is true, so only 6 images will be allowed
                .filter({ $0.isLandscape })
                .share()
            
            // it will pop the ViewController when the photo count reaches 6 items
            selectedPhotos
                .ignoreOutput()
                .filter({ [unowned self] _ in
                    self.images.value.count == 6
                })
                .sink(receiveCompletion: { [unowned self] (completion) in
                    self.navigationController?.popViewController(animated: true)
                }, receiveValue: { _ in })
                .store(in: &subscriptions)
            
            // it will assign the selected images to the current images
            selectedPhotos
                .map({ [unowned self] in self.images.value + [$0] })
                .sink(receiveValue: { [unowned self] in self.images.value = $0 })
                .store(in: &subscriptions)
                     
            // it will wait 2 secs before writing the total count of photos
            selectedPhotos
                .ignoreOutput() // it will ignore all events except finish and error
                .delay(for: 2.0, scheduler: DispatchQueue.main)
                .sink(receiveCompletion: { [unowned self] _ in
                    self.updateUI(photos: self.images.value)
                }, receiveValue: { _ in
                    // it will never be executed
                })
                .store(in: &subscriptions)
            
            // it will write the number of selected photos each time we choose a photo
            viewController.$selectedPhotosCount
                .filter({ $0 > 0 })
                .map({ "Selected photos \($0)" })
                .assign(to: \.title, on: self)
                .store(in: &subscriptions)
            
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    private func showMessage(_ title: String, description: String? = nil) {
        alert(title, description: description)
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
}
