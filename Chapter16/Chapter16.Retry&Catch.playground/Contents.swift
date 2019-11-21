import UIKit
import Combine

let api = PhotoService()
var subscriptions = Set<AnyCancellable>()

api.fetchPhoto(quality: .high)
    .handleEvents(receiveSubscription: { _ in print("Trying ...") },
                  receiveCompletion: {
                    guard case .failure(let error) = $0 else { return }
                    print("Got error: \(error)")
    })
    .retry(3) // +3 retries extra, if no success in any then propagate downstream the error
    .catch({ (error) -> PhotoService.Publisher in
        print("Fetching low quality, catched error")
        return api.fetchPhoto(quality: .low) // if after the retries we still have an error, catch will perform another request but this time in low quality, if fails, then will go for replaceError otherwise final success
    })
    .replaceError(with: UIImage(named: "na.jpg")!) // if after retries we have a Error, it will be replaced with the supplied image
    .sink(receiveCompletion: { (completion) in
        print(completion)
    }) { (image) in
        image
        print(image)
    }.store(in: &subscriptions)
