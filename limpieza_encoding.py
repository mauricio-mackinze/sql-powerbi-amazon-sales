with open(r'C:\Users\mmack\dataAn\train.csv', 'r', encoding='cp1252', errors='replace') as f_in:
    contenido = f_in.read()

with open(r'C:\Users\mmack\dataAn\train_utf8.csv', 'w', encoding='utf-8') as f_out:
    f_out.write(contenido)
