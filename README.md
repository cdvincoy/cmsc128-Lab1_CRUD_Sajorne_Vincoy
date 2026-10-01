# Basic CRUD (To-Do List) Activity 1

## Members
- Sajorne, Chrystie Rae
- Vincoy, Claire Dane

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase
- **Database:** Cloud Firestore


**Flutter** was chosen for the application because it provides a straightforward structure for building the user interface and is relatively easy to learn and integrate. Its documentation and available tutorials make it convenient to follow examples and see changes while developing the application. Flutter allows us to keep the application organized within a single project, with files separated into folders such as pages, models, and services. This made it easier for the group to manage while developing a simple **CRUD** application. On the other hand, **Firebase** was chosen because it is easy to integrate with Flutter and provides a managed backend service. For this project, the team used **Cloud Firestore** as the database, which allows persistent storage and retrieval of tasks without having to build and maintain a separate backend server. 

## Features 

The application supports the following operations:
- Create new tasks (task name, category, priority, due date, & due time)
- View existing tasks
- Update existing tasks
- Delete tasks
- Undo a recently deleted task
- Mark tasks as completed
- View tasks in a scheduled list
- View tasks through a calendar
- Select a date in the calendar to view tasks due on that date

## How to Run Locally

### Prerequisites

Make sure the following are installed:
- Flutter SDK
- Git
- A device or emulator capable of running Flutter applications

### Setup

1. Clone the repository:
```bash
git clone https://github.com/cdvincoy/cmsc128-Lab1_CRUD_Sajorne_Vincoy
```
2. Navigate to the Flutter project:
```bash
cd cmsc128-Lab1_CRUD_Sajorne_Vincoy/todo_list
```

4. Install the project dependencies:
```bash
flutter pub get
```
 
5. Run the application:
```bash
flutter run
```

### Firebase Configuration

This project uses Firebase and Cloud Firestore. A valid Firebase configuration is required to run the application.


## CRUD / Data Operations

The CRUD operations are implemented in: 

```todo_list/lib/service/tasks_actions.dart```

The application uses the cloud_firestore Flutter package to communicate with the Firestore tasks collection.

| Operation | Method | Firestore Operation |
| :--- | :---: | ---: |
| Create | createTask() | add() |
| Read | readTasks () | snapshots() |
| Update | updateTask() | update()
| Delete | deleteTask() | delete () 

### Create

The createTask() method adds a new task to the Firestore tasks collection.

### Read

The readTasks() method listens for changes to the Firestore collection and converts the retrieved documents into Task objects.

### Update

The updateTask() method updates existing tasks using its document ID.

### Delete

The deleteTask() method deletes a task from the Firestore collection. 

### Undo Delete

The application also provides an undo option after deleting a task. The undoDelete() method restores the deleted task to Firestore.

### Complete Task

Tasks can also be marked as completed or active using the completeTask() method.

## Project Structure

The main flutter application is organized into separate folders for different responsibilities:

```
todo_list/
├────────lib/
│   ├───models/
|   |      └── task.dart
|   ├───pages/
|   |      ├── add_task.dart
|   |      ├── edit_task.dart
|   |      ├── onboard.dart
|   |      ├── tasks.dart
│   ├───service/
|   |      ├── tasks_actions.dart
|   ├── firebase_options.dart
│   └── main.dart
└── test/
...
```

### Main Components
- ```models/task.dart``` - Defines the Task model and its data fields.
- ```pages/add_task.dart``` - Provides the interface for creating a new task
- ```pages/edit_task.dart``` - Provides the interface for editing an existing task.
- ```pages/onboard.dart``` - Displays the onboarding screen when the app starts.
- ```services/tasks_actions.dart``` - Handles task CRUD operations with Firestore.
- ```lib/main.dart``` - Initializes Firebase and starts the Flutter application.
- ```lib/firebase_options.dart``` - Contains the Firebase configuration settings for connecting the app to the Firebase project.

### Database

The application uses a Cloud Firestore collection named:

```task```

Each task contains information such as:
- Task title
- Due date
- Time created
- Priority
- Completion status

Task data remains stored in Firestore, allowing tasks to persist after the application is closed or started.

## Authentication and User Account Management

### Authentication Approach

The application uses Firebase Authentication to manage user accounts and authentication. Firebase Authentication handles the user's credentials and authentication state, while Cloud Firestore is used to store application data and user-related profile information and application data.

## Implemented Authentication Features

### User Account Data

Each registered user has a unique Firebase Authentication UID. User profile information is stored in the users collection using the user's UID as the document ID.

The stored profile information currently includes:
- username
- email address
  
Passwords are handled by Firebase Authentication and are not stored in Cloud Firestore.

### Registration

Users can create an account with an email address and password. The registration form:

- Requires an email address and both password fields.
- Requires username.
- Checks that the password and confirmation match.
- Lets users show or hide the password fields.
- Creates the account through Firebase Authentication.
- Displays relevant errors, such as an invalid email, an email already in use, or a password that does not meet Firebase’s configured requirements.
- Returns the user to the login screen after successful registration.

### Login

Users sign in with their registered email address and password through Firebase Authentication. The password is hidden by default, with an option to show it. The app displays messages for common sign-in errors, including invalid email or credentials.

Successful sign-in is handled by the authentication service. 

### Logout

Users can log out from the Profile page. Before signing out, the application displays a confirmation dialog asking: "Are you sure you want to log out?"
If confirmed, Firebase Authentication signs the user out and the application returns to the unauthenticated flow.

### Session Persistence

The application uses Firebase Authentication's authentication state to determine whether a user is currently logged in.

An authentication state listener (authStateChanges()) is used by the application to display the appropriate page depending on whether a valid authenticated session exists.

The authenticated session persists across application refreshes until the user logs out.

### Profile Management

Authenticated users can view their profile information through the Profile page. The profile page displays the user's username and email address retrieved from Cloud Firestore.

Users can access the Edit Profile to update their username and email address. They can also enter and confirm new password when changing their password.

### Password Recovery via Email

The login screen provides a Forgot Password? option. Users enter their email address, and the app asks Firebase Authentication to send a password recovery link. The app reports whether the email was sent or whether an error occurred. Users can then go through their email and look for the recovery link sent by Firebase, in which they will be redirected to change their password. Firebase updates the user account's password credential, thus the old password will not authenticate the user.

## Security Practices

- Firebase Authentication manages account credentials; it uses an internally modified version of scrypt to hash account passwordss.
- Password fields are obscured by default and can be revealed only by user action.
- Registration checks for missing values and mismatched passwords before sending the request to Firebase.
- Authentication errors are handled and presented to the user.
- Password strength requirements are enforced by Firebase according to the project’s configured authentication policy.

# Authentication and User Access Activity 2

## Authentication and Database Operations

Firebase Authentication and Cloud Firestore have separate responsibilities.

Firebase Authentication manages:
- user identity
- email/password changes
- authentication state
- login and logout

Cloud Firestore manages:
- username
- email address
- other data associated with the user (tasks later)

The user's Firebase Authentication UID is used as the document ID for the corresponding Firestore user record.

### Database Inspection

User account records can be inspected through the Firebase Console's Cloud Firestore database interface.
The users collection contains the profile information associated with each registered account. Passwords are not visible in these Firestore documents because password credentials are managed by Firebase Authentication.

### Authentication Flow

1. **App startup**: Firebase is initialized before the app displays the onboarding screen.
2. **Registration**: A new user enters an email and password, confirms the password, and submits the form. The app validates the input and creates the account with Firebase Authentication.
3. **After authentication**: Successful registration returns the user to the login screen. Login success is reported, but the app does not yet navigate to the task screen automatically.
4. **Login**: A registered user enters their email and password. Firebase Authentication verifies the credentials and reports success or an error.
5. **Password recovery**: From the login screen, a user can enter their email address to request a password-reset link from Firebase Authentication.


