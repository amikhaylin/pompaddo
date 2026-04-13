//
//  CalendarManager.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 13.03.2025.
//

@preconcurrency import EventKit

struct CalendarManager {
    static func addToCalendar(title: String, eventStartDate: Date, eventEndDate: Date, isAllDay: Bool = false) {
        EKEventStore().requestWriteOnlyAccessToEvents { allowed, error in
            if let error {
                print(error.localizedDescription)
            } else if allowed {
                let eventStore = EKEventStore()
                let event = EKEvent(eventStore: eventStore)
                event.calendar = eventStore.defaultCalendarForNewEvents
                event.title = title
                event.startDate = eventStartDate
                event.endDate = eventEndDate
                event.isAllDay = isAllDay

                // Save the event
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
