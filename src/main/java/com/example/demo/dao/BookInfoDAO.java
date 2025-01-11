package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.vo.BookInfoVO;

@Mapper
public interface BookInfoDAO {

  List<BookInfoVO> selectAllBookInfo();
  BookInfoVO selectByKey(String book_key);
  BookInfoVO selectByKeyLock(String book_key);  // 기존 메서드 정의
  BookInfoVO selectByKeyLockWithRetry(String book_key, int retryCount);  // Retry 로직 추가
  void insert(BookInfoVO bookInfo);
  boolean update(BookInfoVO bookInfo);
  boolean delete(String book_key);
}
