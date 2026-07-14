# Frontend README

This file documents the Flutter frontend layer of Aura AI.

---

## Frontend Ownership

The frontend is handled by Flutter.

```text
Flutter App → NestJS Backend API → FastAPI AI Service
```

---

## Responsibilities

Flutter handles:

- login/register UI
- chat interface
- memory-related UI
- document upload UI
- journal UI
- profile/settings UI
- API communication with NestJS
- WebSocket client integration
- local UI state management

---

## Frontend Tech Stack

- Flutter
- Dart
- REST API client
- WebSocket client
- secure token storage
- state management depending on final team decision

---

## API Configuration

Local development:

```env
API_BASE_URL=http://localhost:5000
WS_BASE_URL=ws://localhost:5000
```

Production:

```env
API_BASE_URL=https://your-nest-backend-url.com
WS_BASE_URL=wss://your-nest-backend-url.com
```

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/khelseekho-ui/aura-ai.git
   cd aura-ai
   ```

2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

### Running the Application

To run the application on a connected device, simulator, or browser:
```bash
flutter run
```

To target a specific platform:
- **Web (Chrome)**:
  ```bash
  flutter run -d chrome
  ```
- **Windows Desktop**:
  ```bash
  flutter run -d windows
  ```

### Running Tests

Run the comprehensive unit test suite to verify state controllers:
```bash
flutter test
```


## Frontend Request Flow

```text
User interacts with Flutter UI
        ↓
Flutter sends API request to NestJS
        ↓
NestJS validates request
        ↓
NestJS calls FastAPI if AI processing is needed
        ↓
Response returned to Flutter
```

---

## WebSocket Flow

```text
Flutter connects to NestJS WebSocket gateway
        ↓
JWT validated
        ↓
User joins chat room
        ↓
Messages/AI tokens are received in real time
```

---

## Mobile Deployment

Flutter app can be built for:

- Android
- iOS
- Web if required

---

## Frontend Checklist

- [ ] API base URL configurable
- [ ] WebSocket URL configurable
- [ ] auth token stored securely
- [ ] refresh token flow handled
- [ ] chat screen connected
- [ ] WebSocket connected
- [ ] document upload UI tested
- [ ] journal UI tested
- [ ] production API URL configured
