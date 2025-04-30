using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyDatabase.Models
{
    public class Book
    {
        [Key] // Указываем, что BookID - это первичный ключ
        public int BookID { get; set; }

        [Required]
        [Display(Name = "Название")]
        public string? BookName { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Цена должна быть больше 0")]
        public decimal Price { get; set; }

        [Required]
        public string? Author { get; set; } = string.Empty; // Используем `?`, чтобы указать, что поле может быть `NULL`

        [Range(0, double.MaxValue, ErrorMessage = "Вес должен быть положительным числом")]
        public double? Weight { get; set; }

        [Required]
        public int CategoryID { get; set; }

        [RegularExpression(@"^[A-Za-z0-9\-]*$", ErrorMessage = "Допустимы только буквы, цифры и тире")]
        public string? ISBN { get; set; }

        public bool New { get; set; }

        public bool AddCategory { get; set; }

        public bool Bestseller { get; set; }

        [Required]
        public string? Description { get; set; } = string.Empty;

        public DateTime? DateInput { get; set; }
        public virtual Category? Category { get; set; } // навигационное свойство
        public virtual ICollection<PhotoBook> Photos { get; set; } = new List<PhotoBook>();
    }
}
