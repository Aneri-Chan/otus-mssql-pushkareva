using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Cryptography.KeyDerivation;
using System.Security.Cryptography;

namespace MyDatabase.Models
{
    [Table("Customers")] // Указываем, что это таблица Customers в БД
    public class Customer
    {
        [Key]
        public int CustomerID { get; set; } // Первичный ключ

        [Required]
        public required string CustomerName { get; set; } // ФИО

        [Required]
        [EmailAddress]
        public string Email { get; set; } // Email

        [Required]
        public required string PhoneNumber { get; set; } // Телефон

        public string? Address { get; set; } // Адрес (если нужно)

        [Required]
        public required byte[] PasswordHash { get; set; } // Разрешаем NULL

        public DateTime DateInput { get; set; } = DateTime.Now; // Дата регистрации

        // Метод для хеширования пароля
        public static byte[] HashPassword(string password)
        {
            // Генерация случайной соли
            byte[] salt = new byte[16];
            using (var rng = System.Security.Cryptography.RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            // Хеширование пароля с использованием PBKDF2 и соли
            byte[] hash = KeyDerivation.Pbkdf2(
                password: password,
                salt: salt,
                prf: KeyDerivationPrf.HMACSHA256,
                iterationCount: 10000,
                numBytesRequested: 32
            );

            // Объединяем соль и хэш в одном массиве байтов
            byte[] hashBytes = new byte[salt.Length + hash.Length];
            Array.Copy(salt, 0, hashBytes, 0, salt.Length);
            Array.Copy(hash, 0, hashBytes, salt.Length, hash.Length);

            return hashBytes;
        }



    }
}
