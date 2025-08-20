Google Maps + Riverpod (Flutter) — Real-Time Route & Live Location

A clean, testable Flutter setup that shows your current location, draws a route polyline between two points, and keeps the camera auto-following your position — all wired with Riverpod so the UI stays dumb and reactive.

Think of it like this: providers own the side-effects (GPS, Google Maps SDK, polylines), widgets just render state. Easy to reason about, easy to extend.

✨ Features

🔵 Live “blue dot”: shows your real-time location

🧭 Auto camera follow: camera animates as your position changes

🗺️ Route polyline: draws a route between Source ↔ Destination (Google Directions API via flutter_polyline_points)

🧰 Riverpod architecture: FutureProvider, StreamProvider, and StateProvider for clean state flow

🧪 Testable: logic is in providers (simple to mock in unit tests)
