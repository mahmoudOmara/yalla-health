# YallaHealth - Business Requirements and Implementation Details

## Application Overview

**YallaHealth** is a centralized health management platform designed for Egyptian users, focusing on personal and family health management with human-first support and potential AI integrations in future versions.

### Core Business Concept
- Personalized health check-ins (daily or weekly calls)
- Medication adherence tracking and appointment management
- Health logs and family account management
- B2C and B2B2C distribution support
- Multi-account access with subscription-based management

---

## Target Market & Technical Constraints

#### Target Market
- **Primary Users**: Egyptian residents with mobile phones
- **Geographic Focus**: Egypt only (enforced through phone number validation)
- **Phone System**: Egyptian mobile numbers only (+20 country code)
- **Language**: Arabic and English support planned

#### Technical Constraints
- **Orientation**: Portrait mode only
- **Platform**: Cross-platform (iOS/Android)
- **Internet**: Online-only application (no offline support)
- **Data Strategy**: No caching - always fetch fresh data
- **Real-time**: No real-time updates - manual refresh only

---

## Account System Architecture

### Account Types
- **Primary Account**: Has credentials, manages subscription, controls access
- **Secondary Account**: May lack credentials, linked to primary account via shared access

### Account Access Sharing
- Primary Accounts or Secondary Account can give access to other primary accounts who can manage their account with different permission levels
- **Permission Levels**:
  - **View Only**: Read access to health data and updates
  - **Edit Access**: Can add health issues, updates, reminders
  - **Full Management**: Complete account and access control

### Subscription Model
- One subscription covers multiple accounts (N accounts per subscription)
- Primary and secondary accounts are counting to the N account per subscription
- The group who are sharing same subscription doesn't have to share access to their accounts

---

## Feature 1: Authentication System

### 1.1 Registration Flow

**User Input Requirements:**
- **Name**: Full name (required, min 2 characters)
- **Phone**: Egyptian mobile number (required, auto-formatted with +20)
- **Gender**: Male/Female selection (required)
- **Age**: Numeric input (required, 13-120 years)
- **Email**: Optional field for notifications

**Validation Rules:**
- Phone number must be valid Egyptian mobile (10 digits after +20)
- Age must be between 13-120 years
- Name cannot contain special characters or numbers
- Email must be valid format if provided

**Backend Flow:**
1. `POST /api/register` - Submit registration data
   - Request includes: name, phone (+20XXXXXXXXXX), gender, age, email (optional)
   - Response: 201 Created on success
   - Triggers OTP SMS to provided phone number

2. User receives SMS with 6-digit OTP code

3. `POST /api/verify-otp` - OTP verification
   - Request includes: phone, otp_code
   - Response: 200 OK with authentication token (jwt_token)

4. `GET /api/user/details` - Automatic profile fetch
   - Headers: `Authorization: Bearer jwt_token`
   - Response: Complete user profile data

5. `GET /api/user/shared-users` - Automatic profile fetch
   - Headers: `Authorization: Bearer jwt_token`
   - Response: Get all users who grant the authenticated user's account access to their accounts
   - Triggers navigation to home screen

### 1.2 Login Flow

**User Input Requirements:**
- **Phone**: Egyptian mobile number (auto-formatted with +20)

**Backend Flow:**
1. `POST /api/login` - Send OTP to existing user
   - Request includes: phone (+20XXXXXXXXXX)
   - Response: 200 OK on success
   - Triggers OTP SMS to phone number

2. User receives SMS with 6-digit OTP code

3. `POST /api/verify-otp` - OTP verification (same as registration)
   - Request includes: phone, otp_code
   - Response: 200 OK with authentication token (jwt_token)

4. `GET /api/user/details` - Fetch current user profile
   - Automatic call after successful OTP verification
   - Response: Complete user profile data

5. `GET /api/user/shared-users` - Automatic profile fetch
   - Headers: `Authorization: Bearer jwt_token`
   - Response: Get all users who grant the authenticated user's account access to their accounts
   - Triggers navigation to home screen

### 1.3 Auto-Login Flow (Saved Credentials)

**App Startup Process:**
1. Check for stored authentication token
2. If token exists: `GET /api/user/details`
   - Headers: `Authorization: Bearer stored_token`
   - Success (200): Navigate to home screen with user data
   - Failure (401/403): Clear stored token, redirect to login

3. `GET /api/user/shared-users` - Automatic profile fetch
   - Headers: `Authorization: Bearer jwt_token`
   - Response: Get all users who grant the authenticated user's account access to their accounts
   - Triggers navigation to home screen

4. If no token: Show login screen

### 1.4 Phone Number Handling

**Display Format:**
- Input field shows: "+20 " prefix (non-editable)
- User types: "1234567890"
- Display shows: "+20 123 456 7890"
- API sends: "+201234567890"

**Validation Requirements:**
- Must start with Egyptian mobile prefixes: 10, 11, 12, 15
- Total length: 11 digits (including prefix)
- No international codes other than +20 accepted
- Visual indicator: Egyptian flag icon in input field

**Example Valid Numbers:**
- +20 101 234 5678 (Vodafone)
- +20 111 234 5678 (Etisalat)
- +20 120 234 5678 (Orange)
- +20 155 234 5678 (WE)

---

## Feature 2: Home Screen - Health Issues Management

### 2.1 Layout Structure

**Top Section: Account Selection**
- Dropdown menu to select the account currently using the app
- Options: Main authenticated account + all accounts that grant access
- Default selection: Authenticated user's account
- When account changes: Fetch fresh health issues data for selected account

**Middle Section: Search & Filters**
- Search bar to filter issues by name, description, symptoms, treatment, notes
- Local fuzzy search implementation (no API calls)
- Filter controls:
  - **Category**: Multi-select dropdown (categories retrieved from API)
  - **Include Files**: Toggle (show only issues with attached files)
  - **Status**: Multi-select dropdown (statuses retrieved from API)
  - **Severity**: Multi-select dropdown (severities retrieved from API)

**Main Section: Health Issues List**
- Scrollable list of health issues for selected account
- Each item displays:
  - **Issue Title**: Main heading
  - **Status Badge**: Colored indicator (e.g., "Active", "Resolved")
  - **Category**: Text label
  - **Severity Level**: Visual indicator or text
  - **File Indicator**: Icon if files are attached
- List items are clickable → Navigate to Health Issue Detail View
- Pull-to-refresh functionality

**Bottom Section: Action Button**
- **Add New Issue** floating action button
- Clicking opens Add Health Issue screen
- When new issue is saved, it must instantly appear in the list

### 2.2 Data Flow
- **Account Selection**: Send selected account UUID with API requests
- **No Pagination**: Load all health issues for selected account
- **No Caching**: Always fetch fresh data when switching accounts
- **Local Search**: Perform fuzzy search on locally loaded data

---

## Feature 3: Add/Edit Health Issue

### 3.1 Form Fields

**Required Fields:**
- **Issue Title**: Text input (required, max 100 characters)
- **Description**: Multi-line text input (required, max 500 characters)
- **Category**: Dropdown selection (list retrieved from backend API)
- **Status**: Dropdown selection (list retrieved from backend API)
- **Severity Level**: Dropdown selection (list retrieved from backend API)

**Optional Fields:**
- **Symptoms**: Multi-line text input (optional, max 300 characters)
- **Treatment**: Multi-line text input (optional, max 300 characters)
- **Notes**: Multi-line text input (optional, max 500 characters)

**Special Fields:**
- **Is Recurring**: Toggle switch (boolean value)

### 3.2 Form Behavior
- **Validation**: Show validation errors in real-time
- **Save Button**: Disabled until required fields are filled
- **Cancel Button**: Discard changes and return to previous screen
- **Success Action**: Close view and update Home Screen list instantly
- **Error Handling**: Display server error messages appropriately

### 3.3 API Integration
- Use FormViewModel for form state management
- Send selected account UUID with create/update requests
- Handle network errors and validation failures

---

## Feature 4: Health Issue Detail View

### 4.1 Layout Sections

**General Information Section**
- Display-only view of all health issue details:
  - Issue Title
  - Description
  - Category
  - Status
  - Severity Level
  - Symptoms
  - Treatment
  - Notes
  - Recurring status
- **Edit Button**: Navigate to Edit Health Issue screen

**Action Buttons Section**
Implement with optimal UI/UX design:

1. **Add Update**
   - Input: Update text (required), datetime (auto-filled with current time)
   - Action: Save update to health issue timeline

2. **Upload Files**
   - Support: Images (10MB), PDFs (25MB), Documents (15MB)
   - Multiple file selection
   - Each file has: type (auto-detected), optional description
   - Show upload progress and handle errors

3. **Book Follow-Up**
   - Input fields:
     - **DateTime**: Date and time picker
     - **Provider**: Doctor or clinic name (text input)
     - **Reason/Notes**: Optional text area for follow-up details
   - Save to calendar events

4. **Add Reminder**
   - Input fields:
     - **Type**: Dropdown list (retrieved from API)
     - **Details**: Text description of reminder
     - **DateTime**: Date and time picker
     - **Repetition Type**: Dropdown list (retrieved from API)
   - Save to calendar events

**History Timeline Section**
- Chronological display of all actions/logs for this health issue:
  - Issue created
  - Issue updated
  - Update added
  - File uploaded
  - Follow-up booked
  - Reminder added
- Each entry shows: timestamp, action type, details, user who performed action

### 4.2 Data Management
- Real-time updates not required - manual refresh
- All actions immediately update the timeline
- Files are managed by server (may use AWS S3 backend)

---

## Feature 5: Navigation Structure

### 5.1 Bottom Navigation Tabs
Always visible navigation bar with 5 tabs:

1. **Home**: Health Issues list (default tab)
2. **Contact**: Communication features
3. **Calendar**: Schedule and events view
4. **History**: Historical data view (implementation TBD)
5. **Settings**: App settings and account management (implementation TBD)

### 5.2 Navigation Behavior
- Deep navigation maintains bottom tab visibility
- No state persistence when switching tabs
- Each tab reloads fresh data when accessed

---

## Feature 6: Contact Tab

### 6.1 Interface Design
Simple layout with two primary action buttons:

**Start Chat Button**
- Opens full-page chat interface
- Built from scratch (no third-party chat service)
- **Implementation Details TBD**: Message types, persistence, features

**Request Call Button**
- Triggers popup confirmation dialog
- **Implementation Details TBD**: Call scheduling, provider assignment

### 6.2 Future Considerations
- Chat message types (text, images, files) - TBD
- Chat history persistence - TBD
- Message status indicators - TBD
- Call request workflow - TBD

---

## Feature 7: Calendar Tab

### 7.1 Calendar Interface

**Monthly View (Grid Layout)**
- Standard calendar grid showing day numbers
- Navigation controls: Previous/Next month buttons
- Current month/year display

**Event Indicators**
- Colored marks on days with events:
  - **Follow-ups**: Use same color as "Book Follow-Up" button
  - **Reminders**: Use same color as "Add Reminder" button
- Multiple events on same day: Show multiple colored indicators

**Filters (Top Section)**
- Filter buttons: **All**, **Follow-ups**, **Reminders**
- Active filter changes which events are displayed

### 7.2 Day Selection & Event Display

**Day Selection**
- Clicking a day highlights it and shows events in lower section
- Selected day remains highlighted

**Event List (Lower Half)**
- Displays follow-ups and reminders for selected day
- Each event row includes:
  - **Event Title**: Follow-up provider or reminder type
  - **Time**: Scheduled time
  - **Details**: Additional information
  - **Action Icons**: 
    - ✓ (Done) - Mark as completed
    - ✗ (Not Done) - Mark as not completed
    - **Undo Button**: Reset to original clear state

**Event Status Management**
- Clicking ✓ or ✗ toggles status and updates visual appearance
- Status changes are saved immediately
- Visual highlighting for completed/not completed events

### 7.3 Data Integration
- Events populated from follow-ups and reminders created in health issues
- No separate event creation - events only created through health issue actions
- Real-time updates not required - manual refresh

---

## API Integration Guidelines

### Request Headers (All API Calls)
```
Authorization: Bearer {jwt_token}
X-Device-Name: {device_brand_model}
X-Platform: {os_version}
X-App-Version: {app_version_build}
Content-Type: application/json
```

### Account-Specific Requests
For health-related API calls, include selected account UUID in the headers:
```
"X-User-UUID": "selected_account_uuid",
```

### Error Handling Strategy
- Map server error messages to user-friendly text
- Handle network connectivity issues
- Show loading states during API calls
- Provide retry mechanisms for failed requests

---

## User Interface Guidelines

### Brand Identity
- **Primary Color**: #2E7D32 (Green)
- **App Name**: YallaHealth
- **Tagline**: "Your Health, Our Priority"
- **Logo**: Medical services icon with green color scheme

### Design Principles
- **Simplicity**: Clean, uncluttered interface
- **Accessibility**: High contrast, readable fonts
- **Responsiveness**: Adaptive layouts for different screen sizes
- **Consistency**: Uniform design patterns across features

### Color Coding Strategy
- **Follow-ups**: Use consistent color across "Book Follow-Up" button and calendar indicators
- **Reminders**: Use consistent color across "Add Reminder" button and calendar indicators
- **Status Badges**: Different colors for different health issue statuses
- **Severity Levels**: Visual indicators (colors/icons) for different severity levels

### Form Design Standards
- Clear field labels and validation messages
- Disabled states for invalid forms
- Loading indicators for form submissions
- Success/error feedback after form actions

---

## Security & Privacy Requirements

### Authentication Security
- JWT token-based authentication
- Secure token storage in device keychain/keystore

### Data Protection
- All sensitive data encrypted in local storage
- No plain text credential storage (OTP-based system)
- Secure API communication (HTTPS only)

### Privacy Compliance
- Minimal data collection policy
- Clear consent for device information usage
- Option to delete account and all data (implementation TBD)
- Compliance with Egyptian data protection laws

---

## File Management Specifications

### Supported File Types & Limits (max 25MB)
- **Images**: JPG, PNG
- **Documents**: PDF, DOC, DOCX 
- **Total Files**: No limit on number of files per health issue

### File Upload Process
1. User selects files using device file picker
2. Validate file type and size before upload
3. Show upload progress indicator
4. Optional description field for each file
5. Files stored on server (backend handles AWS S3 integration)
6. Display uploaded files in health issue detail view

### File Viewing
- **Images**: Display in-app with zoom capability
- **Documents**: Open with device default application
- **Download**: Allow file download to device storage

---

## Search & Filter Implementation

### Local Fuzzy Search
- Use fuzzywuzzy package for intelligent search
- Search across multiple fields:
  - Issue title
  - Description
  - Symptoms
  - Treatment
  - Notes
- Implement search debouncing (300ms delay)
- Highlight search terms in results

### Filter Categories
1. **Category Filter**:
   - Multi-select dropdown
   - Categories retrieved from API
   - Show count of issues per category

2. **Status Filter**:
   - Multi-select dropdown
   - Statuses retrieved from API
   - Show count of issues per status

3. **Severity Filter**:
   - Multi-select dropdown
   - Severities retrieved from API
   - Show count of issues per severity

4. **Files Filter**:
   - Toggle switch
   - Show only health issues with attached files
   - Show count of issues with files

### Filter Persistence
- Filters reset when switching accounts
- No filter state persistence across app sessions
- Clear filter option to reset all filters

---

## Development Notes

### API Endpoint Strategy
- **Request specific API endpoints before implementing each feature**
- Include proper error handling for all API calls
- Implement loading states for all async operations

### Testing Requirements
- Unit tests for all ViewModels
- Widget tests for complex UI components
- Integration tests for complete user flows
- Mock all external dependencies in tests

### Code Quality Standards
- Follow Flutter/Dart best practices
- Use consistent naming conventions
- Implement proper error boundaries
- Add comprehensive code documentation
- Use static analysis tools (flutter analyze)

### Performance Considerations
- Lazy loading for large lists
- Image optimization for uploaded files
- Efficient state management with Stacked
- Memory management for file uploads

---

## Future Enhancement Placeholders

### Features Planned for Future Versions
- **Push Notifications**: Server-triggered reminders and updates
- **Offline Support**: Local data caching and sync
- **AI Integration**: Health insights and recommendations
- **Family Account Linking**: Enhanced sharing and management
- **Telemedicine Integration**: Video calls and consultations
- **Health Analytics**: Data visualization and trends
- **Third-party Integrations**: Wearables and health devices

### Technical Improvements Planned
- **Deep Linking**: Shareable health issue and calendar links
- **Biometric Authentication**: Fingerprint/Face ID login
- **Background Sync**: Automatic data updates
- **Advanced Search**: Server-side search with filters
- **Real-time Updates**: Live data synchronization
- **Enhanced File Management**: Cloud storage integration
- **API Versioning**: Backward compatibility support

---

**Note**: Features marked as "TBD" (To Be Determined) should be implemented with flexible architecture to accommodate future requirements without major refactoring. Focus on core functionality first, then expand based on user feedback and business needs.
