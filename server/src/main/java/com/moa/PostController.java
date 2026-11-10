package com.moa;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/posts")
public class PostController {
    private final JdbcTemplate jdbc;

    public PostController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping
    public List<Post> feed() {
        return jdbc.query("SELECT id, author, body, likes FROM posts ORDER BY id DESC",
            (row, index) -> new Post(row.getLong("id"), row.getString("author"),
                row.getString("body"), row.getInt("likes")));
    }

    @PostMapping
    public List<Post> create(@RequestBody Draft draft) {
        jdbc.update("INSERT INTO posts(author, body) VALUES (?, ?)",
            required(draft.author(), 20), required(draft.body(), 280));
        return feed();
    }

    @PostMapping("/{id}/likes")
    public List<Post> like(@PathVariable long id) {
        if (jdbc.update("UPDATE posts SET likes = likes + 1 WHERE id = ?", id) == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        return feed();
    }

    private static String required(String value, int max) {
        String clean = value == null ? "" : value.strip();
        int length = clean.codePointCount(0, clean.length());
        if (length == 0 || length > max) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid text length");
        }
        return clean;
    }

    public record Draft(String author, String body) {}
    public record Post(long id, String author, String body, int likes) {}
}
