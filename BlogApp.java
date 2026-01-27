import java.util.List;
import java.util.Scanner;

public class BlogApp {
    private static BlogService blogService = new BlogService();
    private static Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        System.out.println("=================================");
        System.out.println("   Welcome to Simple Blog App");
        System.out.println("=================================\n");

        boolean running = true;
        while (running) {
            displayMenu();
            int choice = getIntInput("Enter your choice: ");

            switch (choice) {
                case 1:
                    createPost();
                    break;
                case 2:
                    viewAllPosts();
                    break;
                case 3:
                    viewPostById();
                    break;
                case 4:
                    updatePost();
                    break;
                case 5:
                    deletePost();
                    break;
                case 6:
                    searchPosts();
                    break;
                case 7:
                    running = false;
                    System.out.println("\nThank you for using Simple Blog App. Goodbye!");
                    break;
                default:
                    System.out.println("\nInvalid choice. Please try again.");
            }
        }
        scanner.close();
    }

    private static void displayMenu() {
        System.out.println("\n----- MENU -----");
        System.out.println("1. Create New Post");
        System.out.println("2. View All Posts");
        System.out.println("3. View Post by ID");
        System.out.println("4. Update Post");
        System.out.println("5. Delete Post");
        System.out.println("6. Search Posts");
        System.out.println("7. Exit");
        System.out.println("----------------");
    }

    private static void createPost() {
        System.out.println("\n--- Create New Post ---");
        System.out.print("Enter title: ");
        String title = scanner.nextLine();
        
        System.out.print("Enter author: ");
        String author = scanner.nextLine();
        
        System.out.print("Enter content: ");
        String content = scanner.nextLine();

        BlogPost post = blogService.createPost(title, content, author);
        System.out.println("\n✓ Post created successfully!");
        System.out.println(post);
    }

    private static void viewAllPosts() {
        System.out.println("\n--- All Blog Posts ---");
        List<BlogPost> posts = blogService.getAllPosts();
        
        if (posts.isEmpty()) {
            System.out.println("No posts available.");
        } else {
            for (BlogPost post : posts) {
                System.out.println(post);
                System.out.println("---");
            }
            System.out.println("Total posts: " + posts.size());
        }
    }

    private static void viewPostById() {
        int id = getIntInput("\nEnter post ID: ");
        BlogPost post = blogService.getPostById(id);
        
        if (post != null) {
            System.out.println("\n" + post);
        } else {
            System.out.println("\n✗ Post not found with ID: " + id);
        }
    }

    private static void updatePost() {
        System.out.println("\n--- Update Post ---");
        int id = getIntInput("Enter post ID to update: ");
        
        BlogPost post = blogService.getPostById(id);
        if (post == null) {
            System.out.println("\n✗ Post not found with ID: " + id);
            return;
        }

        System.out.println("\nCurrent post:");
        System.out.println(post);
        
        System.out.print("Enter new title (or press Enter to keep current): ");
        String newTitle = scanner.nextLine();
        if (newTitle.isEmpty()) {
            newTitle = post.getTitle();
        }
        
        System.out.print("Enter new content (or press Enter to keep current): ");
        String newContent = scanner.nextLine();
        if (newContent.isEmpty()) {
            newContent = post.getContent();
        }

        if (blogService.updatePost(id, newTitle, newContent)) {
            System.out.println("\n✓ Post updated successfully!");
            System.out.println(blogService.getPostById(id));
        } else {
            System.out.println("\n✗ Failed to update post.");
        }
    }

    private static void deletePost() {
        System.out.println("\n--- Delete Post ---");
        int id = getIntInput("Enter post ID to delete: ");
        
        BlogPost post = blogService.getPostById(id);
        if (post == null) {
            System.out.println("\n✗ Post not found with ID: " + id);
            return;
        }

        System.out.println("\nPost to delete:");
        System.out.println(post);
        
        System.out.print("Are you sure you want to delete this post? (yes/no): ");
        String confirmation = scanner.nextLine();
        
        if (confirmation.equalsIgnoreCase("yes")) {
            if (blogService.deletePost(id)) {
                System.out.println("\n✓ Post deleted successfully!");
            } else {
                System.out.println("\n✗ Failed to delete post.");
            }
        } else {
            System.out.println("\nDeletion cancelled.");
        }
    }

    private static void searchPosts() {
        System.out.println("\n--- Search Posts ---");
        System.out.print("Enter search keyword: ");
        String keyword = scanner.nextLine();
        
        List<BlogPost> results = blogService.searchPosts(keyword);
        
        if (results.isEmpty()) {
            System.out.println("\nNo posts found matching: " + keyword);
        } else {
            System.out.println("\nSearch results for '" + keyword + "':");
            for (BlogPost post : results) {
                System.out.println(post);
                System.out.println("---");
            }
            System.out.println("Found " + results.size() + " post(s)");
        }
    }

    private static int getIntInput(String prompt) {
        while (true) {
            try {
                System.out.print(prompt);
                int value = Integer.parseInt(scanner.nextLine());
                return value;
            } catch (NumberFormatException e) {
                System.out.println("Invalid input. Please enter a number.");
            }
        }
    }
}
