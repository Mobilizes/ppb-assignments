# Tugas Pertemuan 3: Widget & State

## A. Program dari ALPRO
Dari ALPRO, disediakan versinya sendiri di repository `mobile_programming` di bagian 4. Di dalam MyApp di dalam aplikasi ini, terdapat 2 widget kustom lainnya.

### 1. RowColumnPage (StatelessWidget)
RowColumnPage adalah home di MyApp yang bertanggung jawab untuk menulis semua card dalam aplikasinya. RowColumnPage berisikan Scaffold untuk membentuk framework di dalam widget untuk mempermudah pemisahan appBar dan body.  
Body di dalam Scaffold nya adalah sebuah Column yang berisikan semua container yang ingin diperlihatkan ke user.  
RowColumnPage bersifat stateless karena class itu sendiri tidak ada memerlukan penyimpanan state.

### 2. CounterCard (StatefulWidget)
CounterCard adalah widget yang bertujuan untuk merekam berapa kali tombol counter ditekan dalam widget ini.  
CounterCard bersifat stateful karena untuk menghitung berapa kali tombolnya ditekan selama runtime, diperlukan perubahan state dalam widget.  
Untuk menyimpan counternya, diperlukan fungsi `_incrementCounter` yang menggunakan `setState` untuk mengganti nilai sebuah variabel selama runtime.

## B. Program sendiri
Di dalam programming aplikasi ini, dijalankan class MyApp (StatelessWidget) yang berfungsi sebagai akar dari widget-widget yang dibuat di dalam aplikasi ini.  
Di dalam MyApp ini, dipakai 4 widget kustom, yaitu:

### 1. ImageCard (StatelessWidget)
ImageCard adalah widget yang tujuan utamanya menampilkan gambar di MyApp. ImageCard ini menerima widget Image sebagai parameter dengan tujuan kemungkinan reusability.  
Alasan utama ImageCard ini stateless karena tidak akan ada perubahan data di dalam widget ini selama runtime, jadi tidak diperlukan fungsionalitas StatefulWidget.

### 2. QuestionCard (StatelessWidget)
QuestionCard adalah widget yang tujuan utamanya memberikan pertanyaan berupa teks biasa di MyApp. QuestionCard juga menerima widget Text sebagai parameter dengan tujuan kemungkinan reusability.  
QuestionCard diberikan sifat stateless dengan alasan yang sama dengan ImageCard, karena tidak diperlukannya fungsionalitas StatefulWidget.

### 3. AnswerCard (StatelessWidget)
AnswerCard adalah widget yang tujuan utamanya memberikan opsi jawaban di MyApp. AnswerCard juga menerima List widget AnswerCardOption sebagai parameter dengan tujuan kemungkinan reusability.  
AnswerCard sendiri stateless karena opsi jawab tidak akan bertambah selama runtime. Walau AnswerCardOption adalah StatefulWidget, AnswerCard itu sendiri StatelessWidget.

### 3.5. AnswerCardOption (StatefulWidget)
AnswerCardOption adalah widget yang merepresentasikan opsi-opsi jawab di AnswerCard. AnswerCardOption menerima Icon dan Text sebagai parameter dengan tujuan kemungkinan reusability.  
Sementara AnswerCardOption stateful karena kemungkinan masing-masing opsi mengeluarkan hasil yang berbeda, tetapi untuk sekarang, tidak ada implementasi jika opsi ditekan.

### 4. CounterCard (StatefulWidget)
CounterCard adalah widget yang bertujuan untuk merekam berapa kali tombol counter ditekan dalam widget ini. CounterCard tidak menerima parameter apa apa.  
CounterCard bersifat stateful karena untuk menghitung berapa kali tombolnya ditekan selama runtime, diperlukan perubahan state dalam widget.
