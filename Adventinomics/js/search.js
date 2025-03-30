document.addEventListener('DOMContentLoaded', () => {
    fetch('../articles/articles.json')
    .then(response => response.json())
    .then(data => {
    console.log("search");
    
    var searchField = "Artificial";
    var results = [];
    data.articles.filter( (articles) => {
        if (articles.title.toLowerCase().includes(searchField.toLowerCase())) {
            results.push(articles);
        }
    });
    console.log(results);
    });
});