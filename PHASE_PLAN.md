# NaloFocus Development Phase Plan

> **Last Updated**: 2025-10-30
> **Project Duration**: 16 Days
> **Current Phase**: Phase 1 - Foundation
> **Overall Progress**: 0%

## 📊 Executive Summary

**Project**: NaloFocus - Lightweight macOS menu bar app for time-blocking Reminders
**Status**: 🔄 Development Starting
**Target Completion**: November 15, 2025
**Risk Level**: 🟢 Low

### Quick Status
- **Current Sprint**: Setting up project foundation
- **Blockers**: None
- **Next Milestone**: EventKit proof of concept (Day 3)

---

## 📅 Phase Overview

| Phase | Duration | Status | Progress | Target Dates |
|-------|----------|--------|----------|--------------|
| Phase 1: Foundation | 3 days | 🔄 In Progress | 0% | Oct 30 - Nov 1 |
| Phase 2: Core Features | 4 days | ⏳ Not Started | 0% | Nov 2 - Nov 5 |
| Phase 3: Integration | 3 days | ⏳ Not Started | 0% | Nov 6 - Nov 8 |
| Phase 4: Testing & Refinement | 4 days | ⏳ Not Started | 0% | Nov 9 - Nov 12 |
| Phase 5: Release Preparation | 2 days | ⏳ Not Started | 0% | Nov 13 - Nov 14 |

---

## 🚀 Phase 1: Foundation (Days 1-3)
**Goal**: Establish project infrastructure and validate core technical feasibility
**Status**: 🔄 In Progress
**Progress**: 0/15 tasks

### Day 1: Project Setup (Oct 30)
- [ ] Create Xcode project with macOS app template
- [ ] Configure minimum deployment target (macOS 15.0)
- [ ] Set up project structure according to design
- [ ] Configure Git repository and .gitignore
- [ ] Add Info.plist entries for EventKit permissions

### Day 2: Core Infrastructure (Oct 31)
- [ ] Implement ServiceContainer for dependency injection
- [ ] Create basic data models (SprintTask, SprintSession)
- [ ] Set up MenuBarExtra with basic icon
- [ ] Create placeholder SprintDialogView
- [ ] Implement basic app state coordinator

### Day 3: EventKit Proof of Concept (Nov 1)
- [ ] Implement EventKit permission request flow
- [ ] Create basic ReminderManager with fetch functionality
- [ ] Test reminder fetching from different accounts
- [ ] Validate reminder update capability
- [ ] Document any EventKit limitations found

### ✅ Success Criteria
- [ ] Project builds and runs on macOS 15+
- [ ] Menu bar icon appears and responds to clicks
- [ ] EventKit permissions can be requested and granted
- [ ] Can fetch and display reminders from the system
- [ ] Basic architecture is in place and validated

---

## 📦 Phase 2: Core Features (Days 4-7)
**Goal**: Build the main user interface and business logic
**Status**: ⏳ Not Started
**Progress**: 0/20 tasks

### Day 4: Sprint Dialog UI (Nov 2)
- [ ] Implement SprintDialogView layout
- [ ] Create dynamic task row generation
- [ ] Build TaskRowView component
- [ ] Add task count picker (1-9 tasks)
- [ ] Implement add/remove task functionality

### Day 5: Reminder Selection (Nov 3)
- [ ] Create ReminderPicker component
- [ ] Implement searchable dropdown functionality
- [ ] Add reminder categorization (Past Due, No Time Set, Scheduled)
- [ ] Handle duplicate selection prevention
- [ ] Style picker with proper spacing and layout

### Day 6: Time Management (Nov 4)
- [ ] Implement DurationPicker with preset values
- [ ] Create break toggle functionality
- [ ] Build TimeCalculator service
- [ ] Add break duration selection
- [ ] Calculate and update session end times

### Day 7: Timeline Preview (Nov 5)
- [ ] Create TimelineView component
- [ ] Implement TimelineEntry visualization
- [ ] Add time formatting utilities
- [ ] Style timeline with proper visual hierarchy
- [ ] Connect timeline to sprint session data

### ✅ Success Criteria
- [ ] Complete sprint dialog UI is functional
- [ ] Can select reminders from categorized list
- [ ] Can set durations and add breaks
- [ ] Timeline preview accurately shows schedule
- [ ] All UI components are properly styled

---

## 🔗 Phase 3: Integration (Days 8-10)
**Goal**: Connect UI with EventKit and complete the sprint creation flow
**Status**: ⏳ Not Started
**Progress**: 0/15 tasks

### Day 8: EventKit Integration (Nov 6)
- [ ] Implement reminder alarm update functionality
- [ ] Create "Breaks" calendar/list management
- [ ] Add break reminder creation
- [ ] Handle multiple reminder accounts (iCloud, Exchange, Local)
- [ ] Implement error handling for EventKit operations

### Day 9: Sprint Execution (Nov 7)
- [ ] Connect "Start Sprint" button to business logic
- [ ] Implement sequential time updates for reminders
- [ ] Add success message display
- [ ] Implement form reset after sprint creation
- [ ] Add loading states during operations

### Day 10: Polish & Edge Cases (Nov 8)
- [ ] Handle "Breaks" list already exists scenario
- [ ] Add warning indicators for already-scheduled reminders
- [ ] Implement empty state for no reminders
- [ ] Handle sprints extending past midnight
- [ ] Add comprehensive error messages

### ✅ Success Criteria
- [ ] Can successfully create and schedule a sprint
- [ ] Reminders are updated with correct times
- [ ] Break reminders are created properly
- [ ] All edge cases are handled gracefully
- [ ] User receives clear feedback for all operations

---

## 🧪 Phase 4: Testing & Refinement (Days 11-14)
**Goal**: Ensure reliability, performance, and user experience quality
**Status**: ⏳ Not Started
**Progress**: 0/20 tasks

### Day 11: Unit Testing (Nov 9)
- [ ] Write unit tests for TimeCalculator
- [ ] Write unit tests for ReminderManager
- [ ] Test data model logic
- [ ] Test view model state management
- [ ] Achieve >80% code coverage

### Day 12: Integration Testing (Nov 10)
- [ ] Create UI tests for sprint creation flow
- [ ] Test EventKit integration scenarios
- [ ] Test permission denial handling
- [ ] Validate all reminder account types
- [ ] Test edge cases and error conditions

### Day 13: Performance Optimization (Nov 11)
- [ ] Profile memory usage
- [ ] Optimize reminder fetching performance
- [ ] Reduce app launch time
- [ ] Optimize UI rendering performance
- [ ] Validate <10 second sprint creation target

### Day 14: User Experience Polish (Nov 12)
- [ ] Add smooth animations and transitions
- [ ] Implement keyboard shortcuts
- [ ] Enhance visual feedback for user actions
- [ ] Improve error message clarity
- [ ] Conduct accessibility audit

### ✅ Success Criteria
- [ ] All tests pass with >80% coverage
- [ ] Performance targets are met
- [ ] No memory leaks detected
- [ ] UI is responsive and smooth
- [ ] Accessibility standards are met

---

## 🚢 Phase 5: Release Preparation (Days 15-16)
**Goal**: Prepare for distribution and launch
**Status**: ⏳ Not Started
**Progress**: 0/15 tasks

### Day 15: Distribution Setup (Nov 13)
- [ ] Create app icon and assets
- [ ] Configure code signing for distribution
- [ ] Set up notarization workflow
- [ ] Prepare App Store metadata
- [ ] Create screenshots for App Store

### Day 16: Final Validation (Nov 14)
- [ ] Conduct final testing on clean system
- [ ] Validate all success criteria are met
- [ ] Create user documentation
- [ ] Set up TestFlight for beta testing
- [ ] Submit for App Store review

### ✅ Success Criteria
- [ ] App is properly signed and notarized
- [ ] All distribution requirements are met
- [ ] Documentation is complete
- [ ] Beta testing is configured
- [ ] Ready for App Store submission

---

## 🎯 Key Milestones

| Milestone | Target Date | Status | Criteria |
|-----------|------------|--------|----------|
| EventKit POC Complete | Nov 1 | ⏳ | Can fetch and update reminders |
| UI Complete | Nov 5 | ⏳ | All interface components functional |
| MVP Feature Complete | Nov 8 | ⏳ | Can create and schedule sprints |
| Testing Complete | Nov 12 | ⏳ | >80% coverage, all tests pass |
| Release Ready | Nov 14 | ⏳ | Signed, notarized, documented |

---

## ⚠️ Risk Register

| Risk | Likelihood | Impact | Mitigation | Status |
|------|------------|--------|------------|--------|
| EventKit API limitations | Medium | High | Early POC validation | 🟡 Monitoring |
| macOS 15+ requirement limits users | Low | Medium | Document in marketing | 🟢 Accepted |
| Reminder account compatibility | Medium | Medium | Test all account types | 🟡 Monitoring |
| App Store review delays | Low | Low | Submit early, have backup plan | 🟢 Accepted |
| Performance with many reminders | Low | Medium | Implement pagination if needed | 🟢 Monitoring |

---

## 📝 Decision Log

| Date | Decision | Rationale | Impact |
|------|----------|-----------|--------|
| 2025-10-30 | Use SwiftUI over AppKit | Modern, simpler, better for menu bar apps | Requires macOS 15+ |
| 2025-10-30 | Stateless design | Simplifies architecture, leverages Reminders | No persistence layer needed |
| 2025-10-30 | Direct EventKit integration | Native, reliable, no server needed | Must handle permissions carefully |

---

## 📈 Progress Metrics

### Overall Statistics
- **Total Tasks**: 85
- **Completed**: 0
- **In Progress**: 0
- **Blocked**: 0
- **Completion Rate**: 0%

### Daily Velocity
- **Average tasks/day**: TBD
- **Current velocity**: TBD
- **Projected completion**: On track

---

## 🔄 Update Log

### 2025-10-30
- Initial phase plan created
- Project structure defined
- Development phases outlined
- Success criteria established

---

*This document is actively maintained and updated daily throughout the development cycle.*