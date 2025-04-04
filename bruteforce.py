from flask import Flask, request, render_template, jsonify
import hashlib
import itertools
import string
import time

app = Flask(__name__)

def sifre_hashle(sifre):
    return hashlib.md5(sifre.encode()).hexdigest()

def kelime_listesi_olustur(karakterler, uzunluk):
    return (''.join(kombinasyon)
            for kombinasyon in itertools.product(karakterler, repeat=uzunluk))

def brute_force(hedef_hash, karakterler, maksimum_uzunluk, gecikme=1.0):
    for uzunluk in range(1, maksimum_uzunluk + 1):
        for sifre in kelime_listesi_olustur(karakterler, uzunluk):
            hashli_sifre = sifre_hashle(sifre)
            if hashli_sifre == hedef_hash:
                return sifre
            time.sleep(gecikme)
    return None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/bruteforce', methods=['POST'])
def bruteforce():
    json_data = request.get_json()
    hedef_hash = json_data['hedef_hash']
    karakterler = string.ascii_lowercase + string.digits
    maksimum_uzunluk = int(json_data['maksimum_uzunluk'])
    gecikme = float(json_data['gecikme'])

    bulunan_sifre = brute_force(hedef_hash, karakterler, maksimum_uzunluk, gecikme)
    if bulunan_sifre:
        return jsonify({'status': 'success', 'password': bulunan_sifre})
    else:
        return jsonify({'status': 'fail', 'message': 'Sifre bulunamadi'})

if __name__ == '__main__':
    app.run(debug=True)