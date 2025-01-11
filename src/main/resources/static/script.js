// Helper function for handling fetch response
function handleFetchResponse(response) {
  if (!response.ok) {
    return response.json().then((errorData) => {
      throw new Error(errorData.message || "Failed to process request.");
    });
  }
  return response.json();
}

// Fetch books and populate the table
function fetchBooks() {
  fetchData("GET", "http://localhost:8080/book")
    .then((data) => {
      const bookTable = document.getElementById("bookTable").getElementsByTagName("tbody")[0];
      bookTable.innerHTML = "";
      data.forEach((book) => bookTable.appendChild(createBookRow(book)));
    })
    .catch((error) => {
      console.error("Error fetching books:", error);
      showMessage("Error fetching books.", false);
    });
}

// Send a request to fetch, add, update, or delete books
function fetchData(method, url, body = null) {
  const options = {
    method: method,
    headers: {
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : null,
  };

  return fetch(url, options)
    .then(handleFetchResponse)
    .catch((error) => {
      console.error(`Error with ${method} request:`, error);
      showMessage(error.message, false);
    });
}

// Create a row for the book table
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

// Load book details into the update form
function loadBookForUpdate(bookKey) {
  fetchData("GET", `http://localhost:8080/book/${bookKey}`)
    .then((book) => {
      document.getElementById("update_book_key").value = book.book_key;
      document.getElementById("update_book_reg_no").value = book.book_reg_no;
      document.getElementById("update_book_title").value = book.book_title;
      document.getElementById("update_book_author").value = book.book_author;
      document.getElementById("update_book_publisher").value = book.book_publisher;
      openModal("updateModal");
    })
    .catch((error) => console.error("Error loading book for update:", error));
}

// Add a new book
function addBook(event) {
  event.preventDefault();
  const bookInfo = getBookFormData("addBookForm");

  fetchData("POST", "http://localhost:8080/book/new", bookInfo)
    .then(() => {
      showMessage("Book added successfully!");
      fetchBooks();
      resetFormFields("addBookForm");
    })
    .catch((error) => {
      showMessage(error.message, false);
    });
}

// Update book details
function updateBook(event) {
  event.preventDefault();
  const bookKey = document.getElementById("update_book_key").value;
  const bookInfo = getBookFormData("updateBookForm");

  fetchData("PUT", `http://localhost:8080/book/${bookKey}`, bookInfo)
    .then(() => {
      showMessage("Book updated successfully!");
      fetchBooks();
      closeModal("updateModal");
    })
    .catch((error) => {
      showMessage(error.message, false);
    });
}

// Delete a book
function deleteBook(bookKey, buttonElement) {
  if (!confirm("Are you sure you want to delete this book?")) return;

  fetchData("DELETE", `http://localhost:8080/book/${bookKey}`)
    .then(() => {
      showMessage("Book deleted successfully!");
      const row = buttonElement.closest("tr");
      row.remove();
    })
    .catch((error) => {
      showMessage(error.message, false);
    });
}

// Extract book form data
function getBookFormData(formId) {
  const form = document.getElementById(formId);
  const formData = {
    book_key: form.querySelector("#book_key_input")?.value || form.querySelector("#update_book_key").value,
    book_reg_no: form.querySelector("#add_book_reg_no")?.value || form.querySelector("#update_book_reg_no").value,
    book_title: form.querySelector("#add_book_title")?.value || form.querySelector("#update_book_title").value,
    book_author: form.querySelector("#add_book_author")?.value || form.querySelector("#update_book_author").value,
    book_publisher: form.querySelector("#add_book_publisher")?.value || form.querySelector("#update_book_publisher").value,
  };

  return formData;
}

// Display success or error messages
function showMessage(message, isSuccess = true) {
  const messageBox = document.getElementById("messageBox");
  messageBox.innerText = message;
  messageBox.style.display = "block";
  messageBox.classList.toggle("success", isSuccess);
  messageBox.classList.toggle("error", !isSuccess);
  setTimeout(() => (messageBox.style.display = "none"), 3000);
}

// Open modal
function openModal(modalId) {
  document.getElementById(modalId).style.display = "block";
}

// Close modal
function closeModal(modalId) {
  document.getElementById(modalId).style.display = "none";
}

// Close modal when clicking outside of it
window.onclick = function (event) {
  const modals = document.querySelectorAll(".modal");
  modals.forEach((modal) => {
    if (event.target === modal) {
      modal.style.display = "none";
    }
  });
};

// Reset form fields
function resetFormFields(formId) {
  const form = document.getElementById(formId);
  form.reset();
}

// Fetch books when the page loads
fetchBooks();
