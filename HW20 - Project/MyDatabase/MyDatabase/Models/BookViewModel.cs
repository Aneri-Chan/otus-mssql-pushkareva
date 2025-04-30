namespace MyDatabase.Models
{
    public class BookViewModel
    {
        public int BookID { get; set; }
        public string BookName { get; set; }
        public string PhotoLink { get; set; } // Ссылка на изображение
        public int Price { get; set; } // Цена в целых числах (без копеек)
    }
}
