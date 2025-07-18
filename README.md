# 03 - Slot-Based and Adaptive Layouts with `ModalCard` view

<img src="./ModalCard.gif" width="25%"/>

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
  let primaryButton: Primary
  let secondaryButton: Secondary

  // MARK: - Init
  
  public init(
    title: String,
    message: String,
    primaryButton: ModalCard.Button,
    secondaryButton: ModalCard.Button
  ) {
    self.title = title
    self.message = message
    self.primaryButton = primaryButton.render() as! Primary
    self.secondaryButton = secondaryButton.render() as! Secondary
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
Let me walk you through it, step-by-step:

```swift
public struct ModalCard<Primary: View, Secondary: View>: View {
  public struct Button {
```

1. Since the `Button` struct is meant to support the `ModalCard` struct, and relates to it, I define it within the `ModalCard` struct. Yes, that's a common pattern for when you have a type that associates with and belongs to another one. In this example case, `Button` is going to be part of the `ModalCard` struct and is going to be a completely different `struct` from our native `SwiftUI.Button`; in that, `ModalCard.Button` is our **Factory struct**, which provides a **semantic API surface** and **encapsulates** the internal implementation detail from the users of our `ModalCard` API.

```swift
// MARK: - Properties

  let title: String
  let message: String
  let primaryButton: Primary
  let secondaryButton: Secondary
```

2. Notice that I also changed the name of our properties from `primaryAction` and `secondaryAction` to `primaryButton` and `secondaryButton`, since our implementation is fully predictive and we know what to expect from the user; that's because _we_ are now to decide and implement the options as well as what to return internally — `Button` objects, in our case — via our new interface.

```swift
// Within the `ModalCard.Button` struct

enum ButtonType {
  case destructive(label: Text, action: () -> Void)
  case cancel(action: () -> Void)
}
```

3. Why define a helper `ButtonType` `enum`? Well, an `enum` is a supporting strategy to our Factory Method Design Pattern. It serves as a bridging between the `ModalCard` and `ModalCard.Button` to communicate which `SwiftUI.Button` to render within the `body` property at due time. This pattern is also used by SwiftUI to allow communication between factory structs (e.g., `Font`), and the appropriate modifier (e.g., `.font()` modifier) of type `ViewModifier`, as the SwiftUI likely uses an `enum` or `descriptor` to talk to the `ViewModifier` for it to know which `TextStyle` to apply, for example, which will eventually be written to the environment of the `View` object the `.font()` modifier gets called on. We are using the same pattern here, and we will eventually have the `ModalCard.Button` factory struct return a `ModalCard.Button` instance holding the configuration info as to what type of button to render. Also, notice that I have defined two cases for the `ButtonType` enum: `destructive`, and `cancel`. Both of them have associated values because we need to store information being passed by the users of the API; namely, either the `action` to perform, as well as the `label` for our buttons.

```swift
// Within the `ModalCard.Button` struct

// Inner Workings of `ModalCard.Button`, which are abstracted away from the user
private type: ButtonType

private init(type: ButtonType) {
  self.type = type
}
```

4. Then, I go about designing the internals of the `ModalCard.Button` struct. They are encapsulated by making use of the `private` access modifier. I go about defining how each `Button` instance is created, as well as its instance members — `type` property. The `ModalCard.Button` instance will be assigned a value to its `type` property upon its instantiation, depending on which `static` method the user calls. This is how we know which `SwiftUI.Button` to render.

```swift
// Within the `ModalCard.Button` struct

// User option for `destructive` role (semantic API user interface)
public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
  return Button(type: .destructive(label: label, action: action))
}

// User option for `cancel` role (semantic API user interface)
public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
  return Button(type: .cancel(action: action))
}
```

5. Finally, our precious `static` factory methods. Obviously, we define them with a `public` access modifier, as they need to be used by our users from outside the `ModalCard` module. Each factory method produces an instance of `ModalCard.Button` and passes over the relative value to its `type` property of type `ButtonType`. Also, we get to define the proper associated values for our `enum`, depending on the case. Those associated values are important because they allow us to gather information from the user, which will then be passed to the constructor of the `SwiftUI.Button`. Let me show you how I built the instance method to render the appropriate `SwiftUI.Button` object.

```swift
// Within the `ModalCard.Button` struct

@ViewBuilder
fileprivate func render() -> some View {
  switch self.type {
    case destructive(let label, let action):
      SwiftUI.Button(action: action, label: { label })
    case cancel(let action):
      SwiftUI.Button(action: action, label: { Text("Cancel") })
  }
}
```
6. In order to render our `SwiftUI.Button` view, I created an instance method called `render`. Notice how I gave it a `fileprivate` access modifier. Can you guess why? Well, this method needs to be called from within the `body` property of the `ModalCard` struct, so we made it private to the _file_, and not to the `ModalCard.Button` _struct_ itself. The `some View` opaque return type is **key** to scalability of our `ModalCard` component, on top of being the main reason why I avoided using generics, as I have previously mentioned. I'll explain to you in a second.

### Why Avoid Using Generics

At this point, If you tried building your `ModalCard` object using the version that uses **generics**, which I lastly shared with you,

```swift
import ModalCard

ModalCard(
    title: "Delete Account",
    message: "This action cannot be undone.",
    primaryButton: .destructive(
        Text("Delete"),
        { print("Delete") }
    ),
    secondaryButton: .cancel(
        { print("Cancel") }
    )
)
```
it won't work, and that's due to how we structured our Factory struct (`ModalCard.Button`); specifically, our `render()` method.

We are currently using our `render()` method inside the initializer of our `ModalCard` to assign _whichever_ object of type `View` is being returned from it to both `primaryButton`, and `secondaryButton`.
Then, I force-cast that returned type to the `Primary` and `Secondary` generic types, because those are the types we declared our properties to be.

```swift
// Within the `ModalCard` struct
public init(
  title: String,
  message: String,
  primaryButton: ModalCard.Button,
  secondaryButton: ModalCard.Button
) {
  self.title = title
  self.message = message

  // Force casting an opaque type to a generic type
  self.primaryButton = primaryButton.render() as! Primary
  self.secondaryButton = secondaryButton.render() as! Secondary
}
```

You might ask to yourself, "Well, we know that what's returned by the `render()` method is some object of type `View`, and we also know that either the `Primary` or `Secondary` generic type are some types conforming to the `View` protocol, so what's the problem with force-casting?"

Well, I know that it might sound plausible, but it actually isn't, and I'll explain to you why.

#### The Problem with `as! Primary`

We know that the `some` keyword defines an **opaque return type**. The opaque return type hides the actual underlying type — actual type being returned — and it lets Swift infer the type at runtime. In our specific case, we are hiding the actual returned type behind the `View` protocol. 

Therefore, even though the Swift compiler knows that the underlying type conforms to `View`, Swift can't know whether this real `View` underlying type being returned by `render()` actually matches with the `Primary` type. Yes, `Primary` also conforms to `View`, but that doesn't mean that the view being returned by `render` is going to be exactly of the same type specified by `Primary`. 

For instance, `Primary` might hold a type of `Text` — still conforming to `View` — while the actual underlying `View` being returned by the `render()` method is of type `Button`, which still conforms to `View`, but at the end of the day they are _not_ matching types. That's why Swift rightfully complains about this and prevents it from happening at runtime. It's like telling Swift to trust us that whatever `some View` returns is definitely the same as a completely unrelated generic type `Primary`. Well, if you think about it, Swift cannot know it since it's implicit within the definition of generics: either `Primary` or `Secondary` can hold _any_ type conforming to `View`.

#### Solution to Force-Cast

If you think about it, we have already laid the foundation for a flexible, scalable, and safe code using our `ModalCard.Button` supporting struct and applying the _Factory Method_ design pattern.

In fact, the main reason why we came up with such a solution was to have our factory struct `ModalCard.Button` _produce_ buttons, and `ModalCard` _accept_ those views. We don't need generics at all — in our case, we don't need `Primary: View` and `Secondary: View` — because the flexibility attribute that generics could have offered us is being resolved by the following steps:

- Having `ModalCard` store the `ModalCard.Button` object directly under `primaryButton` and `secondaryButton`.
  
- Delegating the rendering to `render() -> some View`, which offers us the flexibility we need via the _return opaque type_ — the method returns any object conforming to `View` — while providing safety and encapsulation by deciding which options (static methods) to expose to the end user — our developers — when designing the `ModalCard.Button` factory struct. In such a situation, our `ModalCard.Button` object holds the necessary information regarding which `Button` view to render; therefore, we are no longer force-casting the underlying `View` type, but directly embedding it within the `body` property of our `ModalCard` view.

Finally, the pattern we are going to use mimics Apple's `Alert.Button` style almost exactly.

### Final Implementation of `ModalCard`

We understood that generics aren't always needed, and despite them being useful, we should use them whenever the end-user of our API _injects_ their logic, but that also comes with its risks.

However, in scenarios where we are to own the logic, for example, with a supporting factory struct, we don't need generics.

Therefore, let's finally have a look at the final implementation of our `ModalCard` component, where we make the most out of our factory design pattern and allow smooth communication between the outer and inner structs:

```swift
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
```

Let me walk you through the main changes with our final and working implementation, which is the one I provided you with within the `ModalCard.swift` file on this repository:

```swift
public struct ModalCard: View {
```

1. We are no longer using generics — we no longer define the `Primary: View` and `Secondary: View` type parameters.

```swift
// Within the `ModalCard` struct

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
```

2. We have `ModalCard` accept the `ModalCard.Button` instances produced by the factory struct (`ModalCard.Button`), and store them under `primaryButton` and `secondaryButton`. These instances are crucial as they hold information as to which `View` to render; specifically, which `SwiftUI.Button` type to render, based on the option that the end-user passed to the exposed interface (e.g., `ButtonType.destructive`).

```swift
// Within the `body` property of `ModalCard`

HStack(spacing: 15) {
  secondaryButton.render()
  primaryButton.render()
```

3. As we mentioned in the previous paragraph, we delegate the rendering to `render() -> some View`, which will just embed whichever type of `View` returned into the `HStack`. This offers us the flexibility we were looking for. However, this flexibility is controlled for predictiveness and safety by setting up our constraints within the factory struct.

#### Usage Example

So, what you are left with is just trying the `ModalCard` component! You'll find that its setup is very similar to how Apple constructed its native `Alert` component.

The following is an example showing you how you would want to instantiate and use the `ModalCard` struct:

```swift
ModalCard(
  title: "Delete Account",
  message: "This action cannot be undone.",
  primaryButton: .destructive(
      Text("Delete"),
      { print("Delete") }
  ),
  secondaryButton: .cancel(
      { print("Cancel") }
  )
)
```

### Briefly on Design Choice

The `ModalCard` component is an interesting example of combining multiple design patterns to achieve clarity, reusability, and expressiveness.

#### Factory Design Pattern

The primary design pattern is the _Factory_ design pattern. This pattern is a creational design pattern, which exposes a method to the user of our class or struct to create well-defined instances of a certain type. In our case, we exposed `static` methods (e.g., `.destructive`, or `.cancel`) to produce `ModalCard.Button` instances; for this reason, we can specifically refer to it as _Static Factory Method_.

```swift
public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
```

Methods such as the one in the code snippet above encapsulate the internal implementation details (e.g., enums, properties, and constructor) and expose the necessary features offering a semantic API surface to the end-user.

As you may have noticed, many of Apple's APIs, such as `Alert` (e.g., `Alert.Button.destructive`) are also implemented using the Static Factory Method design pattern, because it _encapsulates_ construction logic, and provides _semantic access_.

#### Strategy-like Design Pattern

As a premise, I'm claiming that the codebase of our `ModalCard` uses a design pattern _similar_ to the **Strategy** Design Pattern, because it applies the same concepts. However, it doesn't resemble the exact implementation, and I'll explain to you why in a second.

First off, a **Strategy** Design Pattern lets you define a series of algorithms (actions) to embed in separate classes or structs, each of these classes or structs is meant to implement a certain interface or protocol (in Swift) called the **Strategy** protocol. This protocol will define a requirement, which is the implementation of a concrete strategy or action for each class or struct.

For instance, in our `ModalCard` example, the Strategy protocol would be the `ButtonType`, and the structs adopting that protocol would be `Destructive` and `Cancel`. Either `Destructive` or `Cancel` struct is a **Concrete Strategy**, because we provide a _concrete_ implementation for the strategy or action — rendering a certain `SwiftUI.Button` object.

These concrete strategy objects are then going to be interchangeable on the `ModalCard.Button` struct. This struct is called the context struct, which stores the actual strategy object — any object adopting the `ButtonType` protocol — and also defines an interface to have the strategy object manipulate its data and perform specific strategy actions with it – rendering a certain `SwiftUI.Button` object. In other words, the `ModalCard.Button` context struct would use a property of type `ButtonType` to invoke a specific algorithm/action defined by the concrete strategy (e.g., object of type `Destructive` adopting the `ButtonType` strategy) we store on that property. This a truly flexible tool, because we can change the behavior of our `ModalCard` at runtime, just by using an interface that replaces a new concrete strategy object with a new one, which performs a different action. For example, in our `ModalCard` example case, that property would be our `type` property, right?

I'll show you an example of `ModalCard.Button` using the pure Strategy Design Pattern just for demonstration purposes and explain to you how it relates to the final implementation of `ModalCard` and why I decided not to go fully into implementing it:

```swift
public struct ModalCard: View {

  // MARK: - `ModalCard.Button` factory/context struct

  public struct Button {
      
      // Define static factory methods: semantic API interface
      
      public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
          Button(type: AnyButtonType(Destructive(label: label, action: action)))
      }
      
      public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
          Button(type: AnyButtonType(Cancel(action: action)))
      }
      
      // Define the `ButtonType` strategy protocol
      private protocol ButtonType {
          associatedtype ViewType: View
          
          @ViewBuilder
          func render() -> ViewType
      }
      
      // Apply type erasure using `AnyButtonType` to wrap any conformer
      // to `ButtonType`. A type-erased `ButtonType` strategy
      private struct AnyButtonType: ButtonType {
          
          let _render: () -> AnyView
          
          fileprivate init<T: ButtonType>(_ wrapped: T) {
              self._render = { AnyView(wrapped.render()) }
          }
          
          @ViewBuilder
          func render() -> some View {
              self._render()
          }
      }
      
      // Define `destructive` concrete strategy
      private struct Destructive: ButtonType {
          
          let label: Text
          let action: () -> Void
          
          @ViewBuilder
          func render() -> some View {
              SwiftUI.Button(action: action, label: { label })
          }
      }
      
      // Define `cancel` concrete strategy
      private struct Cancel: ButtonType {
          
          let action: () -> Void
          
          @ViewBuilder
          func render() -> some View {
              SwiftUI.Button(action: action, label: { Text("Cancel") })
          }
      }
      
      // Expose interface to `ModalCard` to render buttons
      @ViewBuilder
      fileprivate func render() -> some View {
          type.render()
      }
      
      // Define the property storing the `ButtonType` strategy object
      private var type: AnyButtonType
      
      private init(type: AnyButtonType) {
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
```
Let me walk you through the above implementation for `ModalCard.Button`, which uses the _Strategy Design Pattern_ at its fullest, alongside the _Factory Design Pattern_, which we have already gone through.

```swift
// Define the `ButtonType` strategy protocol
private protocol ButtonType {
    associatedtype ViewType: View
    
    @ViewBuilder
    func render() -> ViewType
}
```

1. The most important aspect to implementing the Strategy pattern is defining a protocol to be adopted by all versions of a certain algorithm or action — the `render()` action, in our specific case. The context struct `ModalCard.Button` uses our `ButtonType` strategy protocol to be able to interchange amongst objects conforming to `ButtonType` at runtime — concrete strategies. Because of that, the `ModalCard.Button` context has the ability to call the rendering action defined by a specific concrete strategy (e.g., `Destructive`).

```swift
// Define `destructive` concrete strategy
private struct Destructive: ButtonType {
    
    let label: Text
    let action: () -> Void
    
    @ViewBuilder
    func render() -> some View {
        SwiftUI.Button(action: action, label: { label })
    }
}

// Define `cancel` concrete strategy
private struct Cancel: ButtonType {
    
    let action: () -> Void
    
    @ViewBuilder
    func render() -> some View {
        SwiftUI.Button(action: action, label: { Text("Cancel") })
    }
}
```

2. The different versions of an algorithm/action are represented by the concrete strategy classes or structs adopting the Strategy interface/protocol. In our case, we defined two concrete strategies — `Destructive` and `Cancel`, both adopting the `ButtonType` strategy protocol.

```swift
// Define the property storing the `ButtonType` strategy object
private var type: AnyButtonType

private init(type: AnyButtonType) {
    self.type = type
}
```

3. We then define a reference to a strategy object within our `ModalCard.Button` context struct; specifically, we store the strategy object on the `type` property.

```swift
// Define static factory methods: semantic API interface for encapsulating internal implementation details
      
public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
    Button(type: AnyButtonType(Destructive(label: label, action: action)))
}

public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
    Button(type: AnyButtonType(Cancel(action: action)))
}

// Expose interface to `ModalCard` to render buttons
@ViewBuilder
fileprivate func render() -> some View {
    type.render()
}
```

4. Then, the context defines an interface to either manipulate the strategy object or have it access the data on the context itself. In our case, our interface involves both the `render()` method — which uses a `fileprivate` access modifier to expose it to `ModalCard` to render buttons — and the static factory methods (Factory Design Pattern) used to produce instances of `ModalCard.Button` with a specific concrete strategy on the `type` property for a determined button-rendering behavior.

#### The Problem with Using `ButtonType` protocol as a Type to the `type` Property

Now, at this point, you might have had some doubts about step number 3, where we have the following code:

```swift
// Define the property storing the `ButtonType` strategy object
private var type: AnyButtonType

private init(type: AnyButtonType) {
    self.type = type
}
```

And asked yourself why we didn't end up with the following code, instead:

```swift
// Define the property storing the `ButtonType` strategy object
private var type: ButtonType

private init(type: ButtonType) {
    self.type = type
}
```

The code above would have been more plausible as far as the Strategy Design Pattern is concerned. After all, the context struct is expected to store any concrete strategy conforming to the `ButtonType` protocol to run its specific rendering behavior. So, where is the gotcha?

Well, Swift would have allowed us to write the code right above if we hadn't had an associated type within the definition of our `ButtonType` protocol.

However, the definition of an associated type within our protocol is crucial, in our case, because it allows us to define the different concrete implementations for the `render()` method on each concrete strategy struct (`Destructive` and `Cancel`) to return an opaque return type — `some View`, in our case — which is key to rendering any underlying `View` being inferred by Swift upon returning them.

So, if we had used the `ButtonType` directly as a type to the `type` property — I know, too many "type" words — that wouldn't have worked, and we would have had a compiler error. That's because we _cannot_ use a protocol with an associated type as a _concrete_ type for a stored property. This isn't allowed in Swift.

We know that to accomplish the Strategy pattern, the `type` property on the context struct is meant to wrap any object conforming to the `ButtonType` strategy protocol. Therefore, a solution to this problem is creating a _concrete_ type that wraps any object of type `ButtonType` using generics, and the name for this solution is **Type Erasure**.

In our case, **Type Erasure** will encapsulate different `ButtonType` conformers inside a single `AnyButtonType` wrapper, which will be defined as a struct. As a convention, we tend to name the type-eraser/type-wrapper using the "Any" prefix attached to the name of the type to be erased/wrapped — `ButtonType`, in our case. Therefore, `AnyButtonType` is also said to be a "type-erased" `ButtonType`.

The following is the code for the `AnyButtonType` wrapper struct:

```swift
private struct AnyButtonType: ButtonType {

  let _render: () -> AnyView
  

  fileprivate init<T: ButtonType>(_ wrapped: T) {
    self._render = { AnyView(wrapped.render()) }
  }

  @ViewBuilder
  func render() -> some View {
    return self._render()
  }
}
```

You see that we are now using a concrete type (`AnyButtonType`) that wraps any type conforming to the `ButtonType` protocol. If you think about it, that's a type-erasure operation, in the sense that we don't care about the type that's being wrapped, as long as it conforms to the `ButtonType` protocol. This operation finally erases the type, because the actual type that's being returned is represented by the type-eraser itself, which happens to be `AnyButtonType`, in our specific case. Eventually, the original type of the wrapped object is lost or erased.

```swift
// Within the `AnyButtonType` wrapper

fileprivate init<T: ButtonType>(_ wrapped: T) {
```

Also, notice how generics is a _fundamental_ feature for type erasure: it wouldn't be possible to wrap any concrete strategy type conforming to the `ButtonType` strategy protocol without generics. In our case, we defined a generic type parameter with a `ButtonType` conformance (`T: ButtonType`) for the initializer on `AnyButtonType`. The `AnyButtonType` struct is instantiated with a concrete strategy conforming to `ButtonType`, passed under the `wrapped` parameter — we use the type parameter `T` as its type.

```swift
// Within the `AnyButtonType` wrapper

let _render: () -> AnyView
```

The wrapper struct defines a `_render` property, which has a function type `() -> AnyView`. Notice how we are, again, using type erasure; in fact, the function returns a type-erased `View`. That's because `_render` is a stored property, and cannot be assigned an opaque return type. That means we couldn't type-annotate `_render` as `() -> some View`, because Swift would be expecting an initializer expression from which to infer an underlying type. For how we define our initializer within `AnyButtonType`, we are not able to have Swift infer the concrete type that's being hidden by the opaque `some View` type.

For instance, assume we were to assign `_render`, the following closure `{ wrapped.render() }`. Do you think Swift would be able to infer the type of what the `render()` method on the wrapped object conforming to `ButtonType` returns? 

Well, first off, Swift doesn't know, at compilation time, which concrete strategy object conforming to `ButtonType` is going to be wrapped by `AnyButtonType`; hence, it cannot know what's the _actual_ view being returned by the `render()` method. Therefore, the most the Swift compiler can do is know that the `render()` method is returning a `ViewType` associated type, still not a concrete type (`Text`, `Button`, `VStack`) from which Swift can infer. How does it know? Well, we told that `T` is a type conforming to `ButtonType`, and that's all Swift knows.

That's the reason why we used the `AnyView` type-erased `View`, and wrapped whichever object conforming to `View`, being returned by the `render()` method on any of the wrapped concrete strategy object — either `Destructive` or `Cancel`, in our case.

```swift
// Within the `AnyButtonType` wrapper

fileprivate init<T: ButtonType>(_ wrapped: T) {
  self._render = { AnyView(wrapped.render()) }
}
```

We are allowed to write `AnyView(wrapped.render())`, and Swift won't complain at compilation time, because it knows `AnyView` wraps any object conforming to `View`, and it just so happens that we defined our `ViewType` associated type to conform to `View`. At runtime, Swift will know which object of type `View` we are actually wrapping into `AnyView`.

Finally, we return the result of calling `_render()` from the concrete implementation of `render()` on the `AnyButtonType` struct.
Since `AnyView` is a concrete type, it's simply inferred by Swift when returned from `render() -> some View`.

```swift
// Within the `AnyButtonType` wrapper

@ViewBuilder
func render() -> some View {
  return self._render()
}
```

Finally, notice how we wrap our concrete strategies (`Destructive` and `Cancel`) within `AnyButtonType` when returning from the static factory methods to type-erase them:

```swift
// Define static factory methods: semantic API interface for encapsulating internal implementation details
      
public static func destructive(_ label: Text, _ action: @escaping () -> Void) -> ModalCard.Button {
    Button(type: AnyButtonType(Destructive(label: label, action: action)))
}

public static func cancel(_ action: @escaping () -> Void) -> ModalCard.Button {
    Button(type: AnyButtonType(Cancel(action: action)))
}
```

#### Strategy-like Pattern (via Enum) vs Full Strategy Pattern

Let's end this walk-through on the `ModalCard` component by explaining to you why, for this specific component, I decided to stick with the **Strategy-like** pattern using an internal enum for describing different strategies (rendering logic) based on the case (`.destruvtive` and `.cancel`).

Generally, the main reason why you would use the Strategy Design Pattern is when your context class/struct starts getting overwhelmed with bulky conditionals that switch the class's behavior depending on a certain property or parameter.

For instance, take our internal enum `ButtonType`:

```swift
// Within `ModalCard.Button`

private enum ButtonType {
  case destructive(label: Text, action: () -> Void)
  case cancel(action: () -> Void)
}
```

If it had had multiple conditionals to switch the context struct's behavior, our code would have been a mess, and every time we wanted to change or expand our behaviors, we would have had to _modify_ the code within `enum`, and that's not a best practice for when you have a large codebase.

Instead, with the classic Strategy pattern, we can create as many classes/structs as we have versions of a certain algorithm/behavior, all conforming to the strategy protocol — `ButtonType`, in our case.

Also, when using the Strategy pattern, your team can plan for future implementation/changes for your algorithms, because your codebase becomes flexible and easy to update. In our case, we only have two rendering algorithms/actions (`destructive`, and `cancel`), and that's why I decided to stick with an `enum`, instead of using structs to isolate the complexity of my codebase. 

However, I invite you to think about a scenario when you may have multiple versions of the same algorithm. In such a case, it's not recommended to keep your code in an `enum`, because it becomes cluttered and it's not even open to the Open/Closed principle from SOLID — open to extension, closed to modification; that is, if you were to expand or update your behaviors, you would be forced to _modify_ your code; on the other hand, if you were using the _full_ Strategy Design Pattern, to embed a new version of an algorithm — rendering our `Button` views, in our case — you would just need to create a new struct that adopts the `ButtonType` strategy protocol. Also, if you had to modify an existing behavior, you keep working on that specific struct that isolates that behavior, keeping your code modularized, flexible, and scalable.

#### Usage Example

Just for clarity's sake, I will repost the code snippet that uses my `ModalCard` component:

```swift
// At the top of your swift file
import SwiftUI
import ModalCard

// Within the `body` computed property of your view
ModalCard(
  title: "Delete Account",
  message: "This action cannot be undone.",
  primaryButton: .destructive(
      Text("Delete"),
      { print("Delete") }
  ),
  secondaryButton: .cancel(
      { print("Cancel") }
  )
)
```

I hope this guide served you well in walking you through the various facets of building adaptive components, and made you realize how simple interfaces hide quite a bit of complexity.































