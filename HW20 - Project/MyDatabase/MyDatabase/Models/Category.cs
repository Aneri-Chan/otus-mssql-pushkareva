using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

namespace MyDatabase.Models
{
    public class Category
    {
        [Key]
        public int CategoryID { get; set; }  // Первичный ключ
        [Required(ErrorMessage = "Введите название категории")]
        [StringLength(100)]
        public string CategoryName { get; set; }  // Название категории
        public ICollection<Book> Books { get; set; }
    }
}

