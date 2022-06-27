//
//  StructClassActorBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 25.06.2022.
//

/*
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the stack
 - Faster
 - Thread safe (Because each thread has its own stack)
 - When you assign or pass value type, a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the heap
 - Slower, but synchronized
 - Not thread safe (by default)
 - When you assign or pass reference type, a new reference to original instance will be created (pointer)
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 STACK:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memmory, and access to this memmory is very fast
 - Each thread has its own stack
 
 HEAP:
 - Stores Reference types
 - Shared across threads
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 STRUCT:
 - Based on Values
 - Can be mutated
 - Stored in the Stack
 
 CLASS:
 - Based on References (Instances)
 - Cannot be mutated instead we can change values inside the reference
 - Stored in the Heap
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe (We have to be in asynchronous environment. Also we need to await to get in and out of the actor)
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 Structs -> Data Models, Views
 Classes -> View Models
 Actors -> Shared ('Manager' and 'Data Store')
 
*/


import SwiftUI

struct StructClassActorBootcamp: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                runTest()
            }
    }
}

extension StructClassActorBootcamp {
    private func runTest() {
        
        structTest1()
        printDivier()
        classTest1()
        printDivier()
        actorTest1()
        
//        structTest2()
//        printDivier()
//        classTest2()
    }
    
    private func printDivier() {
        print(
        """
            
        ----------------------------------------
        
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "Starting title")
        print("ObjectA: ", objectA.title)
        
        print("Pass the VALUE of objectA to objectB")
        var objectB = objectA
        print("ObjectB: ", objectB.title)
        
        // getting rid of objectB and creating a new objectB
        objectB.title = "Second title"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title")
        print("ObjectA: ", objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB")
        let objectB = objectA
        print("ObjectB: ", objectB.title)
        
        // when we are changing the title here, we are not changing the object itself (bacuse of that objectB is let) but we are changing the title inside the object
        objectB.title = "Second title"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func actorTest1() /* async */ {
        print("actorTest1")
        // It has to be in async environemnt. You can wrap within Task or you can make your func async
        Task {
            let objectA = MyActor(title: "Starting title")
            await print("ObjectA: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB")
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            // when we are changing the title here, we are not changing the object itself (bacuse of that objectB is let) but we are changing the title inside the object
            //objectB.title = "Second title" -> Cannot change title like that in actor because actor is thread safe, you must to do it within the actor
            await objectB.updateTitle(title: "Second title")
            print("ObjectB title changed")
            
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
    }
}

// we don't have the word "mutating" anywhere but we are actually mutating it when we change the title
struct MyStruct {
    var title: String
}

// Immutable struct -> Meaning the data inside this struct will not change
// Immutable means everything is going to be a let inside this struct
// question then becomes how do we change the title
// to mutate a struct would really be to create a new struct with updated values
struct CustomStruct {
    let title: String
    
    // we are creating totaly new struct
    func updateTitle(title: String) -> CustomStruct {
        CustomStruct(title: title)
    }
}

// Mutable struct
// When we change this title we are going to actually change this entire object (struct itself), we are not just changing the value of the title in here but we are changing the entire object
struct MutatingStruct {
    private(set) var title: String
    
    mutating func updateTitle(title: String) {
        self.title = title
    }
}

extension StructClassActorBootcamp {
    
    private func structTest2() {
        print("structTest2")
        
        // Fist one mutated
        // Second one totaly separate struct
        // All of these examples are actually functioning the same exact way
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        struct3 = struct3.updateTitle(title: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        // struct4.title = "asdasd" -> Because of private(set), we can't change title like that
        struct4.updateTitle(title: "Title2")
        print("Struct4: ", struct4.title)
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(title: String) {
        self.title = title
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(title: String) {
        self.title = title
    }
}


extension StructClassActorBootcamp {
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(title: "Title2")
        print("Class2: ", class2.title)
    }
}


struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp()
    }
}
