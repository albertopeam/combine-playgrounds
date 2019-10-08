//
//  ErrorView.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 13/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    let imageName: String
    let message: String
    let actionText: String
    let action: () -> Void
    
    init(imageName: String = "exclamationmark.triangle",
         message: String = "Something went wrong",
         actionText: String = "Retry",
         action: @escaping () -> Void) {
        self.imageName = imageName
        self.message = message
        self.actionText = actionText
        self.action = action
    }
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.red)
            Spacer().frame(height: 16)
            Text(message)
            Spacer().frame(height: 8)
            Button(action: {
                self.action()
            }, label: {
                Text(actionText)
                    .foregroundColor(.blue)
            })
        }
    }
}
