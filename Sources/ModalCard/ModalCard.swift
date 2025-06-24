//
//  ModalCard.swift
//  MyComponents
//
//  Created by Saverio Negro on 6/21/25.
//

import SwiftUI

public struct ModalCard: View {

  // MARK: - `ModalCard.Button` factory struct

  public struct Button {

    // Exposed factory methods

    public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
      return Button(type: .destructive(label: label, action: action))
    }

    public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
      return Button(type: .cancel(action: action))
    }

    // Rendering method exposed to `ModalCard`
    @ViewBuilder
    fileprivate func render() -> some View {
      switch self.type {
      case .destructive(let label, let action):
        SwiftUI.Button(action: action, label: { label })
      case .cancel(let action):
        SwiftUI.Button(action: action, label: { Text("Cancel") })
      }
    }

    // Encapsulated behaviors
    
    private enum ButtonType {
      case destructive(label: Text, action: () -> Void)
      case cancel(action: () -> Void)
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
          
          HStack(spacing: 15) {
              secondaryButton.render()
              primaryButton.render()
          }
          .padding()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    )
    .padding()
  }
}
