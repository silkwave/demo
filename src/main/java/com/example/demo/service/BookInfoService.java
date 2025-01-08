package com.example.demo.service;

import java.util.List;
import com.example.demo.vo.BookInfoVO;

public interface BookInfoService {

    // 모든 도서 목록을 조회
    List<BookInfoVO> selectAllBookInfo();

    // 책 키로 도서를 조회
    BookInfoVO selectByKey(String book_key);

    // 도서 추가
    void insertBookInfo(BookInfoVO bookInfo);

    // 도서 수정
    boolean updateBookInfo(String book_key, BookInfoVO bookInfo);

    // 도서 삭제
    boolean deleteBookInfo(String book_key);
}
