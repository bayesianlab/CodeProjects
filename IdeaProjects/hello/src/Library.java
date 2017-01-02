/**
 * Created by dillonflannery-valadez on 11/12/15.
 */
public class Library {
    // Add the missing implementation to this class

    String address;
    Book[] books;
    static String libHours = "The Libraries are open from 9 AM to 5 PM";


    public Library(String derecion) {
        address = derecion;
    }

    public static void print(String x) {
        System.out.println(x);
    }

    public static void printList(String[] aList) {
        for (int i = 0; i < aList.length; i++)
            System.out.println(aList[i]);
    }

    public Book[] append(Book[] list1, Book element) {
        Book[] newList;
        if (list1 == null) {
            newList = new Book[1];
            newList[0] = element;
            return newList;
        }
        int listLen = list1.length;
        newList = new Book[listLen + 1];
        for (int i = 0; i < listLen; i++) {
            newList[i] = list1[i];
        }
        newList[newList.length - 1] = element;
        return newList;
    }

    public void addBook(Book book) {
        books = append(books, book);
    }

    public static void printOpeningHours() {
        System.out.println(libHours);
    }

    public void printAddress() {
        System.out.println(address);
    }

    public void borrowBook(String bookTitle) {
        if(books == null) {
            System.out.println("No book in catalog");
        }
        else{
            for (int i = 0; i < books.length; i++) {
                if (books[i].title.equals(bookTitle)) {
                    if (books[i].borrowed) {
                        System.out.println("Sorry this is borrowed.");
                        break;
                    }
                    System.out.print("You have borrowed " + books[i].title + ".\n");
                    books[i].borrowed();
                    break;
                }
            }
        }
    }

    public void printAvailableBooks(){
        if(books == null){
            System.out.print("No books in catalog.\n");
        }
        else{
            for(int i=0; i < books.length; i++){
                if(books[i].isBorrowed() == false){
                    System.out.println(books[i].title);
                }

            }
        }
    }

    public void returnBook(String name){
        for(int i = 0; i < books.length; i++){
            if(books[i].title.equals(name)){
                books[i].returned();
                System.out.println("You have returned " + books[i].title);
                break;
            }
            }
        }


    public static void main(String[] args) {
        // Create two libraries

        Library firstLibrary = new Library("10 Main St.");
        Library secondLibrary = new Library("228 Liberty St.");

        // Add four books to the first library
        firstLibrary.addBook(new Book("The Da Vinci Code"));
        firstLibrary.addBook(new Book("Le Petit Prince"));
        firstLibrary.addBook(new Book("A Tale of Two Cities"));
        firstLibrary.addBook(new Book("The Lord of the Rings"));

//        // Print opening hours and the addresses
        System.out.println("Library hours:");
        printOpeningHours();
        System.out.println();

        System.out.println("Library addresses:");
        firstLibrary.printAddress();
        secondLibrary.printAddress();
        System.out.println();

//        String[] x = {"A"};
//        firstLibrary.borrowBook(x);
//
//        // Try to borrow The Lords of the Rings from both libraries
        System.out.println("Borrowing The Lord of the Rings:");
        firstLibrary.borrowBook("The Lord of the Rings");
        firstLibrary.borrowBook("The Lord of the Rings");
        secondLibrary.borrowBook("The Lord of the Rings");
        System.out.println();
//
//        // Print the titles of all available books from both libraries
        System.out.println("Books available in the first library:");
        firstLibrary.printAvailableBooks();
        System.out.println();
        System.out.println("Books available in the second library:");
        secondLibrary.printAvailableBooks();
        System.out.println();
//
//        // Return The Lords of the Rings to the first library
        System.out.println("Returning The Lord of the Rings:");
        firstLibrary.returnBook("The Lord of the Rings");
        System.out.println();
//
//        // Print the titles of available from the first library
        System.out.println("Books available in the first library:");
        firstLibrary.printAvailableBooks();
        System.out.println(firstLibrary.address);
    }
}