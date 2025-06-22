//
//  ModalCard.swift
//  MyComponents
//
//  Created by Saverio Negro on 6/21/25.
//

import SwiftUI

public struct ModalCard: View {
    
    // MARK: - ModalCard.Button (Factory struct)
    public struct Button {
        
        enum ButtonType {
            case destructive(label: Text, action: () -> Void)
            case cancel(action: () -> Void)
        }
        
        public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
            return Button(type: .destructive(label: label, action: action))
        }
        
        public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
            return Button(type: .cancel(action: action))
        }
        
        @ViewBuilder
        fileprivate func render() -> some View {
            switch self.type {
            case .destructive(let label, let action):
                SwiftUI.Button(action: action, label: { label })
            case .cancel(let action):
                SwiftUI.Button(action: action, label: { Text("Cancel") })
            }
        }
        
        private var type: ButtonType
        
        private init(type: ButtonType) {
            self.type = type
        }
    }
    
    // MARK: - Properties
    let title: String
    let message: String
    let primaryButton: ModalCard.Button
    let secondaryButton: ModalCard.Button
    
    // MARK: - Init
    public init(
        title: String,
        message: String,
        primaryButton: ModalCard.Button,
        secondaryButton: ModalCard.Button
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                secondaryButton.render()
                primaryButton.render()
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 5)
        }
        .padding()
    }
}
