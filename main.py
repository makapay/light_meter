from light import Ui_MainWindow
from light_window import Ui_Form
import MySQLdb as mdb
from PyQt6 import QtWidgets, QtCore
from PyQt6.QtWidgets import QVBoxLayout, QCheckBox
from qwer_scrin import QwSql
from itertools import chain
from light import *
from qwer_scrin import *


class Main(QtWidgets.QMainWindow,Ui_Form):
    def __init__(self, parent=None):
        super(Main, self).__init__(parent)
        self.setupUi(self)
        self.chBox = []  # для чекбоксов
        self.sale = []  # для учёта скидок
        self.tar = None  # для тарифа
        self.read_dif = None  # для разницы показаний
        self.id_devise = None  # id прибора
        self.summa = None
        self.newRead = None  # показания счётчика
        self.id_tarif = None
        data_qw = QwSql().get_combo()
        HP1 = QwSql().get_benefits
        get_tarifs = QwSql().get_tarifs()
        for i in data_qw:
            self.comboBox.addItem(i[1])

        self.comboBox.model().item(0).setEnabled(False)
        self.comboBox.currentTextChanged.connect(lambda: self.comboChangedBackground(data_qw, HP1))
        self.btn_calc.clicked.connect(self.onClickCheck)
        self.btn_write.clicked.connect(self.setSumma)

        height = 40
        for i in get_tarifs:
            rad = QtWidgets.QRadioButton(parent=self.grBox)
            rad.setGeometry(20, height, 200, 21)
            rad.setObjectName(f"{i[1]}")
            rad.setText(f"{i[1]}")
            rad.setAccessibleName(f"{i[0]}")
            rad.setAccessibleDescription(f"{i[2]}")
            rad.toggled.connect(self.on_togled)
            height += 23

    def on_togled(self, checked):
        radio = self.sender()
        if checked:
            self.tar = float(radio.accessibleDescription())
            self.id_tarif = radio.accessibleName()
            print(self.tar)


    def onClickCheck(self):
        self.sale.clear()
        checked = (' '.join([checkbox.text() for checkbox in self.chBox if checkbox.isChecked()])).split(' ')
        for i in checked:
            if i == '':
                pass
            else:
                self.sale.append(float(QwSql().get_sale(i)))
        print(self.sale)
        print(self.id_devise)
        read = self.lineEdit.text()
        self.newRead = read

        if read == '' or self.id_devise == None:
            pass
        else:
            self.read_dif = QwSql().get_read(self.id_devise, read)

        try:
            print(self.summa)
            self.ll.setText(str(self.summa))
            self.ll.adjustSize()
        except:
            pass

    def setSumma(self):
            QwSql().set_answer(self.newRead, self.summa, self.id_tarif, self.id_devise)


    def comboChangedBackground(self, data_qw, HP1):
        # очистка layout
        while self.verticalLayout_benefits.count():
            item = self.verticalLayout_benefits.takeAt(0)
            widget = item.widget()
            if widget:
                widget.deleteLater()

        comb = self.comboBox.currentText()
        new_data_qw = list(chain.from_iterable(data_qw))
        index = new_data_qw.index(comb) - 1
        element = new_data_qw[index]
        self.id_devise = element
        HP1 = HP1(element)
        for i in HP1[0]:
            if i != None:
                self.checkbox = QCheckBox(i)
                self.chBox.append(self.checkbox)
                self.verticalLayout_benefits.addWidget(self.checkbox)

if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    wind = Main()
    wind.show()
    sys.exit(app.exec())

