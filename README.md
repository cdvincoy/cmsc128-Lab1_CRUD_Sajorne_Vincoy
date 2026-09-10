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


