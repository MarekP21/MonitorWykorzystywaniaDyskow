# Monitor Wykorzystywania Dysków
Skrypt monitorujący w sposób ciągły wolne miejsce na partycji /home/$USER – zrealizowany jako zadanie na zajęcia

<p align=justify>
  Ten skrypt w Bashu monitoruje wolne miejsce na partycji /home/$USER i automatycznie proponuje usunięcie plików, gdy ilość dostępnej przestrzeni spadnie poniżej określonej wartości granicznej podanej jako parametr (wyrażonej w procentach). Działa w pętli, stale sprawdzając stan dysku, a gdy wolne miejsce jest mniejsze niż wartość graniczna, pyta użytkownika, czy ten chce usunąć pliki.</p>

<p align=justify>
  Skrypt generuje listę największych plików w katalogu użytkownika (z pominięciem niektórych systemowych i ważnych typów plików). Następnie użytkownik może wybrać, które pliki usunąć, aby zwolnić potrzebną przestrzeń. Jeśli użytkownik odmówi działania, skrypt ponawia sprawdzanie po minucie. Program dynamicznie aktualizuje wyświetlane dane, a usuwanie plików odbywa się na podstawie wyborów użytkownika.</p>
