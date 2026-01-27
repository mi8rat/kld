import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class BlogService {
    private List<BlogPost> posts;
    private int nextId;
    private static final String DATA_FILE = "blog_posts.txt";

    public BlogService() {
        this.posts = new ArrayList<>();
        this.nextId = 1;
        loadPosts();
    }

    // CREATE
    public BlogPost createPost(String title, String content, String author) {
        BlogPost post = new BlogPost(nextId++, title, content, author);
        posts.add(post);
        savePosts();
        return post;
    }

    // READ - Get all posts
    public List<BlogPost> getAllPosts() {
        return new ArrayList<>(posts);
    }

    // READ - Get post by ID
    public BlogPost getPostById(int id) {
        for (BlogPost post : posts) {
            if (post.getId() == id) {
                return post;
            }
        }
        return null;
    }

    // UPDATE
    public boolean updatePost(int id, String newTitle, String newContent) {
        BlogPost post = getPostById(id);
        if (post != null) {
            post.setTitle(newTitle);
            post.setContent(newContent);
            savePosts();
            return true;
        }
        return false;
    }

    // DELETE
    public boolean deletePost(int id) {
        BlogPost post = getPostById(id);
        if (post != null) {
            posts.remove(post);
            savePosts();
            return true;
        }
        return false;
    }

    // SEARCH
    public List<BlogPost> searchPosts(String keyword) {
        List<BlogPost> results = new ArrayList<>();
        String lowerKeyword = keyword.toLowerCase();
        
        for (BlogPost post : posts) {
            if (post.getTitle().toLowerCase().contains(lowerKeyword) ||
                post.getContent().toLowerCase().contains(lowerKeyword) ||
                post.getAuthor().toLowerCase().contains(lowerKeyword)) {
                results.add(post);
            }
        }
        return results;
    }

    // Save posts to file
    private void savePosts() {
        try (PrintWriter writer = new PrintWriter(new FileWriter(DATA_FILE))) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            
            for (BlogPost post : posts) {
                writer.println("ID:" + post.getId());
                writer.println("TITLE:" + post.getTitle());
                writer.println("AUTHOR:" + post.getAuthor());
                writer.println("CREATED:" + post.getCreatedAt().format(formatter));
                writer.println("UPDATED:" + post.getUpdatedAt().format(formatter));
                writer.println("CONTENT:" + post.getContent());
                writer.println("---END---");
            }
            writer.println("NEXT_ID:" + nextId);
        } catch (IOException e) {
            System.err.println("Error saving posts: " + e.getMessage());
        }
    }

    // Load posts from file
    private void loadPosts() {
        File file = new File(DATA_FILE);
        if (!file.exists()) {
            return;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(DATA_FILE))) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String line;
            int id = 0;
            String title = "";
            String author = "";
            String content = "";
            LocalDateTime created = null;
            LocalDateTime updated = null;

            while ((line = reader.readLine()) != null) {
                if (line.startsWith("ID:")) {
                    id = Integer.parseInt(line.substring(3));
                } else if (line.startsWith("TITLE:")) {
                    title = line.substring(6);
                } else if (line.startsWith("AUTHOR:")) {
                    author = line.substring(7);
                } else if (line.startsWith("CREATED:")) {
                    created = LocalDateTime.parse(line.substring(8), formatter);
                } else if (line.startsWith("UPDATED:")) {
                    updated = LocalDateTime.parse(line.substring(8), formatter);
                } else if (line.startsWith("CONTENT:")) {
                    content = line.substring(8);
                } else if (line.equals("---END---")) {
                    BlogPost post = new BlogPost(id, title, content, author);
                    post.setCreatedAt(created);
                    post.setUpdatedAt(updated);
                    posts.add(post);
                } else if (line.startsWith("NEXT_ID:")) {
                    nextId = Integer.parseInt(line.substring(8));
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading posts: " + e.getMessage());
        }
    }
}
