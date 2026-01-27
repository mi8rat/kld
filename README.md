# Simple Java Blog Application

A console-based blog application with CRUD operations written in pure Java (no frameworks).

## Features

- **Create** new blog posts with title, author, and content
- **Read** all posts or view a specific post by ID
- **Update** existing posts (title and content)
- **Delete** posts with confirmation
- **Search** posts by keyword (searches title, content, and author)
- **Persistent Storage** - Posts are saved to a text file and loaded on startup

## Files

- `BlogPost.java` - Model class representing a blog post
- `BlogService.java` - Service class handling CRUD operations and file storage
- `BlogApp.java` - Main application with console interface
- `blog_posts.txt` - Data file (created automatically)

## How to Compile

```bash
javac BlogPost.java BlogService.java BlogApp.java
```

## How to Run

```bash
java BlogApp
```

## Usage

The application presents a menu with the following options:

1. **Create New Post** - Add a new blog post
2. **View All Posts** - Display all blog posts
3. **View Post by ID** - View a specific post
4. **Update Post** - Modify an existing post
5. **Delete Post** - Remove a post (with confirmation)
6. **Search Posts** - Find posts by keyword
7. **Exit** - Close the application

## Data Structure

Each blog post contains:
- ID (auto-generated)
- Title
- Content
- Author
- Created timestamp
- Updated timestamp

## Data Persistence

Posts are automatically saved to `blog_posts.txt` after every create, update, or delete operation. The data is loaded when the application starts.

## Example Usage

```
1. Create a new post:
   - Enter title: "My First Blog Post"
   - Enter author: "John Doe"
   - Enter content: "This is the content of my first post."

2. View all posts to see your creation

3. Update the post by entering its ID and new values

4. Search for posts containing specific keywords

5. Delete posts you no longer need
```

## Requirements

- Java 8 or higher (uses LocalDateTime)
- No external dependencies or frameworks required
