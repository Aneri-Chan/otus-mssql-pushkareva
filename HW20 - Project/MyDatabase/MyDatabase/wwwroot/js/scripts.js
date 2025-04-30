function performSearch() {
    var query = document.getElementById('searchInput').value;
    alert('Searching for: ' + query);
    // Здесь можно добавить логику для выполнения поиска
}

function updateCartCount() {
    $.get('/Cart/GetCartItemCount', function (data) {
        $('#cart-count').text(data.count);
    });
}


// например: вызывать при добавлении в корзину:
function updateCartCount(count) {
    $('#cart-count').text(count);
}

function addToCart(bookID, quantity) {
    $.post("/Cart/AddToCart", { bookID: bookID, quantity: quantity })
        .done(function (data) {
            if (data.success) {
                $("#cart-count").text(data.cartCount);
            }
        })
        .fail(function (xhr) {
            alert("Ошибка: " + xhr.responseText);
        });
}


$(document).ready(function () {
    $.get('/Cart/GetCartItemCount', function (data) {
        updateCartCount(data.count);
    });
});



