import MySQLdb as mdb
db = mdb.connect(host='localhost', user='root', password='', database='light_meter_pav')

class QwSql():

    def get_combo(self):
        cur = db.cursor()
        rows = cur.execute(f"SELECT * FROM meter_devise ")
        data_qw = cur.fetchall()
        cur.close()
        return data_qw


    def get_benefits(self, id):
        cur = db.cursor()
        rows = cur.execute(f"CALL `HP1`('{id}')")
        data_qw = cur.fetchall()
        cur.close()
        return data_qw


    def get_tarifs(self):
        cur = db.cursor()
        rows = cur.execute(f"select * from tarif ")
        data_qw = cur.fetchall()
        cur.close()
        return data_qw

    def get_date(self, id):
        cur = db.cursor()
        rows = cur.execute(f"call HP2('{id}')")
        data_qw = cur.fetchall()
        cur.close()
        return data_qw

    def get_sale(self, title):
        cur = db.cursor()
        rows = cur.execute(f'SELECT rate FROM `type_of_benefits` WHERE title = "{title}";')
        data_qw = cur.fetchone()[1]
        cur.close()
        return data_qw


    def get_read(self, id_devise, current_reading):
        try:
            cur = db.cursor()
            rows = cur.execute(f"call HP3('{id_devise}', '{current_reading}')")
            data_qw = cur.fetchone()[0]
            print(data_qw)
            cur.close()
            return data_qw
        except Exception as e:
            return None



    def set_answer(self, reading, summa, id_tarif, id_devise):
        cur = db.cursor()
        rows = cur.execute(f'INSERT INTO meter_readings (date_time, readings, summa, id_tarif, id_devise) VALUES (NOW(), "{reading}", "{summa}", "{id_tarif}", "{id_devise}") ')
        db.commit()
        cur.close()
        print('Ответ добавлен')




















