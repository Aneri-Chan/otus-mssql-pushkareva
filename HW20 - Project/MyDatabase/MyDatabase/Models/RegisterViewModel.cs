using System.ComponentModel.DataAnnotations;

public class RegisterViewModel
{
    [Required(ErrorMessage = "Введите ФИО")]
    public string CustomerName { get; set; }

    [Required(ErrorMessage = "Введите Email")]
    [EmailAddress(ErrorMessage = "Введите корректный Email")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Введите телефон")]
    [RegularExpression(@"^\+?\d{10,15}$", ErrorMessage = "Введите корректный телефон")]
    public string PhoneNumber { get; set; }

    [Required(ErrorMessage = "Введите пароль")]
    [MinLength(6, ErrorMessage = "Пароль должен содержать минимум 6 символов")]
    [DataType(DataType.Password)]
    public string Password { get; set; }

    [Required(ErrorMessage = "Подтвердите пароль")]
    [Compare("Password", ErrorMessage = "Пароли не совпадают")]
    [DataType(DataType.Password)]
    public string ConfirmPassword { get; set; }

    [Required(ErrorMessage = "Подтвердите, что вы не робот")]
    public bool CaptchaConfirmed { get; set; }
}
