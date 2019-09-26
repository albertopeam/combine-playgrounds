import Combine

let me = Chatter(name: "Alberto", message: "Hi!")
let stranger = Chatter(name: "Stragner", message: "hey yo")

var subscriptions = Set<AnyCancellable>()
let subject = CurrentValueSubject<Chatter, Never>(me)
subject.flatMap({ $0.message }) // append new publisher that is send to the subject
    .sink(receiveValue: { print("regular flatMap: \($0)") })
    .store(in: &subscriptions)

// adding new publisher
subject.value = stranger

// updating inner CurrentValueSubject value for all subject.value
me.message.value = "who are you?"
stranger.message.value = "I´m you from the future"

me.message.value = ""

// to avoid consuming lots of memory it can be sized the flatMap with a top count of appended Publiser
let fixedSizeSubject = CurrentValueSubject<Chatter, Never>(me)
fixedSizeSubject.flatMap(maxPublishers: .max(1), { $0.message })
    .sink(receiveValue: { print("fixed size flatMap: \($0)") })
    .store(in: &subscriptions)

fixedSizeSubject.value = stranger // try to append new publisher, but it won´t due to maxPublishers
me.message.value = "Hellloooo"
me.message.value = "Anyone there?"

stranger.message.value = "nop" // it wont be printed in fixedSizeSubject



