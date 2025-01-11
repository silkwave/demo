package com.example.demo.dao.impl;

import java.util.List;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import com.example.demo.dao.BookInfoDAO;
import com.example.demo.vo.BookInfoVO;

@Repository
public class BookInfoDAOImpl implements BookInfoDAO {

    @Autowired
    private SqlSession sqlSession;
    
    @Override
    public List<BookInfoVO> selectAllBookInfo() {
        // 모든 책 정보 조회
        return sqlSession.selectList("com.example.demo.dao.BookInfoDAO.selectAllBookInfo");
    }

    @Override
    public BookInfoVO selectByKey(String book_key) {
        // book_key로 책 정보 조회
        return sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKey", book_key);
    }

    @Override
    public BookInfoVO selectByKeyLock(String book_key) {
        // 책 정보 조회 및 잠금 처리 (MyBatis 매퍼에서 정의한 SQL을 사용)
        return sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKeyLock", book_key);
    }

    @Override
    public void insert(BookInfoVO bookInfo) {
        // 새 책 정보 추가
        sqlSession.insert("com.example.demo.dao.BookInfoDAO.insert", bookInfo);
    }

    @Override
    public boolean update(BookInfoVO bookInfo) {
        // 책 정보 수정
        int rowsAffected = sqlSession.update("com.example.demo.dao.BookInfoDAO.update", bookInfo);
        return rowsAffected > 0;
    }

    @Override
    public boolean delete(String book_key) {
        // 책 정보 삭제
        int rowsAffected = sqlSession.delete("com.example.demo.dao.BookInfoDAO.delete", book_key);
        return rowsAffected > 0;
    }

    // selectByKeyLockWithRetry: 책 정보를 조회하면서 잠금을 시도하고, 실패 시 재시도
    @Override
    public BookInfoVO selectByKeyLockWithRetry(String book_key, int retryCount) {
        if (retryCount <= 0) {
            throw new RuntimeException("Maximum retry attempts reached");
        }

        try {
            // 책 정보를 조회하고 잠금을 시도
            return sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKeyLock", book_key);
        } catch (Exception e) {
            // 잠금을 얻지 못했을 경우 재시도
            if (retryCount > 1) {
                try {
                    // 재시도 전에 1초간 대기
                    Thread.sleep(1000);  // 1초 대기
                    return selectByKeyLockWithRetry(book_key, retryCount - 1); // 재시도
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
            throw new RuntimeException("Failed to acquire lock after multiple attempts: " + e.getMessage(), e);
        }
    }
}
