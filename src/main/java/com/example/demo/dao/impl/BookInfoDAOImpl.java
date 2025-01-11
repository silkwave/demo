package com.example.demo.dao.impl;

import java.util.List;

import org.apache.ibatis.exceptions.PersistenceException;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import com.example.demo.dao.BookInfoDAO;
import com.example.demo.vo.BookInfoVO;

import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
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
    for (int attempt = 1; attempt <= retryCount; attempt++) {
      try {
        // 책 정보를 조회하고 잠금을 시도 (MyBatis에서 정의된 SELECT ... FOR UPDATE 쿼리 사용)
        BookInfoVO bookInfo = sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKeyLock", book_key);

        // 만약 책 정보가 없다면 예외를 발생시킴
        if (bookInfo == null) {
          throw new RuntimeException("No book found with the key: " + book_key);
        }

        // 성공적으로 잠금을 얻었다면 bookInfo 반환
        return bookInfo;

      } catch (PersistenceException e) {
        String errorMessage = e.getMessage();

        // ORA-00054 오류가 발생한 경우에만 재시도
        if (errorMessage != null && errorMessage.contains("ORA-00054")) {
          log.error("Attempt {} failed to acquire lock for book_key: {}. MyBatis Error: {}", attempt, book_key,
              errorMessage);

          // 잠금을 얻지 못했을 경우 재시도
          if (attempt < retryCount) { // 마지막 재시도가 아니면
            log.info("Retrying attempt {} after 1 second...", attempt + 1);
            sleepBeforeRetry();
          } else {
            throw new RuntimeException(
                "Failed to acquire lock after " + retryCount + " attempts for book_key: " + book_key, e);
          }
        } else {
          // ORA-00054 이외의 다른 예외는 즉시 처리
          throw new RuntimeException("Error occurred while processing book_key: " + book_key, e);
        }
      } catch (Exception e) {
        // MyBatis에서 발생하는 PersistenceException이 아닌 다른 예외 발생 시 즉시 처리
        throw new RuntimeException("Error occurred while processing book_key: " + book_key, e);
      }
    }
    return null; // 이 코드는 사실 실행되지 않지만, 컴파일을 위해 필요
  }

  private void sleepBeforeRetry() {
    try {
      // 재시도 전에 1초간 대기
      Thread.sleep(1000); // 1초 대기
    } catch (InterruptedException ie) {
      Thread.currentThread().interrupt(); // InterruptedException이 발생하면 현재 스레드를 인터럽트 상태로 설정
    }
  }

}
