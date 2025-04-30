using System.ComponentModel.DataAnnotations;

public class ProfileUpdateViewModel
{
    [Required(ErrorMessage = "ФИО обязательно")]
    [RegularExpression(@"^[А-Яа-яЁё\s\-]+$", ErrorMessage = "ФИО должно содержать только русские буквы")]
    [StringLength(100, MinimumLength = 3, ErrorMessage = "ФИО должно содержать минимум 3 символа")]
    public string CustomerName { get; set; }


    [Required]
    [EmailAddress(ErrorMessage = "Введите корректный email")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Телефон обязателен")]
    [StringLength(12, MinimumLength = 11, ErrorMessage = "Номер телефона должен содержать от 11 до 12 символов")]
    [RegularExpression(@"^\d{11,12}$", ErrorMessage = "Номер телефона должен содержать от 11 до 12 символов")]
    public string PhoneNumber { get; set; }

}

public class ChangePasswordViewModel
{
    [Required(ErrorMessage = "Введите новый пароль")]
    [DataType(DataType.Password)]
    public string NewPassword { get; set; }

    [Required(ErrorMessage = "Подтвердите новый пароль")]
    [Compare("NewPassword", ErrorMessage = "Пароли не совпадают")]
    [DataType(DataType.Password)]
    public string ConfirmPassword { get; set; }
}

public class PhoneCheckRequest
{
    public string PhoneNumber { get; set; }
    public string Email { get; set; }
}