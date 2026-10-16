# 37 productos reales de Servitecnicos (de la MATRIZ DE PRODUCTOS). Cantidad: sin dato -> None ("Disponible").
import json
TONER_D = ("{que} de muy buena calidad, totalmente {nuevo} y {listo} para instalar de manera sencilla y ágil.\n\n"
           "La presentación del producto puede variar de la foto publicada, pero coincide en sus características, funcionalidad y compatibilidad.\n\n"
           "Aclaración: los nombres de marcas y productos mencionados en este sitio pertenecen a sus respectivos fabricantes y se citan exclusivamente "
           "de forma informativa para indicar para qué equipos son aptos nuestros artículos. No mantenemos una relación comercial directa con las marcas.")
D_TONER = TONER_D.format(que='Cartucho de tóner', nuevo='nuevo', listo='listo')
D_UNIDAD = TONER_D.format(que='Unidad de imagen', nuevo='nueva', listo='lista')
D_TINTA = "Esta tinta combina ahorro, buena calidad y rendimiento."
D_KIT = "Este kit de tinta combina ahorro, buena calidad y rendimiento. Ideal para quienes imprimen grandes volúmenes."

def rend(n): return 'Rendimiento aprox. %s páginas (cobertura 5%%)' % n

EP66 = "L110, L200, L210, L300, L350, L355, L550, L555, L800"
EP54 = "L1110, L3110, L3150, L4150, L4160, L4171, L4191, L5190, L6161, L6171"
CA19 = "PIXMA G1100, G2100, G3100, G3102"
HPGT = "DeskJet GT 5810, GT 5820, Ink Tank 115, 318, 319, 410, Ink Tank Wireless 415, 416, 418, 419, Smart Tank 450, 455"
P2035 = "P2030, P2033, P2034, P2035, P2035n, P2036, P2037"

T = 'Tóners'; R = 'Repuestos'; I = 'Tintas'
P = [
 ('TN-SA-116L','Tóner compatible Samsung MLT-D116L',T,'Samsung','Compatible',55000,rend('3.000'),"M2625, M2625D, M2823DW, M2825WN, M2825DW, M2885FW, SL-M2675FN, SL-M2875FW, SL-M2875FD, SL-M2835",D_TONER),
 ('TN-HP-CF248A','Tóner compatible HP CF248A',T,'HP','Compatible',60000,rend('1.000'),"LaserJet Pro M15, M15a, M15w, MFP M28, MFP M28a, MFP M28w",D_TONER),
 ('TN-SA-111L','Tóner compatible Samsung MLT-D111L',T,'Samsung','Compatible',70000,rend('1.800'),"M2020, M2020W, M2022, M2022W, M2026, M2027, M2070, M2070W, M2070F, M2071, M2074FW",D_TONER),
 ('TN-HP-CF283A','Tóner compatible HP CF283A',T,'HP','Compatible',50000,rend('1.500'),"LaserJet Pro MFP M125, M127fn, M127fw, M201dw, M201n, M225dn, M225dw, M225idn",D_TONER),
 ('TN-HP-Q2612A','Tóner compatible HP Q2612A',T,'HP','Compatible',55000,rend('2.000'),"LaserJet 1010, 1012, 1015, 1018, 1020, 1022, 1022n, 1022nw, 3015 MFP, 3020 MFP, 3030 MFP, 3050 MFP, 3050Z, 3052 MFP, 3055 MFP, M1005 MFP",D_TONER),
 ('TN-HP-CE285A-U','Tóner universal compatible HP CE285A / CB435A / CB436A / CE278A',T,'HP','Compatible · universal',50000,rend('1.500 a 2.000'),"LaserJet P1004, P1005, P1006, P1006dn, P1102, 1505, P1505n, 1506n, P1566, P1607, 1522, M1522nf, M1130, M1132, M1134, M1210, M1212nf, M1218nf, M1219nf, M1530, M1536, M1537, M1538dn, M1539dnf",D_TONER),
 ('TN-HP-CF237A','Tóner compatible HP CF237A',T,'HP','Compatible',190000,rend('11.000'),"LaserJet Enterprise M607, M608, M609, MFP M631, MFP M632, MFP M633",D_TONER),
 ('TN-SA-119S','Tóner compatible Samsung MLT-D119S',T,'Samsung','Compatible',70000,rend('2.000'),"ML-1610, ML-1615, ML-1620, ML-1625, ML-2010, ML-2015, ML-2020, ML-2510, ML-2570, ML-2571, SCX-4321, SCX-4521",D_TONER),
 ('TN-SA-101S','Tóner compatible Samsung MLT-D101S',T,'Samsung','Compatible',70000,rend('1.500'),"ML-2160, ML-2161, ML-2162, ML-2164, ML-2165, ML-2165W, ML-2167, ML-2168W, SCX-3400, SCX-3405, SCX-3405FW, SCX-3407, SF-760P",D_TONER),
 ('TN-HP-CF280A','Tóner compatible HP CE505A / CF280A',T,'HP','Compatible',70000,rend('2.500'),"LaserJet "+P2035+", P2050, P2053, P2053dn, P2053x, P2054, P2055, P2055d, P2056, P2056dn, P2056x, P2057, P2057dn, P2057x, LaserJet Pro 400 M401a, M401d, M401n, M401dn, M401dw, M425dn, M425dw, Canon 6300, Canon 6650, Canon MF5870dn",D_TONER),
 ('TN-HP-CF280X','Tóner compatible HP CE505X / CF280X',T,'HP','Compatible · alto rendimiento',95000,rend('6.500'),"LaserJet P2050, P2053, P2053dn, P2053x, P2054, P2054dn, P2054x, P2055, P2055dn, P2055x, P2056, P2056dn, P2056x, P2057, P2057dn, P2057x, LaserJet Pro 400 M401a, M401d, M401n, M401dn, M401dw, M425dn, M425dw, Canon LBP6300, Canon LBP6650, Canon MF5870dn",D_TONER),
 ('TN-HP-CF226X','Tóner compatible HP CF226X',T,'HP','Compatible · alto rendimiento',95000,rend('9.000'),"LaserJet Pro M402dn, M402n, M402dw, MFP M426dw, MFP M426fdn, MFP M426fdw",D_TONER),
 ('TN-HP-W1500A','Tóner compatible HP W1500A',T,'HP','Compatible',75000,rend('970'),"LaserJet MFP M141w, MFP M141a, MFP M111w, MFP M111a",D_TONER),
 ('TN-HP-CF217A','Tóner compatible HP CF217A',T,'HP','Compatible',60000,rend('1.600'),"LaserJet Pro M102, M102a, M102w, MFP M130, MFP M130a, MFP M130fw, MFP M130fn, MFP M130nw",D_TONER),
 ('RP-HP-CF232A','Unidad de imagen compatible HP CF232A',R,'HP','Unidad de imagen compatible',80000,'Unidad de imagen (tambor)',"LaserJet M203, M203dn, M203dw, M206, M206dn, MFP M227, M227fdw, M227sdn, MFP M230, M230fdw, M230sdn",D_UNIDAD),
 ('RP-HP-CF219A','Unidad de imagen compatible HP CF219A',R,'HP','Unidad de imagen compatible',80000,'Unidad de imagen (tambor)',"LaserJet Pro M102a, M102w, M104a, M104w, MFP M130a, M130fw, M130nw, M130fn, MFP M132a, M132fw, M132nw, M132fn",D_UNIDAD),
 ('TN-HP-W1360X','Tóner compatible HP W1360X',T,'HP','Compatible · alto rendimiento',80000,'Tóner negro',"LaserJet MFP M236sdw, MFP M236dw, M236sdn, M236d, LaserJet M211d, M211dw",D_TONER),
 ('TI-EP-660K','Tinta compatible Epson 660 negra 100 ml',I,'Epson','Botella compatible',13000,'100 ml',EP66,D_TINTA),
 ('TI-EP-665C','Tinta compatible Epson 665 cian 100 ml',I,'Epson','Botella compatible',13000,'100 ml',EP66,D_TINTA),
 ('TI-EP-666M','Tinta compatible Epson 666 magenta 100 ml',I,'Epson','Botella compatible',13000,'100 ml',EP66,D_TINTA),
 ('TI-EP-667Y','Tinta compatible Epson 667 amarilla 100 ml',I,'Epson','Botella compatible',13000,'100 ml',EP66,D_TINTA),
 ('TI-EP-544K','Tinta compatible Epson 504/544 negra 70 ml',I,'Epson','Botella compatible',13000,'70 ml',EP54,D_TINTA),
 ('TI-EP-544C','Tinta compatible Epson 504/544 cian 70 ml',I,'Epson','Botella compatible',13000,'70 ml',EP54,D_TINTA),
 ('TI-EP-544Y','Tinta compatible Epson 504/544 amarilla 70 ml',I,'Epson','Botella compatible',13000,'70 ml',EP54,D_TINTA),
 ('TI-EP-544M','Tinta compatible Epson 504/544 magenta 70 ml',I,'Epson','Botella compatible',13000,'70 ml',EP54,D_TINTA),
 ('TI-CA-GI190K','Tinta compatible Canon K-190 negra 135 ml',I,'Canon','Botella compatible',20000,'135 ml',CA19,D_TINTA),
 ('TI-CA-GI190C','Tinta compatible Canon C-190 cian 70 ml',I,'Canon','Botella compatible',15000,'70 ml',CA19,D_TINTA),
 ('TI-CA-GI190Y','Tinta compatible Canon Y-190 amarilla 70 ml',I,'Canon','Botella compatible',15000,'70 ml',CA19,D_TINTA),
 ('TI-CA-GI190M','Tinta compatible Canon M-190 magenta 70 ml',I,'Canon','Botella compatible',15000,'70 ml',CA19,D_TINTA),
 ('TI-HP-GT51K','Tinta compatible HP GT-51 negra 100 ml',I,'HP','Botella compatible',15000,'100 ml',HPGT,D_TINTA),
 ('TI-HP-GT52C','Tinta compatible HP GT-52 cian 100 ml',I,'HP','Botella compatible',15000,'100 ml',HPGT,D_TINTA),
 ('TI-HP-GT52Y','Tinta compatible HP GT-52 amarilla 100 ml',I,'HP','Botella compatible',15000,'100 ml',HPGT,D_TINTA),
 ('TI-HP-GT52M','Tinta compatible HP GT-52 magenta 100 ml',I,'HP','Botella compatible',15000,'100 ml',HPGT,D_TINTA),
 ('TI-CA-GI190-KIT','Kit de tintas compatibles Canon 190 (negro, cian, amarillo y magenta)',I,'Canon','Kit de colores compatible',63000,'4 botellas · N, C, A, M',"PIXMA G1100, G1110, G2100, G2101, G2110, G2111, G3100, G3101, G3102, G3110, G3111, G4100, G4102, G4110, G4111",D_KIT),
 ('TI-EP-660-KIT','Kit de tintas compatibles Epson 660 / 665 / 666 / 667',I,'Epson','Kit de colores compatible',63000,'4 botellas · N, C, A, M',EP66,D_KIT),
 ('TI-EP-544-KIT','Kit de tintas compatibles Epson 504/544 (negro, cian, amarillo y magenta)',I,'Epson','Kit de colores compatible',50000,'4 botellas · N, C, A, M',EP54,D_KIT),
 ('TI-HP-GT5152-KIT','Kit de tintas compatibles HP GT-51 / GT-52 (negro, cian, amarillo y magenta)',I,'HP','Kit de colores compatible',58000,'4 botellas de 100 ml · N, C, A, M',HPGT,D_KIT),
]
import os
NFOT = {c: len([f for f in os.listdir('/home/claude/servitecnicosclaude/media/fotos') if f.startswith(c + '-') and f[len(c)+1:-4].isdigit()]) for c, *_ in P}
COLID = {'Tóners': 'toners', 'Tintas': 'tintas', 'Repuestos': 'repuestos', 'Impresoras': 'impresoras'}

def fotos(c): return ['media/fotos/%s-%d.jpg' % (c, k) for k in range(1, NFOT[c] + 1)]

def js():
    return [dict(c=c, n=n, col=col, b=b, t=t, p=p, q=None, s=s, cp=cp, d=d, f=fotos(c)) for c, n, col, b, t, p, s, cp, d in P]

def q(x): return 'null' if x is None else "'" + str(x).replace("'", "''") + "'"

def sql():
    rows = []
    for c, n, col, b, t, p, s, cp, d in P:
        arr = "array[" + ",".join(q(f) for f in fotos(c)) + "]"
        rows.append("(%s,%s,%s,%s,%s,%d,null,%s,%s,%s,%s,true)" % (q(c), q(n), q(COLID[col]), q(b.lower()), q(t), p, q(s), q(cp), q(d), arr))
    return ("-- Productos reales de Servitecnicos (37). cantidad = null significa 'sin control de inventario' (se muestra Disponible).\n"
            "alter table public.productos alter column cantidad drop not null;\n"
            "alter table public.productos alter column cantidad drop default;\n"
            "update public.productos set visible=false where codigo not in (" + ",".join(q(x[0]) for x in P) + ");\n"
            "insert into public.productos (codigo,nombre,coleccion_id,marca_id,tipo,precio,cantidad,tamano,compatibilidad,descripcion,fotos,visible) values\n"
            + ",\n".join(rows) +
            "\non conflict (codigo) do update set nombre=excluded.nombre,coleccion_id=excluded.coleccion_id,marca_id=excluded.marca_id,tipo=excluded.tipo,"
            "precio=excluded.precio,precio_oferta=null,cantidad=excluded.cantidad,tamano=excluded.tamano,compatibilidad=excluded.compatibilidad,"
            "descripcion=excluded.descripcion,fotos=excluded.fotos,visible=true;\n")

if __name__ == '__main__':
    import sys
    assert len(P) == 37 and len({x[0] for x in P}) == 37
    open('/tmp/work/data/reales.json', 'w').write(json.dumps(js(), ensure_ascii=False))
    open('/home/claude/servitecnicosclaude/supabase/productos_reales.sql', 'w').write(sql())
    print('ok', sum(NFOT.values()))
