# Observing

**Observing** is a property wrapper in Swift designed to facilitate observing changes to property values. It is particularly useful in scenarios where you need to react to changes in a property and perform certain actions accordingly.

Observing is designed to work in applications that cannot yet utilize SwiftUI or Combine for property observation.


## Usage

To use Observing, follow these steps:


Define the property you want to observe:

```swift
@Observing var myProperty = 0
```

Bind listeners to the property:

```swift
myProperty.$bind { [weak self] value in
    // Perform actions based on the new value
}
```

Optionally, you can bind hard listeners, which are always notified:

```swift
myProperty.$hardBind { [weak self] value in
    // Perform actions based on the new value, always notified
}
```

Remove listeners when It's no longer needed:

```swift
$myProperty.removeListener()
```

### Note
> The bind method sets a listener. If it has been set previously, it will be replaced by the last set listener. However, hardBind allows setting multiple listening objects. Use according to your project requirements.


<br>

## Function 



```swift 
func bind(fireNow: Bool = true, _ listener: @escaping Listener)
```

>Binds a listener to the property. If fireNow is set to true, the listener will be immediately invoked with the current value of the property.

<br>

```swift 
func hardBind(fireNow: Bool = true, _ listener: @escaping Listener)
```
>Binds a listener to the property, prioritizing it over other listeners. Even if **removeListener()** is called, hard-bound listeners remain. Use with caution.
if you want to remove hardBind listener please call **removeAllListeners()**

<br>

```swift 
func removeListener()
```

>Removes the listener associated with the property.

<br>

```swift 
func removeHardBindListeners()
```

>Remove listeners set through the hardBind method.

<br>

```swift 
func removeAllListeners()
```
>Remove listeners set through the hardBind method.


<br>

## MVVM 

>Below codes will create a simple MVVM structure where SomeViewModel contains observed properties title and content, and SomeViewController binds its UI elements to these properties to reflect changes dynamically.

```swift
// MVVM Sample 

class SomeViewModel {
    @Observing var title = ""
    @Observing var content = ""
}

class SomeViewController: UIViewController {
    
    typealias ViewModel = SomeViewModel

    private var viewModel = ViewModel()
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$title.bind{ [weak self] value in
            self?.titleLabel.text = value
        }
        
        viewModel.$content.bind{ [weak self] value in
            self?.contentLabel.text = value
        }
    }
}
```
