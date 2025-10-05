function handleFetchResponse(response) {
  if (!response.ok) {
    return response.json().then(data => { throw new Error(data.message || "Failed"); });
  }
  return response.json();
}

function fetchData(method, url, body=null) {
  return fetch(url, { method, headers:{ "Content-Type": "application/json" }, body: body?JSON.stringify(body):null })
    .then(handleFetchResponse)
    .catch(e => { showMessage(e.message,false); throw e; });
}

function fetchBooks() {
  fetchData("GET","http://localhost:8080/book")
    .then(data => {
      const tbody = document.getElementById("bookTable").querySelector("tbody");
      tbody.innerHTML = "";
      data.forEach(book => tbody.appendChild(createBookRow(book)));
    })
    .catch(e => showMessage("Error fetching books.",false));
}

function createBookRow(book) {
  const row = document.createElement("tr");
  row.innerHTML = `
    <td>${book.book_key}</td>
    <td>${book.book_reg_no}</td>
    <td>${book.book_title}</td>
    <td>${book.book_author}</td>
    <td>${book.book_publisher}</td>
    <td>
      <button class="update" onclick="loadBookForUpdate('${book.book_key}')">✏️</button>
      <button class="delete" onclick="deleteBook('${book.book_key}',this)">🗑️</button>
    </td>`;
  return row;
}

function getBookFormData(formId){
  const form = document.getElementById(formId);
  return {
    book_key: form.querySelector("#book_key_input")?.value || form.querySelector("#update_book_key").value,
    book_reg_no: form.querySelector("#add_book_reg_no")?.value || form.querySelector("#update_book_reg_no").value,
    book_title: form.querySelector("#add_book_title")?.value || form.querySelector("#update_book_title").value,
    book_author: form.querySelector("#add_book_author")?.value || form.querySelector("#update_book_author").value,
    book_publisher: form.querySelector("#add_book_publisher")?.value || form.querySelector("#update_book_publisher").value
  };
}

function addBook(event){
  event.preventDefault();
  fetchData("POST","http://localhost:8080/book/new",getBookFormData("addBookForm"))
    .then(()=>{ showMessage("Book added successfully!"); fetchBooks(); resetFormFields("addBookForm"); });
}

function loadBookForUpdate(bookKey){
  fetchData("GET",`http://localhost:8080/book/${bookKey}`)
    .then(book=>{
      document.getElementById("update_book_key").value = book.book_key;
      document.getElementById("update_book_reg_no").value = book.book_reg_no;
      document.getElementById("update_book_title").value = book.book_title;
      document.getElementById("update_book_author").value = book.book_author;
      document.getElementById("update_book_publisher").value = book.book_publisher;
      openModal("updateModal");
    });
}

function updateBook(event){
  event.preventDefault();
  const bookKey = document.getElementById("update_book_key").value;
  fetchData("PUT",`http://localhost:8080/book/${bookKey}`,getBookFormData("updateBookForm"))
    .then(()=>{ showMessage("Book updated successfully!"); fetchBooks(); closeModal("updateModal"); });
}

function deleteBook(bookKey, btn){
  if(!confirm("Are you sure?")) return;
  fetchData("DELETE",`http://localhost:8080/book/${bookKey}`)
    .then(()=>{ showMessage("Book deleted successfully!"); btn.closest("tr").remove(); });
}

function showMessage(msg,success=true){
  const box = document.getElementById("messageBox");
  box.innerText = msg;
  box.style.display = "block";
  box.classList.toggle("success",success);
  box.classList.toggle("error",!success);
  setTimeout(()=>box.style.display="none",3000);
}

function resetFormFields(formId){ document.getElementById(formId).reset(); }
function openModal(id){ document.getElementById(id).style.display="flex"; }
function closeModal(id){ document.getElementById(id).style.display="none"; }

window.onclick = function(e){
  document.querySelectorAll(".modal").forEach(modal=>{ if(e.target===modal) modal.style.display="none"; });
}

// 페이지 로딩 시 책 목록 가져오기
fetchBooks();
