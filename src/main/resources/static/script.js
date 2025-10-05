document.addEventListener("DOMContentLoaded", () => {
  loadBookList();

  // ESC 키로 모달 닫기
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeModal();
  });

  // 모달 외부 클릭 시 닫기
  const modal = document.getElementById("bookModal");
  modal.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
  });
});

const BASE_URL = "http://localhost:8080/book";

// 도서 목록 로드
function loadBookList() {
  fetch(BASE_URL)
    .then(res => res.json())
    .then(data => {
      const tbody = document.querySelector("#bookTable tbody");
      tbody.innerHTML = "";
      data.forEach(book => {
        const row = `
          <tr>
            <td>${book.book_key}</td>
            <td>${book.book_reg_no}</td>
            <td>${book.book_title}</td>
            <td>${book.book_author}</td>
            <td>${book.book_publisher}</td>
            <td>
              <button class="update" onclick="openBookForm('${book.book_key}')">✏️</button>
              <button class="delete" onclick="deleteBook('${book.book_key}')">🗑️</button>
            </td>
          </tr>`;
        tbody.insertAdjacentHTML("beforeend", row);
      });
    })
    .catch(err => console.error("도서 목록 로드 실패:", err));
}

// 도서 추가/수정 모달 열기
function openBookForm(bookKey) {
  const modal = document.getElementById("bookModal");
  const title = document.getElementById("modalTitle");
  const saveButton = document.getElementById("saveButton");
  const isUpdate = !!bookKey;

  if (isUpdate) {
    title.textContent = "도서 수정";
    fetch(`${BASE_URL}/${bookKey}`)
      .then(res => res.json())
      .then(book => {
        document.getElementById("book_key").value = book.book_key;
        document.getElementById("book_reg_no").value = book.book_reg_no;
        document.getElementById("book_title").value = book.book_title;
        document.getElementById("book_author").value = book.book_author;
        document.getElementById("book_publisher").value = book.book_publisher;

        document.getElementById("book_key").readOnly = true;

        // 이벤트 중복 방지
        saveButton.replaceWith(saveButton.cloneNode(true));
        const newSaveButton = document.getElementById("saveButton");
        newSaveButton.addEventListener("click", () => saveBook(true));

        modal.style.display = "block";
      })
      .catch(err => console.error("Error loading book for update:", err));
  } else {
    title.textContent = "도서 추가";
    document.getElementById("book_key").value = "";
    document.getElementById("book_reg_no").value = "";
    document.getElementById("book_title").value = "";
    document.getElementById("book_author").value = "";
    document.getElementById("book_publisher").value = "";

    document.getElementById("book_key").readOnly = false;

    saveButton.replaceWith(saveButton.cloneNode(true));
    const newSaveButton = document.getElementById("saveButton");
    newSaveButton.addEventListener("click", () => saveBook(false));

    modal.style.display = "block";
  }
}

// 저장 (추가/수정)
function saveBook(isUpdate) {
  const book = {
    book_key: document.getElementById("book_key").value,
    book_reg_no: document.getElementById("book_reg_no").value,
    book_title: document.getElementById("book_title").value,
    book_author: document.getElementById("book_author").value,
    book_publisher: document.getElementById("book_publisher").value
  };

  const url = isUpdate ? `${BASE_URL}/${book.book_key}` : `${BASE_URL}/new`;
  const method = isUpdate ? "PUT" : "POST";

  fetch(url, {
    method: method,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(book)
  })
    .then(res => {
      if (!res.ok) throw new Error("저장 실패");
      return res.json();
    })
    .then(() => {
      closeModal();  
      loadBookList();
    })
    .catch(err => alert(err.message));
}

// 도서 삭제
function deleteBook(bookKey) {
  if (!confirm("정말 삭제하시겠습니까?")) return;
  fetch(`${BASE_URL}/${bookKey}`, { method: "DELETE" })
    .then(res => {
      if (!res.ok) throw new Error("삭제 실패");
      loadBookList();
    })
    .catch(err => alert(err.message));
}

// 모달 닫기
function closeModal() {
  document.getElementById("bookModal").style.display = "none";
}

// 전역 노출
window.openBookForm = openBookForm;
window.closeModal = closeModal;
