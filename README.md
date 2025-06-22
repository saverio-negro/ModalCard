# 03 - Slot-Based and Adaptive Layouts with `ModalCard` view

## Introduction

The `ModalCard` view component is meant to be a _reusable_ and _configurable_ modal by having it accept configurable parameters, both variables (state) and functions (behaviors); hence, an _adaptive_ layout that can be reused across apps.

Concepts being used in the `ModalCard` component build on top of the `Card` view component. Therefore, if you'd like to have a look at the `Card` view component before checking the `ModalCard`, head over to the <a href="https://github.com/saverio-negro/Card">Card View Component</a> Github project. It's quite a simple component, but you can take it as a groundwork for the `ModalCard` as well as more advanced components/frameworks I have coded.

## Component Description

As described above, the component is a reusable modal card with title, message, and customizable action slots.

While it's true that you can create your modal component depending on your purpose, my modal card is meant to better present confirmation dialogues or alerts with a customizable title and message, based on the specific scenario, as well as specific actions to perform upon confirmation or cancellation. However, this component shall serve you as a reference frame as far as how you will go about designing _your_ components based on the user experience needs.

With that out of the way, let's see how I implemented it, and why I came up with that specific solution. I'll walk you through the design-thinking process, and why this solution is _encapsulating_ and _scalable_.
Also, this is pretty _similar_ to the approach that Apple uses.

**Note**: Take into account the fact that we can't see the actual implementation used by Apple since SwiftUI is a **closed-source** framework. However, I'm using reverse engineering by inspecting objects at runtime using Xcode's LLDB, inferring the behavior by checking out Apple's documentation, as well as referencing Apple's public APIs. What I think is important is that, after having gone through this README, you may appreciate the design-thinking approach, even to building a simple API as a `ModalCard`, which is meant to lay the foundation for more complex SwiftUI architecture patterns.

### First Implementation Layer of `ModalCard` and Why this Approach is Scalable and Flexible

Before getting straight to the final implementation of `ModalCard`, I would like to start presenting you the first layer of my implementation, which starts being very general and generic. As I go about explaining it, I'll outline the pros and cons, and what would a solution be in terms of code design to face those cons.

The following is the first layer of my implementation for a reusable `ModalCard` view that uses a **slot-based** system (configurable content-slots/parameters) to accept a title, message, as well as actions to perform upon confirmation or cancellation:

```swift
public struct ModalCard<Primary: View, Secondary: View>: View {

  // MARK: - Properties

  let title: String
  let message: String
  let primaryAction: Primary
  let secondaryAction: Secondary

  // MARK: - Init
  
  public init(
    title: String,
    message: String,
    @ViewBuilder primaryAction: () -> Primary,
    @ViewBuilder secondaryAction: () -> Secondary
  ) {
    self.title = title
    self.message = message
    self.primaryAction = primaryAction()
    self.secondaryAction = secondaryAction()
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
              secondaryAction
              primaryAction
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
```

That's a mouthful, isn't it? Well, let's go through it:

```swift
public struct ModalCard<Primary: View, Secondary: View>: View {
```

1. The code snippet above uses the `public` access modifier so that users using our component from _outside_ the `ModalCard` module can tap into it. This is crucial to any reusable API you are building.

2. We use **parametric polymorphism** — simply known as **generics** — with our `ModalCard`, and all it does is define two _type parameters_ — `Primary` and `Secondary` — that we want this struct to work with. Essentially, these type parameters could be of any type, as long as they conform to the `View` protocol; in other words, they should be views. This is a powerful tool of Swift and many other programming languages out there (e.g., template classes in C++), which allows the code of our struct to work with any type, and those `Primary` and `Secondary` are two placeholders with the `View` type constraint applied to them `<Primary: View, Secondary: View>`. 

