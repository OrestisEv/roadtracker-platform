# Project Governance

## Maintainer

RoadTracker is maintained by Oresti Ev. The maintainer has final authority over:

- Accepting or rejecting contributions across all repositories
- The direction and roadmap of the project
- Any decision to commercialize the project
- Convening the Contributor Pool when relevant
- Schema changes and platform contract updates

## Repository hierarchy

`roadtracker-platform` is the governing repo. Its contracts and feature matrix take precedence over individual app implementations. If an app repo diverges from the platform contracts, the platform repo is correct and the app must be updated.

## Contributor pool voting

When a vote is called among the Contributor Pool:

- Each contributor with at least one accepted PR (across any repo) gets one vote
- Votes are conducted transparently via a GitHub Discussion or Issue in `roadtracker-platform`
- Decisions require a simple majority
- The maintainer participates in the vote as a contributor

## Amendments

These governance terms may be updated by the maintainer at any time. Contributors will be notified via a pinned issue in `roadtracker-platform`.
