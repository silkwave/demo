package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.exceptions.PersistenceException;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.example.demo.vo.BookInfoVO;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Repository // @Mapper 제거, @Repository만 사용
@Slf4j
@AllArgsConstructor
public class BookInfoDAO {

  private SqlSession sqlSession;

  public List<BookInfoVO> selectAllBookInfo() {
    // 모든 책 정보 조회
    return sqlSession.selectList("com.example.demo.dao.BookInfoDAO.selectAllBookInfo");
  }

  public BookInfoVO selectByKey(String book_key) {
    // book_key로 책 정보 조회
    return sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKey", book_key);
  }

  public void insert(BookInfoVO bookInfo) {
    // 새 책 정보 추가
    sqlSession.insert("com.example.demo.dao.BookInfoDAO.insert", bookInfo);
  }

  public boolean update(BookInfoVO bookInfo) {
    // 책 정보 수정
    int rowsAffected = sqlSession.update("com.example.demo.dao.BookInfoDAO.update", bookInfo);
    return rowsAffected > 0;
  }

  public boolean delete(String book_key) {
    // 책 정보 삭제
    int rowsAffected = sqlSession.delete("com.example.demo.dao.BookInfoDAO.delete", book_key);
    return rowsAffected > 0;
  }

  public BookInfoVO selectByKeyLockWithRetry(String book_key, int retryCount) {
    log.error("selectByKeyLockWithRetry book_key {}", book_key);

    for (int attempt = 1; attempt <= retryCount; attempt++) {
      try {
        // 책 정보를 조회하고 잠금을 시도
        BookInfoVO bookInfo = sqlSession.selectOne("com.example.demo.dao.BookInfoDAO.selectByKeyLock", book_key);

        if (bookInfo == null) {
          throw new RuntimeException("No book found with the key: " + book_key);
        }

        log.error("selectByKeyLockWithRetry bookInfo {}", bookInfo);
        return bookInfo; // 잠금을 얻었다면 bookInfo 반환

      } catch (PersistenceException e) {
        String errorMessage = e.getMessage();
        if (errorMessage != null && errorMessage.contains("ORA-00054")) {
          log.error("Attempt {} failed to acquire lock for book_key: {}. MyBatis Error: {}", attempt, book_key,
              errorMessage);

          // 잠금을 얻지 못했을 경우 재시도
          if (attempt < retryCount) {
            log.info("Retrying attempt {} after {} seconds...", attempt + 1, (int) Math.pow(2, attempt)); // 지수 백오프
            sleepBeforeRetry((int) Math.pow(2, attempt)); // 지수 백오프 적용
          } else {
            throw new RuntimeException(
                "Failed to acquire lock after " + retryCount + " attempts for book_key: " + book_key, e);
          }
        } else {
          throw new RuntimeException("Error occurred while processing book_key: " + book_key, e);
        }
      } catch (Exception e) {
        throw new RuntimeException("Error occurred while processing book_key: " + book_key, e);
      }
    }
    return null; // 이 코드는 사실 실행되지 않지만, 컴파일을 위해 필요
  }

  private void sleepBeforeRetry(int seconds) {
    try {
      Thread.sleep(seconds * 1000); // seconds 단위로 대기
    } catch (InterruptedException ie) {
      Thread.currentThread().interrupt();
    }
  }

}
