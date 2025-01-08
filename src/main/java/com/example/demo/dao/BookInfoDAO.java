package com.example.demo.dao;


import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.example.demo.vo.BookInfoVO;

@Mapper
public interface BookInfoDAO {

  List<BookInfoVO> selectAllBookInfo();
  BookInfoVO selectByKey(String book_key);
  void insert(BookInfoVO bookInfo);
  boolean update(BookInfoVO bookInfo);
  boolean delete(String book_key);
  
}
