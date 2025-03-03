package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.BookInfoDAO;
import com.example.demo.exception.BookNotFoundException;
import com.example.demo.vo.BookInfoVO;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.google.gson.Gson;

@Service
@Slf4j
@AllArgsConstructor
public class BookInfoService {

    private final BookInfoDAO bookInfoDAO;

    public List<BookInfoVO> selectAllBookInfo() {
        return bookInfoDAO.selectAllBookInfo();
    }

    public BookInfoVO selectByKey(String book_key) {
        log.info("selectByKey {}", book_key);

        BookInfoVO bookInfo = findBookByKey(book_key);

        log.info("Book found: {}", bookInfo);
        return bookInfo;
    }

    @Transactional
    public void insertBookInfo(BookInfoVO bookInfo) {
        if (bookInfo == null || bookInfo.getBook_key() == 0) { // 0을 사용하여 기본값 체크
            throw new IllegalArgumentException("유효하지 않은 도서 정보");
        }
        log.info("Inserting book: {}", bookInfo);
        bookInfoDAO.insert(bookInfo);
    }

    @Transactional
    public boolean updateBookInfo(String book_key, BookInfoVO updateBookInfo) {
    
        // 1. 주어진 book_key로 기존 책 정보 조회
        BookInfoVO existingBook = findBookByKey(book_key);
    
        // 2. Gson 객체 생성 (updateBookInfo 객체를 JSON으로 변환하기 위해 사용)
        Gson gson = new Gson();
    
        // 3. updateBookInfo 객체를 JSON 문자열로 변환
        String jsonString = gson.toJson(updateBookInfo);
        log.info("\n\n\nupdateBookInfo → JSON: {}", jsonString);
    
        // 4. JSON 문자열을 다시 BookInfoVO 객체로 변환 (기존 책 정보 객체를 업데이트)
        existingBook = gson.fromJson(jsonString, BookInfoVO.class);
    
        // 5. 업데이트된 책 정보 로그 출력
        log.info("\n\n책 정보 업데이트 중, book_key: {} -> {}", book_key, existingBook);
    
        // 6. 변경된 책 정보를 데이터베이스에 업데이트
        return bookInfoDAO.update(existingBook);
    }
    
    

    @Transactional
    public boolean deleteBookInfo(String book_key) {
        BookInfoVO bookInfo = findBookByKey(book_key); // 존재 여부 확인
        log.info("Deleting book: {}", bookInfo);
        return bookInfoDAO.delete(book_key); // DAO를 통해 삭제
    }

    // Helper method to avoid repetition in selectByKey and update/delete methods
    private BookInfoVO findBookByKey(String book_key) {
        BookInfoVO bookInfo = bookInfoDAO.selectByKeyLockWithRetry(book_key, 5);

        if (bookInfo == null) {
            throw new BookNotFoundException("책이 존재하지 않습니다.");
        }

        return bookInfo;
    }
}
