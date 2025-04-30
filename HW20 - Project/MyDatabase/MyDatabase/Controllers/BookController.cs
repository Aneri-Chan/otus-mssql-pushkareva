using Microsoft.AspNetCore.Mvc;
using System.Linq;
using MyDatabase.Models;
using MyDatabase.Data;

namespace MyDatabase.Controllers
{
    public class BookController : Controller
    {
        private readonly ApplicationDbContext _context;

        public BookController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Метод для отображения всех книг
        public IActionResult AllBooks()
        {
            ViewData["Categories"] = _context.Categories.ToList(); // Передаём категории

            var books = _context.Books
                .Select(b => new BookViewModel
                {
                    BookID = b.BookID,
                    BookName = b.BookName,
                    Price = (int)b.Price,
                    PhotoLink = _context.PhotoBooks
                        .Where(pb => pb.BookID == b.BookID)
                        .Select(pb => pb.PhotoLink)
                        .FirstOrDefault() ?? "/default/no-image.jpg"
                })
                .ToList();

            return View(books);
        }

        public IActionResult NewBooks()
        {
            // Получаем список книг, у которых New = 1
            var newBooks = _context.Books
                .Where(b => b.New == true)
                .Select(b => new BookViewModel
                {
                    BookID = b.BookID,
                    BookName = b.BookName,
                    Price = (int)b.Price,
                    PhotoLink = _context.PhotoBooks
                        .Where(pb => pb.BookID == b.BookID)
                        .Select(pb => pb.PhotoLink)
                        .FirstOrDefault() ?? "/default/no-image.jpg"
                })
                .ToList();

            // Если нет новинок, возвращаем сообщение
            if (!newBooks.Any())
            {
                return Content("Пока нет новинок.");
            }

            // Возвращаем представление, где будут показаны новинки
            return View("BooksByCategory", newBooks); // Используем уже готовый шаблон
        }


        public IActionResult BookDetails(int id)
        {
            var book = _context.Books
                .Where(b => b.BookID == id)
                .Select(b => new BookViewModel
                {
                    BookID = b.BookID,
                    BookName = b.BookName,
                    Price = (int)b.Price,
                    PhotoLink = _context.PhotoBooks
                        .Where(pb => pb.BookID == b.BookID)
                        .Select(pb => pb.PhotoLink)
                        .FirstOrDefault() ?? "no-image.jpg"
                })
                .FirstOrDefault();

            if (book == null) return NotFound();

            return View(book);
        }



        public IActionResult Search(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return RedirectToAction("Index", "Home");
            }

            var books = _context.Books
                .Where(b => (b.BookName ?? "").Contains(query) || (b.Author ?? "").Contains(query))
                .ToList();

            return View(books);
        }
    }
}
