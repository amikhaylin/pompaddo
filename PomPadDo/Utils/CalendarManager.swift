//
//  CalendarManager.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 13.03.2025.
//

import EventKit

struct CalendarManager {
    static func addToCalendar(title: String, eventStartDate: Date, eventEndDate: Date) {
        let store = EKEventStore()
        
        store.requestWriteOnlyAccessToEvents { allowed, error in
            if let error {
                print(error.localizedDescription)
            } else if allowed {
                let event = EKEvent(eventStore: store)
                event.calendar = store.defaultCalendarForNewEvents
                event.title = title
                event.startDate = eventStartDate
                event.endDate = eventEndDate

                // Save the event
                do {
                    try store.save(event, span: .thisEvent)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
