
document.addEventListener('DOMContentLoaded', () => {
    // Get the article ID from the URL query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const articleId = parseInt(urlParams.get('id')); // Get the 'id' parameter as a string

    // Log the result of urlParams to the console
    console.log('URL Parameters:', urlParams.toString());
    console.log('Article ID:', articleId);

    if (!articleId) {
        console.error('No article ID provided in the URL.');
        const container = document.getElementById("article-content");
        container.innerHTML = "<p>No article ID provided. Please specify an article.</p>";
        return;
    }
    fetch("../articles/articles.json")
    .then(response => response.json())
    .then(data => {
        const container = document.getElementById("article-content");
        container.innerHTML = ""; // Clear any existing content

        // Find the article with the matching ID
        const article = data.articles.find(a => a.id === articleId);

        if (!article) {
            container.innerHTML = "<p>Article not found.</p>";
            return;
        }

        // Display the article's information
        const articleBox = document.createElement("div");
        articleBox.classList.add("article");

        const articleTitle = document.createElement("h2");
        articleTitle.textContent = article.title;
        articleBox.appendChild(articleTitle);

        const articleContent = document.createElement("div");
        articleContent.classList.add("article-content");

        article.content.body.forEach(section => {
            if (section.title) {
            const sectionTitle = document.createElement("h3");
            sectionTitle.textContent = section.title;
            articleContent.appendChild(sectionTitle);
            }

            if (section.content) {
            const sectionContent = document.createElement("p");
            sectionContent.textContent = section.content;
            articleContent.appendChild(sectionContent);
            }
        });

        articleBox.appendChild(articleContent);
        container.appendChild(articleBox);
    })
    .catch(error => {
        console.error('Error loading articles:', error);
        const container = document.getElementById("article-content");
        container.innerHTML = "<p>There was an error loading the articles. Please try again later.</p>";
    });
}
);