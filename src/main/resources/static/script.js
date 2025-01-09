// Function to fetch and display books
function fetchBooks() {
  fetch("http://localhost:8080/book", {
    method: "GET",
    headers: {
      Accept: "*/*",
    },
  })
    .then((response) => response.json())
    .then((data) => {
      const bookTable = document.getElementById("bookTable").getElementsByTagName("tbody")[0];
      bookTable.innerHTML = "";
      data.forEach((book) => {
        const row = createBookRow(book);
        bookTable.appendChild(row);
      });
    })
    .catch((error) => console.error("Error fetching books:", error));
}

// Function to create a table row for a book
function createBookRow(book) {
  const row = document.createElement("tr");
  row.innerHTML = `
        <td>${book.book_key}</td>
        <td>${book.book_reg_no}</td>
        <td>${book.book_title}</td>
        <td>${book.book_author}</td>
        <td>${book.book_publisher}</td>
        <td>
            <button onclick="loadBookForUpdate('${book.book_key}')">Update</button>
            <button onclick="deleteBook('${book.book_key}', this)">Delete</button>
        </td>
    `;
  return row;
}

// Function to load a book's data into the update form
function loadBookForUpdate(bookKey) {
  fetch(`http://localhost:8080/book/${bookKey}`)
    .then((response) => response.json())
    .then((book) => {
      document.getElementById("update_book_key").value = book.book_key;
      document.getElementById("update_book_reg_no").value = book.book_reg_no;
      document.getElementById("update_book_title").value = book.book_title;
      document.getElementById("update_book_author").value = book.book_author;
      document.getElementById("update_book_publisher").value = book.book_publisher;
    })
    .catch((error) => console.error("Error loading book for update:", error));
}

// Add Book functionality
function addBook(event) {
  event.preventDefault();
  const bookInfo = {
    book_key: document.getElementById("book_key_input").value,
    book_reg_no: document.getElementById("add_book_reg_no").value,
    book_title: document.getElementById("add_book_title").value,
    book_author: document.getElementById("add_book_author").value,
    book_publisher: document.getElementById("add_book_publisher").value,
  };

  fetch("http://localhost:8080/book/new", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(bookInfo),
  })
    .then((response) => response.json())
    .then((data) => {
      // Optionally add the new book row to the table (if not calling fetchBooks)
      // const bookTable = document.getElementById("bookTable").getElementsByTagName("tbody")[0];
      // const row = createBookRow(data);
      // bookTable.appendChild(row);

      showMessage("Book added successfully!");
      fetchBooks(); // Refresh the book list after adding a new book
    })
    .catch((error) => {
      console.error("Error adding book:", error);
      showMessage("Error adding book.", false);
    });
}

// Update Book functionality
function updateBook(event) {
  event.preventDefault();
  const bookKey = document.getElementById("update_book_key").value;
  const bookInfo = {
    book_reg_no: document.getElementById("update_book_reg_no").value,
    book_title: document.getElementById("update_book_title").value,
    book_author: document.getElementById("update_book_author").value,
    book_publisher: document.getElementById("update_book_publisher").value,
  };

  fetch(`http://localhost:8080/book/${bookKey}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(bookInfo),
  })
    .then((response) => response.json())
    .then((data) => {
      showMessage("Book updated successfully!");
      fetchBooks(); // Refresh the book list after updating a book
    })
    .catch((error) => {
      console.error("Error updating book:", error);
      showMessage("Error updating book.", false);
    });
}

// Show message in message box
function showMessage(message, isSuccess = true) {
  const messageBox = document.getElementById("messageBox");
  messageBox.innerText = message;
  messageBox.style.display = "block";
  messageBox.classList.toggle("success", isSuccess);
  messageBox.classList.toggle("error", !isSuccess);
  setTimeout(() => (messageBox.style.display = "none"), 3000);
}

// Call fetchBooks when the page loads
fetchBooks();
