// 책 목록을 가져와서 표시하는 함수
function fetchBooks() {
  fetch("http://localhost:8080/book", {
    method: "GET",
    headers: {
      Accept: "*/*", // 모든 형식의 응답을 받을 수 있도록 설정
    },
  })
    .then((response) => response.json()) // 응답을 JSON 형식으로 변환
    .then((data) => {
      const bookTable = document.getElementById("bookTable").getElementsByTagName("tbody")[0];
      bookTable.innerHTML = ""; // 기존 테이블 내용 지우기
      data.forEach((book) => {
        const row = createBookRow(book); // 각 책에 대해 테이블 행 생성
        bookTable.appendChild(row); // 테이블에 행 추가
      });
    })
    .catch((error) => console.error("Error fetching books:", error)); // 오류 발생 시 콘솔에 출력
}

// 책의 데이터를 받아서 테이블 행을 생성하는 함수
function createBookRow(book) {
  const row = document.createElement("tr");
  row.innerHTML = `
          <td>${book.book_key}</td>
          <td>${book.book_reg_no}</td>
          <td>${book.book_title}</td>
          <td>${book.book_author}</td>
          <td>${book.book_publisher}</td>
          <td>
              <button onclick="loadBookForUpdate('${book.book_key}')">Update</button> <!-- 수정 버튼 -->
              <button onclick="deleteBook('${book.book_key}', this)">Delete</button> <!-- 삭제 버튼 -->
          </td>
      `;
  return row;
}

// 책 정보를 수정할 수 있도록 폼에 데이터를 채우는 함수
function loadBookForUpdate(bookKey) {
  fetch(`http://localhost:8080/book/${bookKey}`)
    .then((response) => response.json()) // 책 정보를 받아옴
    .then((book) => {
      // 수정할 책 정보를 폼에 채움
      document.getElementById("update_book_key").value = book.book_key;
      document.getElementById("update_book_reg_no").value = book.book_reg_no;
      document.getElementById("update_book_title").value = book.book_title;
      document.getElementById("update_book_author").value = book.book_author;
      document.getElementById("update_book_publisher").value = book.book_publisher;
    })
    .catch((error) => console.error("Error loading book for update:", error)); // 오류 발생 시 콘솔에 출력
}

// 책 추가 기능
function addBook(event) {
  event.preventDefault(); // 폼 제출 시 페이지 리로드 방지
  const bookInfo = {
    book_key: document.getElementById("book_key_input").value, // 책 키
    book_reg_no: document.getElementById("add_book_reg_no").value, // 책 등록 번호
    book_title: document.getElementById("add_book_title").value, // 책 제목
    book_author: document.getElementById("add_book_author").value, // 책 저자
    book_publisher: document.getElementById("add_book_publisher").value, // 책 출판사
  };

  fetch("http://localhost:8080/book/new", {
    method: "POST", // 새 책을 추가하는 POST 요청
    headers: {
      "Content-Type": "application/json", // 요청 본문은 JSON 형식
    },
    body: JSON.stringify(bookInfo), // 책 정보 JSON 형태로 변환
  })
    .then((response) => response.json()) // 응답을 JSON 형식으로 변환a
    .then((data) => {
      // 새로운 책이 추가된 후 테이블을 새로고침
      showMessage("Book added successfully!"); // 성공 메시지 표시
      fetchBooks(); // 책 목록 새로고침
    })
    .catch((error) => {
      console.error("Error adding book:", error); // 오류 발생 시 콘솔에 출력
      showMessage("Error adding book.", false); // 실패 메시지 표시
    });
}

// 책 수정 기능
function updateBook(event) {
  event.preventDefault(); // 폼 제출 시 페이지 리로드 방지
  const bookKey = document.getElementById("update_book_key").value;
  const bookInfo = {
    book_reg_no: document.getElementById("update_book_reg_no").value,
    book_title: document.getElementById("update_book_title").value,
    book_author: document.getElementById("update_book_author").value,
    book_publisher: document.getElementById("update_book_publisher").value,
  };

  fetch(`http://localhost:8080/book/${bookKey}`, {
    method: "PUT", // 기존 책 정보를 수정하는 PUT 요청
    headers: {
      "Content-Type": "application/json", // 요청 본문은 JSON 형식
    },
    body: JSON.stringify(bookInfo), // 수정된 책 정보 JSON 형태로 변환
  })
    .then((response) => response.json()) // 응답을 JSON 형식으로 변환
    .then((data) => {
      showMessage("Book updated successfully!"); // 성공 메시지 표시
      fetchBooks(); // 책 목록 새로고침
    })
    .catch((error) => {
      console.error("Error updating book:", error); // 오류 발생 시 콘솔에 출력
      showMessage("Error updating book.", false); // 실패 메시지 표시
    });
}

// 메시지를 화면에 표시하는 함수
function showMessage(message, isSuccess = true) {
  const messageBox = document.getElementById("messageBox");
  messageBox.innerText = message; // 메시지 내용 설정
  messageBox.style.display = "block"; // 메시지 박스를 화면에 표시
  messageBox.classList.toggle("success", isSuccess); // 성공 메시지 클래스 적용
  messageBox.classList.toggle("error", !isSuccess); // 실패 메시지 클래스 적용
  setTimeout(() => (messageBox.style.display = "none"), 3000); // 3초 후 메시지 박스 숨김
}

// 페이지 로드 시 책 목록을 가져오는 함수 호출
fetchBooks();
