package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.BookInfoDAO;
import com.example.demo.exception.BookNotFoundException;
import com.example.demo.vo.BookInfoVO;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class BookInfoServiceImpl implements BookInfoService {

    private final BookInfoDAO bookInfoDAO;

    @Override
    public List<BookInfoVO> selectAllBookInfo() {
        return bookInfoDAO.selectAllBookInfo();
    }

    @Override
    public BookInfoVO selectByKey(String book_key) {
        log.info("selectByKey {}", book_key);

        BookInfoVO bookInfo = findBookByKey(book_key);

        log.info("Book found: {}", bookInfo);
        return bookInfo;
    }

    @Override
    @Transactional
    public void insertBookInfo(BookInfoVO bookInfo) {
        if (bookInfo == null || bookInfo.getBook_key() == 0) {
            throw new IllegalArgumentException("유효하지 않은 도서 정보");
        }
        log.info("Inserting book: {}", bookInfo);
        bookInfoDAO.insert(bookInfo);
    }

    @Override
    @Transactional
    public boolean updateBookInfo(String book_key, BookInfoVO updateBookInfo) {
        BookInfoVO existingBook = findBookByKey(book_key);

        // Update the fields of the book
        existingBook.setBook_reg_no(updateBookInfo.getBook_reg_no());
        existingBook.setBook_title(updateBookInfo.getBook_title());
        existingBook.setBook_author(updateBookInfo.getBook_author());
        existingBook.setBook_publisher(updateBookInfo.getBook_publisher());

        log.info("Updating book: {}", existingBook);
        return bookInfoDAO.update(existingBook);
    }

    @Override
    @Transactional
    public boolean deleteBookInfo(String book_key) {
        BookInfoVO bookInfo = findBookByKey(book_key); // 존재 여부 확인
        log.info("Deleting book: {}", bookInfo);
        return bookInfoDAO.delete(book_key); // DAO를 통해 삭제
    }
    

    // Helper method to avoid repetition in selectByKey and update/delete methods
    private BookInfoVO findBookByKey(String book_key) {
        BookInfoVO bookInfo = bookInfoDAO.selectByKey(book_key);

        if (bookInfo == null) {
            throw new BookNotFoundException("책이 존재하지 않습니다.");
        }

        return bookInfo;
    }
}
