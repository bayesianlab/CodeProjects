

document.addEventListener('DOMContentLoaded', () => {
  fetch('../articles/articles.json')
    .then(response => response.json())
    .then(data => {

      const container = document.getElementById("newest");
      container.innerHTML = "";
      data.articles.forEach(article => {
        const articleBox = document.createElement("div");
        articleBox.classList.add("article-box");
        
        const articleLink = document.createElement("a");
        articleLink.href = `article.html?id=${article.id}`;
        
        const title = document.createElement("h2");
        title.textContent = article.title;
        articleLink.appendChild(title);
        
        const authorLink = document.createElement("a");
        authorLink.href = `authors.html?id=${article.authorid}`;
        const author = document.createElement("p");
        author.textContent = article.author;
        authorLink.appendChild(author); 
        
        const date = document.createElement("p");
        date.textContent = article.date;
        
        const intro = document.createElement("p");
        intro.textContent = article.content.intro;

      
        articleBox.appendChild(articleLink);
        articleBox.appendChild(authorLink); 
        articleBox.appendChild(date);
        container.appendChild(articleBox);

      }
      );

    }
    )
    .catch(error => {
      // If an error occurs during the fetch or processing, log it to the console
      console.error('Error loading articles:', error);
      const container = document.getElementById("newest");
      container.innerHTML = "<p>There was an error loading the articles. Please try again later.</p>";
    });
}
)
