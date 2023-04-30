import SwiftUI
import counter
import KMMViewModelCore
import KMMViewModelSwiftUI

struct ContentView: View {
  @ObservedPresenterState var state = SwiftSupportKt.doNewCounterPresenter()

  var body: some View {
    NavigationView {
      VStack(alignment: .center) {
        Text("Count \(state.count ?? 0)")
          .font(.system(size: 36))
        HStack(spacing: 10) {
          Button(action: {
            state.eventSink?(CounterScreenEventDecrement.shared)
          }) {
            Text("-")
              .font(.system(size: 36, weight: .black, design: .monospaced))
          }
          .padding()
          .foregroundColor(.white)
          .background(Color.blue)
          Button(action: {
            state.eventSink?(CounterScreenEventIncrement.shared)
          }) {
            Text("+")
              .font(.system(size: 36, weight: .black, design: .monospaced))
          }
          .padding()
          .foregroundColor(.white)
          .background(Color.blue)
        }
      }
      .navigationBarTitle("Counter")
    }
  }
}

extension Kmm_viewmodel_coreKMMViewModel: KMMViewModel { }

@dynamicMemberLookup
public struct KMMPresenterState<UiState: AnyObject> {
      
  internal let presenter: KMMPresenter<UiState>
  
  init(_ presenter: KMMPresenter<UiState>) {
      self.presenter = presenter
  }
  
  subscript<T>(dynamicMember keyPath: KeyPath<UiState, T>) -> T? {
      presenter.state?[keyPath: keyPath]
  }
}

@propertyWrapper
public struct ObservedPresenterState<UiState: AnyObject>: DynamicProperty {
    
  @ObservedViewModel private var presenter: KMMPresenter<UiState>

  public var wrappedValue: KMMPresenterState<UiState>
    
  public init(wrappedValue: KMMPresenterState<UiState>) {
    self.presenter = wrappedValue.presenter
    self.wrappedValue = wrappedValue
  }
   
  // TODO: is this a hack?!
  public init(wrappedValue: KMMPresenter<UiState>) {
    self.init(wrappedValue: KMMPresenterState(wrappedValue))
  }
}
//
//extension ObservedPresenterState {
//    public init(wrappedValue: KMMPresenter<UiState>) {
//        self.init(wrappedValue: KMMPresenterState(wrappedValue))
//    }
//}

// TODO we hide all this behind the Circuit UI interface somehow? Then we can pass it state only
//@MainActor
//class SwiftCounterPresenter: BasePresenter<CounterScreenState> {
//  init() {
//    // TODO why can't swift infer these generics?
//    super.init(
//      delegate: SwiftSupportKt.asSwiftPresenter(SwiftSupportKt.doNewCounterPresenter())
//        as! SwiftPresenter<CounterScreenState>)
//  }
//}

//class BasePresenter<T: AnyObject>: ObservableObject {
//  @Published var state: T? = nil
//
//  init(delegate: SwiftPresenter<T>) {
//    delegate.subscribe { state in
//      self.state = state
//    }
//  }
//}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
