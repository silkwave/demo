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
        for (int i = 0; i < retryCount; i++) {
            try {
                // 책 정보를 조회하고 잠금을 시도
                return sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKeyLock", book_key);
            } catch (Exception e) {
                // 잠금을 얻지 못했을 경우 재시도
                if (i < retryCount - 1) {  // 마지막 재시도는 아니면
                    try {
                        // 재시도 전에 1초간 대기
                        Thread.sleep(1000);  // 1초 대기
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                    }
                } else {
                    throw new RuntimeException("Failed to acquire lock after multiple attempts: " + e.getMessage(), e);
                }
            }
        }
        return null;  // 이 코드는 사실 실행되지 않지만, 컴파일을 위해 필요
    }
}
