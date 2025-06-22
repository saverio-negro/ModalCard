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

### First Implementation Layer of `ModalCard`

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

2. We use **parametric polymorphism** — simply known as **generics** — with our `ModalCard`, and all it does is define two _type parameters_ — `Primary` and `Secondary` — that we want this struct to work with. Essentially, these type parameters could be of any type, as long as they conform to the `View` protocol; in other words, they should be views. This is a powerful tool of Swift and many other programming languages out there (e.g., template classes in C++), which allows the code of our struct to work with any type, and those `Primary` and `Secondary` are two placeholders with the `View` type constraint applied to them `<Primary: View, Secondary: View>`. However, why would we need it? That's because the `ModalCard` view component needs to declare two slots (properties) — our Primary and Secondary views, which are meant to be actions — so that the user of the component can decide what goes in there. In Object-Oriented Programming (OOP), this is also called **Object Composition**, and generics just allows us to define the type of objects — `View` objects (`Primary` and `Secondary`), in our case — with which to compose our `ModalCard` struct. In this case, because we are defining the slots of our modal card (e.g., title, message, etc.), we can also name this procedure as **slot-based view composition**, since we are defining two additional properties (slots) on the `ModalCard` struct to be two objects `primaryAction` and `secondaryAction` of type `Primary` and `Secondary`, both conforming to the `View` protocol.

3. Finally, the `ModalCard` struct itself conforms to the `View` protocol, since it's meant to be a `View` that can be rendered from within the `body` property of any other `View` object.

Next up,

```swift
// MARK: - Properties

  let title: String
  let message: String
  let primaryAction: Primary
  let secondaryAction: Secondary
```

In the code above, we define our properties, which are the slots of our `ModalCard` object in which the user can pass its content, and reuse and adapt it based on their needs.
That includes the `Primary` and `Secondary` views, which are meant to be primary and secondary actions; more specifically, buttons that the user can define their behavior for, and pass to the modal card.

Let's have a look at the next code snippet and see how we allow the user to pass over this information with our custom initializer:

```swift
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
```

We are essentially defining four parameters for the `ModalCard` constructor/initializer. However, the ones we are most interested in are the `primaryAction` and `secondaryAction` parameters. Their type annotation entails a function that doesn't take any parameter and returns either a `Primary` or `Secondary` type. That will allow the user to pass any function under `primaryAction` and `secondaryAction` parameters — usually in the form of a closure — which allows for reusability and adaptability: they can return any object of type `View` from the closure, even multiple child views, and the `@ViewBuilder` property wrapper will bundle those views into a `TupleView` object. 

**Note**: I explain the `@ViewBuilder` property wrapper in the last component; namely, the <a href="https://github.com/saverio-negro/Card">Card View Component</a>. Make sure to check it out!

In the code block relative to the constructor, we assign to `primaryAction` and `secondaryAction` properties the views being returned by the user-defined functions — which are passed to `ModalCard` upon its instantiation; in fact, notice that we are calling them — `primaryAction()` and `secondaryAction()` — since the initializer is passed a reference of those functions in memory, and to run their associated code blocks, we need to invoke them, which entails appending a set of parentheses; only then will we make sure that the properties are assigned the actual `View` objects, and not the functions themselves.

Finally, we have the following code:

```swift
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
```

Now, I assume that, if you have come here to know a bit more about the SwiftUI architecture and how to build your own SwiftUI APIs, you must have some groundwork of basic SwiftUI. That means I won't go with an in-depth explanation for each modifier; instead, I want to describe at a higher level what's happening in the code snippet above.

We are trying to build a card-like UI, where we define `Text` views displaying the values for our `title` and `message` properties. We then define a `RoundedRectangle` shape as a background to our `VStack` view.

What's interesting is the content in our `HStack`. We are returning the `View` objects defined by the user and stored on the `primaryAction` and `secondaryAction` properties. We are assuming that `primaryAction` stores a button with a _destructive_ role (right-hand side), while `secondaryAction` stores one with a _cancel_ role (left-hand side).

### Pros and Cons of the Above Implementation

Now that we have gone over the first implementation layer for our `ModalCard` component, if you are a detail-oriented person, you might have noticed some cons to this implementation, especially after telling you that I meant for this card view to display buttons for actions to perform.

Then, in an ideal world, an upright user that would read the documentation attached to my SwiftUI component would know what to do and use the `ModalCard` view API much like the following:

```swift
ModalCard(
    title: "Delete Account",
    message: "This action cannot be undone.",
    primaryAction: {
        Button("Delete") {
            print("Delete")
        }
    },
    secondaryAction: {
        Button("Cancel") {
            print("Cancel")
        }
    }
)
```

This is how the `ModalCard` should be used, and `primaryAction` and `secondaryAction` should be assigned functions returning `Button` objects.

However, there are some cons to this, and if you are reasoning through things like a framework designer, you might notice that we are actually allowing the user to pass over to the `ModalCard` constructor whichever `View` objects they want. That means that someone could pass in a `Text`, an `Image`, or even a `ProgressView`, and our component wouldn't complain!

For instance, this is weird, yet legal:

```swift
ModalCard(
    title: "Oops",
    message: "This modal has weird content.",
    primaryAction: {
        Image(systemName: "xmark.circle")
    },
    secondaryAction: {
        Text("Not really a button")
    }
)
```

If our intention was just to allow buttons, then the code above is nonsensical, isn't it?

Then why use it?

Let me walk you through this, and that's where things get hotter and more interesting.

There's actually a clear trade-off here, which is a very common one for framework engineers:

1. Using `View` (generic):
   - **Pros**: Very flexible and allows the component to be extremely adaptive.
   - **Cons**: No constraints defined, which may lead to misuse and nonsensical behaviors.

2. Using a restricted type (e.g., `Button`):
   - **Pros**: Forces intended usage.
   - **Cons**: Reduces flexibility (e.g., custom-styled buttons, or conditional logic).

So, I'll tell you right off the bat that Apple leans towards the first approach, which is using generics, but with a more clever implementation that allows for encapsulation, flexibility, and scalability.

However, before showing you how I would add a second layer to our current version of `ModalCard` to come up with a more Apple-like version, I want to first point out to you why using a restricted type (2. approach) is very limiting, which I suggest you not go for it.

### Implementing `ModalCard` with a Restricted-Type Approach (Not Recommended)

So, I'm just showing you this restricted-type approach to stress over the fact that you shouldn't use it.

Take the following implementation of `ModalCard` using this approach, which enforces the user of the component to pass over a `Button` under the `primaryAction` and `secondaryAction` parameters:

```swift
public struct ModalCard: View {

  // MARK: - Properties

  let title: String
  let message: String
  let primaryAction: Button<Text>
  let secondaryAction: Button<Text>

  // MARK: - Init
  
  public init(
    title: String,
    message: String,
    primaryAction: Button<Text>,
    secondaryAction: Button<Text>
  ) {
    self.title = title
    self.message = message
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
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

The code above is almost similar to the generic implementation, but we are now forcing a type of `Button<Text>` to be passed by the user, which is now meeting the expectations of our `ModalCard` components, and forces consistent UI logic across the view. However, we can't pass styled buttons, or any other type of buttons. For instance, a `Button` with an `Image` and `Text` isn't allowed. Therefore, it doesn't support cases where our buttons might be more complex than `Button<Text>`.

For instance, this button wouldn't be allowed for the restricted-type implementation:

```swift
Button {
    print("OK")
} label: {
    Label("OK", systemImage: "checkmark")
}
```

That's because that's not a `Button<Text>` type; rather, it's a `Button<Label<Text, Image>>` type.

Furthermore, this other implementation would also be restrictive, which is pretty similar to the one I showed you right above, with the only difference being that we are to decide which type of `Button` to store, and limit the user to defining just the action of those buttons.

```swift
public struct ModalCard: View {

  // MARK: - Properties

  let title: String
  let message: String
  let primaryAction: Button<Text>
  let secondaryAction: Button<Text>

  // MARK: - Init
  
  public init(
    title: String,
    message: String,
    primaryAction: @escaping () -> Void,
    secondaryAction: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.primaryAction = Button("Delete", action: primaryAction)
    self.secondaryAction = Button("Cancel", action: secondaryAction)
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

### Second Layer to our `ModalCard`: Providing Encapsulation and Predictiveness (Recommended)

You now see why I don't suggest using the restricted-type approach; instead, I got you covered with a better generic approach: I will turn my first implementation layer to `ModalCard` into a much more predictive solution, which restricts the choice to the kinds of options that we'd like the user to choose out of; in other words, we control which options are given to the user. This is also scalable, because we are going to update our `ModalCard` struct in such a way that, in later versions of our API, we can also add further options. You will also see how we can abstract away the need for the user to pass over the entire `View` object, and encapsulate the nitty-gritty to provide the user with a better and cleaner interface to deal with.

The following is an approach similar to Apple; that is, Apple provides full `View` flexibility, while documenting the expected usage, and coming up with convenience overloads for pre-defined options.

Before starting, I took inspiration from one of the native SwiftUI components; namely, the `Alert` view. I wanted to build something similar, so I started reverse-engineering it. The initializer of the `Alert` struct that I took inspiration from is the following:

```swift
Alert(
  title: Text("My inspiration component"),
  primaryButton: .destructive(Text("Delete"), action: {}),
  secondaryButton: .cancel()
)
```

Actually, many of SwiftUI's native components are built using a similar pattern.

Go into Xcode, or your Swift playground, and try it. You'll notice that either under `primaryButton`, or `secondaryButton`, you are provided options.

Whenever you write `.<option>`, just know that you are most likely tapping into either a `static` method, or a `static` computed property. `static` is the key, because it allows for abstraction, and encapsulation of the main code that actually creates those buttons, and the user is provided with a pre-defined interface where they just need to type in the related contents, under specific parameters.

Also, if you peek into the type of the `primaryButton` parameter, you'll read `Alert.Button`, which means that Apple has build a custom `Button` struct inside of the `Alert` struct, which is totally different from the `SwiftUI.Button` type, our good ol' button.

That means that when you type `.destructive(...)`, you are tapping into a specific `static` method on the `Button` struct within the `Alert` struct (`Alert.Button`), and that's the one that builds that specific kind of button with a _destructive_ role.

Therefore, our `Alert.Button` struct is such that it controls which `Button` type to be returned depending on which `static` method the user taps into.

As a side node, a `static` method or property, is such that it belongs to the `struct` or `class` object itself, and not to any of their instances. However, since a `static` property belongs to the type object itself, any instances of that type (e.g., `Alert`) can tap into that `static` property, which also means that's being shared among all instances of that type.

With that out of the way, let's look at how we would go about implementing a **predictive**, **safe**, and **encapsulating** approach similar to Apple-style APIs. However, I'll also show you why, for our implementation, we won't need to make use of generics; instead, we will expose a **high-level**, **semantic** **API** that reads nicer — much like the `Alert.Button.destructive(...)` semantic — using a common design pattern used by Apple: the **Static Factory Method** Design Pattern, strategized and supported with our dear `enum` friend.

First off, let me show you why you wouldn't want to use **generics** when implementing a supporting struct that applies the Factory Method design pattern. 

However, before we do this, let's actually create this supporting struct to our `ModalCard` view, much similar to how Apple builds it within the native `Alert` struct — `Alert.Button`.

```swift
public struct ModalCard<Primary: View, Secondary: View>: View {

  // MARK: - Properties

  let title: String
  let message: String
  let primaryButton: Primary
  let secondaryButton: Secondary

  // MARK: - Init
  
  public init(
    title: String,
    message: String,
    primaryButton: Primary,
    secondaryButton: Secondary
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
              secondaryButton
              primaryButton
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

Since the `Button` struct is meant to support the `ModalCard` struct, and relates to it, I define it within the `ModalCard` struct. Yes, that's a common pattern for when you have a type that associates with and belongs to another one. In this example case, `Button` is going to be part of the `ModalCard` struct and is going to be a completely different `struct` from our native `SwiftUI.Button`; in that, `ModalCard.Button` is our **Factory struct**, which provides **semantic API surface** and **encapsulates** the internal implementation detail from API users.

Notice that I also changed the name of our properties from `primaryAction` and `secondaryAction` to `primaryButton` and `secondaryButton`, since our implementation is fully predictive and we know what to expect from the user; that's because we are now to decide and implement the options as well as what to return internally — `Button` objects, in our case — via our new interface.
















