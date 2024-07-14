//
//  ContentView.swift
//  SwiftUIRedux
//
//  Created by chenyilong on 2024/7/14.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var store: Store
    
    struct Props {
        let counter: Int
        let onIncrement: () -> Void
        let onDecrement: () -> Void
        let onAdd: (Int) -> Void
    }
    
    private func map(state: State) -> Props {
        Props(counter: state.counter, onIncrement: {
            store.dispatch(action: IncrementAction())
        }, onDecrement: {
            store.dispatch(action: DecrementAction())
        }, onAdd: {
            store.dispatch(action: addAction(value: $0))
        }
        )
    }
    
    var body: some View {
        
        let props = map(state: store.state)
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("\(props.counter)")
                .font(.largeTitle)
            Button(action: {
                props.onIncrement()
            }) {
                Text("Increment")
            }
            
            Button(action: {
                props.onDecrement()
            }) {
                Text("Decrement")
            }
            
            Button(action: {
                props.onAdd(10)
            }) {
                Text("Add 10")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(reducer: reducer)
        ContentView().environmentObject(store)
    }
}
