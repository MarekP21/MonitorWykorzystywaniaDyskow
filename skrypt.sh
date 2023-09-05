#!/bin/bash

dla_pierwszego=1 # zmienna pomocnicza, która pomoga gdy już przy odpaleniu programu wartość graniczna jest za mała; wykorzystana po algorytmie wyświetlającym

ILE_P=12                     # Zmienna określająca ilość wyświetlanych użytkownikowi plików
declare -a Pliki[$ILE_P]     # Tablica przechowuje w późniejszej części informacje o usuwanych plikach  
declare -a Wartosci[$ILE_P]  # Tablica przechowuje informacje o wielkościach tych plików
declare -a Wybory            # Tablica z wyborami użytkownika dotyczącymi usuwanych plików
n=0                          # Licznik plików w tablicy
zmienna=0                    # Zmienna sprawdzająca na bieżąco ilość zwalnianego miejsca; służy do regulowania zmiennej "min_war"
a="y"                        # Zmienna wyznaczająca nam wybór użytkownika po przekroczeniu wartości granicznej

# Zaczynamy od w miarę dokładnej kontroli błędów
if test $# -ne 1
then
        echo "Sposób uruchomienia: $0 <wartość graniczna wolnego miejsca wyrażona w %>"
        exit 1
elif [ $(expr match "$1" "[+-]\?[0-9]\+$") -ne 0 ]
then
        if test $1 -lt 5
        then
                echo "Minimalna wartość parametru nie może być mniejsza niż 5"
                exit 2
        elif test $1 -ge 100
        then
                echo "Parametr jest wyrażony w procentach, a więc nie może być równy bądź większy od 100"
                exit 3
        else
                # Tu rozpoczyna się program główny po kontroli błędu wprowadzonego parametru
                while [ TRUE ]; do
                        clear
                        condition=0     # Zmienna kontrolująca, aby informacja o przeciążeniu dotarła do użytkownika od razu po jego wystąpieniu
                        pom=1           # Zmienna, która sprawi że nie będziemy musieli długo czekać po zwolnieniu partycji
                        echo "*Program w sposób ciągły monitoruje wolne miejsce na partycji /home/$USER*"

                        # Zmienna określająca ilość wolnego miejsca do wyświetlania
                        wm=$(df -h /home/$USER | grep / | awk '{print $4}')
                        # Zmienna określająca ilość wolnego miejsca w Kilobajtach do obliczeń
                        wmB=$(df /home/$USER | grep / | awk '{print $4}')

                        # Zmienna określająca ilość zajętego miejsca do wyświetlania
                        zm=$(df -h /home/$USER | grep / | awk '{print $3}')
                        # Zmienna określająca ilość zajętego miejsca w Kilobajtach do obliczeń
                        zmB=$(df /home/$USER | grep / | awk '{print $3}')

                        # Zmienna określająca w KiloBajtach wartość graniczną
                        wgB=$(( $(df /home/$USER | grep / | awk '{print $2}')/100*$1 ))
			
 			# Wyświetlanie potrzebnych informacji dotyczących miejsca na dysku
                        echo -e "Nazwa Dysku:\t\t\t$(df -h /home/$USER | grep / | awk '{print $1}')"
                        echo -e "Nazwa Partycji:\t\t\t/home/$USER"
                        echo -e "Ilość wykorzystanego miejsca:\t$zm, $zmB"KB" ($(df -h /home/$USER | grep / | awk '{print $5}'))"
                        echo -e "Ilość wolnego miejsca:\t\t$wm, $wmB"KB" ($(( 100-$(df -h /home/$USER | grep / | awk '{print $5}' | cut -b 1-2) ))%)"
                        echo -e "Wartość graniczna:\t\t$wgB"KB" ($1%)"


                        # Po algorytmie wyświetlającym następuje integracja z użytkownikiem
                        if test $wgB -ge $wmB
                        then
                                if test $dla_pierwszego -eq 1
                                then
                                        dla_pierwszego=2
                                elif test $condition -eq 1 || test "$a" == "n"
                                then
                                        sleep 60
                                fi
                                echo ""
                                echo "UWAGA !!! Przekroczono wartość graniczną. "
                                while [ TRUE ]; do
                                        echo -n "Czy chcesz wyczyścić partycję? (y/n) "
                                        read a
                                        if test "$a" != 'y' && test "$a" != 'n'
                                        then
                                                echo "Podaj jedną z dwóch wyświetlanych odpowiedzi"
                                        else break
                                        fi
                                done
                                if test "$a" == 'n'
                                then
                                        continue
                                else
                                        # Zmienna określająca ile pamięci należy zwolnić (w Kilobajtach)
                                        min_war=$(( $wgB - $wmB - $zmienna ))

                                        while [ TRUE ]; do
                                                # Następuje uzupełnianie zadeklarowanych na początku tablic rozmiarów i nazw plików poprzez pomocnicze pliki tekstowe
                                                # Użyte polecenia powodują że do usunięcia nie wyświetlą się pliki niezbędne do działania systemu oraz takie, do których nie mamy prawa zapisu 
                                                clear
                                                find /home/$USER -writable \( ! -path ".sh" ! -path "*/." ! -path "./Pictures/*" ! -path "*.sqlite" ! -path "*.bin" -o -path "./.cache*" -o -path "./.temp*" \) -type f -exec du -S -h -b -x {} + | sort -rh | head -$ILE_P | awk '{print $2}' > Plik.txt
                                                while read -r LINE; do
                                                        Pliki[$n]=$LINE
                                                        (( n++ ))
                                                done < Plik.txt
                                                n=0

						find /home/$USER -writable \( ! -path ".sh" ! -path "*/." ! -path "./Pictures/*" ! -path "*.sqlite" ! -path "*.bin" -o -path "./.cache*" -o -path "./.temp*" \) -type f -exec du -S -h -b -x {} + | sort -rh | head -$ILE_P | awk '{print $1}' > Plik.txt
                                                while read -r LINE; do
                                                        Wartosci[$n]=$LINE
                                                        (( n++ ))
                                                done < Plik.txt
                                                n=0
                                                rm Plik.txt

                                                # Zmienna określająca ile pamięci należy zwolnić (w bajtach)
                                                min_war=$(( min_war-$zmienna ))

                                                zmienna=0
                                                if test $min_war -ge 0
                                                then

                                                        # Informacja dla użytkownika
                                                        echo "Minimalna ilość miejsca jaką trzeba zwolnić, aby nie przekraczać wartości granicznej to "$min_war"KB"
                                                        # Wyświetlenie propozycji użytkownikowi
                                                        echo "Pliki zaproponowane do usunięcia od rozmiarów o wartościach największych: "

                                                        c=1
                                                        while [ $c -le $ILE_P ]; do
                                                                echo -e -n $c".\t"${Wartosci[$c-1]}"B\t\t"${Pliki[$c-1]}
                                                                (( c++ ))
                                                                echo ""       
                                                        done
                                                        licznik=0
                                                        echo ""
                                                        echo "Wprowadzaj numery plików, które chcesz usunąć. Gdy uznasz, że chcesz zakończyć wprowadź \"0\". Jeśli chcesz usunąć wszytkie wyświetlone pliki wprowadź \"13\"."
                                                        while [ TRUE ]; do
                                                                echo -n "Wprowadz $(( $licznik + 1 )) numer: "  
                                                                read w
                                                                if [ $(expr match "$w" "[+-]\?[0-9]\+$") -eq 0 ]
                                                                then
                                                                        echo "Podany argument nie jest liczbą całkowitą. Ponów próbę."
                                                                elif test $w -lt 0 || test $w -gt $(( $ILE_P + 1 ))
                                                                then
                                                                        echo "Podana wartość musi mieścić się w przedziale 1-13. Ponów próbę."
                                                                elif test $w -gt 0 && test $w -le $ILE_P
								then
                                                                        Wybory[$licznik]=$w
                                                                        (( licznik++ ))
                                                                elif test $w -eq 13
                                                                then
                                                                        for i in {1..12}
                                                                        do
                                                                                Wybory[$licznik]=$i
                                                                                (( licznik++ ))
                                                                        done
                                                                        break
                                                                else
                                                                        echo "Zakonczono Wprowadzanie informacji."
                                                                        break
                                                                fi
                                                        done
                                                        if test $w -eq 13
                                                        then
                                                                echo "Usunięto wszystkie wyświetlone Tobie pliki. (odświeżenie informacji za 10 sekund)"
                                                                zapis=hdguard_$(date +%F)_$(date +%H):$(date +%M).deleted
                                                                touch $zapis
                                                                for (( m=0; m<licznik; m++ ))
                                                                do
                                                                         echo ${Pliki[${Wybory[$m]}-1]}>>$zapis          # Następuje zapis wszystkich usuniętych plików do pliku wynikowego
                                                                         zmienna=$(( zmienna+$(( ${Wartosci[${Wybory[$m]}-1]}/1000 )) ))
                                                                                                                         # Dzielenie przez 1000 gdyż wyświetlane wartości są w bajtach
                                                                         rm ${Pliki[${Wybory[$m]}-1]}
                                                                done
                                                                echo -e "Utworzony plik z nazwami usuniętych przez ciebie plików: "$zapis

                                                        else
                                                                echo "Usunięte pliki wraz z ich wielkościami: (odświeżenie informacji za 10 sekund)"
                                                                zapis=hdguard_$(date +%F)_$(date +%H):$(date +%M).deleted
                                                                touch $zapis
                                                                for (( m=0; m<licznik; m++ ))
								do
                                                                        echo -e -n ${Wybory[$m]}".\t"${Wartosci[${Wybory[$m]}-1]}"B\t\t"${Pliki[${Wybory[$m]}-1]}
                                                                        echo ""
                                                                        echo ${Pliki[${Wybory[$m]}-1]}>>$zapis
                                                                        zmienna=$(( zmienna+$(( ${Wartosci[${Wybory[$m]}-1]}/1000 )) ))
                                                                                                                        # Dzielenie przez 1000 gdyż wyświetlane wartości są w bajtach
                                                                        rm ${Pliki[${Wybory[$m]}-1]}
                                                                done
                                                                echo ""
                                                                echo -e "Utworzony plik z nazwami usuniętych przez ciebie plików: "$zapis

                                                        fi
                                                        sleep 10
                                                else
                                                        clear
                                                        echo "Udało sie zwolnić odpowiednią ilość miejsca. Niedługo nastąpi powrót do dalszego monitorowania partycji."
                                                        pom=0
                                                        sleep 5
                                                        break
                                                fi
                                        done
                                fi
                        fi
                        if test $pom -eq 0
                        then
                                continue
                        else
                                sleep 60
                                condition=1
                        fi
                done

        fi
else
        echo "Podany parametr nie jest liczbą całkowitą"
        exit 4
fi



