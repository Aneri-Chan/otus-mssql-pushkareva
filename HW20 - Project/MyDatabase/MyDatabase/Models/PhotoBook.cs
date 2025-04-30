using System.ComponentModel.DataAnnotations;

namespace MyDatabase.Models
{
    public class PhotoBook
    {
        [Key] // Убедитесь, что это свойство помечено как первичный ключ
        public int PhotoID { get; set; }

        public string PhotoLink { get; set; }

        public int BookID { get; set; }  // Связь с Book

        public DateTime DateInput { get; set; }

        public virtual Book Book { get; set; }
    }
}
