document.addEventListener('DOMContentLoaded', () => {
    // Get the author ID from the URL query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const authorId = parseInt(urlParams.get('id')); // Convert to a number

    if (!authorId) {
        console.error('No author ID provided in the URL.');
        const container = document.getElementById("authors-content");
        container.innerHTML = "<p>No author ID provided. Please specify an author.</p>";
        return;
    }

    // Fetch the authors.json file
    fetch('../articles/authors.json')
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById("authors-content");
            container.innerHTML = ""; // Clear any existing content

            // Find the author with the matching ID
            const author = data.authors.find(a => a.id === authorId);

            if (!author) {
                container.innerHTML = "<p>Author not found.</p>";
                return;
            }

            // Display the author's information
            const authorBox = document.createElement("div");
            authorBox.classList.add("article");

            const authorName = document.createElement("h2");
            authorName.textContent = author.name;
            authorBox.appendChild(authorName);

            const authorBio = document.createElement("p");
            authorBio.textContent = author.bio;
            authorBox.appendChild(authorBio);

            container.appendChild(authorBox);
        })
        .catch(error => {
            console.error('Error loading authors:', error);
            const container = document.getElementById("authors-content");
            container.innerHTML = "<p>There was an error loading the authors. Please try again later.</p>";
        });
});