package com.example.demo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.exception.BookNotFoundException;
import com.example.demo.service.BookInfoService;
import com.example.demo.vo.BookInfoVO;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequiredArgsConstructor
public class BookInfoController {

    private final BookInfoService bookInfoService;

    @Operation(summary = "도서 목록 조회", description = "도서 목록을 조회한다")
    @GetMapping("/book")
    public List<BookInfoVO> selectAllBookInfo() {
        log.info("Fetching all books");
        return bookInfoService.selectAllBookInfo();
    }

    @Operation(summary = "도서 정보 조회", description = "도서 정보를 조회한다")
    @GetMapping("/book/{book_key}")
    public ResponseEntity<BookInfoVO> selectByKey(@PathVariable String book_key) {
        log.info("Fetching book info with book_key: {}", book_key);

        try {
            BookInfoVO bookInfo = bookInfoService.selectByKey(book_key);
            log.info("Book info found: {}", bookInfo);
            return ResponseEntity.ok(bookInfo);
        } catch (BookNotFoundException e) {
            log.error("Book with key {} not found", book_key);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "도서 정보 추가", description = "도서 정보를 추가한다")
    @PostMapping(value = "/book/new", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<BookInfoVO>> insertBookInfo(@RequestBody BookInfoVO bookInfo) {
        log.info("Inserting new book: {}", bookInfo);
        bookInfoService.insertBookInfo(bookInfo);
        return ResponseEntity.status(HttpStatus.CREATED).body(bookInfoService.selectAllBookInfo());
    }

    @Operation(summary = "도서 정보 수정", description = "도서 정보를 수정한다")
    @PutMapping(value = "/book/{book_key}")
    public ResponseEntity<List<BookInfoVO>> updateBookInfo(@PathVariable String book_key, @RequestBody BookInfoVO bookInfo) {
        log.info("Updating book with book_key: {}", book_key);
        boolean updated = bookInfoService.updateBookInfo(book_key, bookInfo);
        if (!updated) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        return ResponseEntity.ok(bookInfoService.selectAllBookInfo());
    }

    @Operation(summary = "도서 정보 삭제", description = "도서 정보를 삭제한다")
    @DeleteMapping("/book/{book_key}")
    public ResponseEntity<String> deleteBookInfo(@PathVariable String book_key) {
        log.info("Deleting book with book_key: {}", book_key);
        boolean deleted = bookInfoService.deleteBookInfo(book_key); 
        if (!deleted) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Book not found");
        }
        return ResponseEntity.ok("Book deleted successfully");
    }
}
