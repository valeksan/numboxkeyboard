// ButtonDlg.qml
import QtQuick
import QtQuick.Controls

// Наследуемся от Button из QtQuick.Controls
Button {
    id: control

    // --- Настраиваемые свойства ---
    // --- Добавляем свойство color для совместимости ---
    property color color: "white"
    // Цвет фона кнопки, когда она "включена" (on = true)
    property color backgroundColorOn: color // Используем color как базовое значение
    // Цвет фона кнопки, когда она "выключена" (on = false)
    property color backgroundColorOff: Qt.darker(color, 1.2)
    // Цвет текста кнопки
    property color textColor: "black"
    // Цвет текста, когда кнопка "включена"
    property color textColorOn: textColor
    // Цвет текста, когда кнопка "выключена"
    property color textColorOff: textColorOn
    // Жирный ли шрифт, когда кнопка "включена"
    property bool textBoldByOn: true
    // Включено ли состояние "вкл/выкл"
    property bool on: false
    // Радиус скругления фона
    property int radius: 0
    // Включено ли визуальное обозначение нажатия
    property bool enableOnPressIndicate: true
    // Внутреннее свойство для отслеживания "триггерного" нажатия
    property bool triggerPress: false

    // --- Стандартные свойства Button ---
    text: "" // Текст кнопки
    height: 50
    width: 180
    implicitHeight: height
    implicitWidth: width
    antialiasing: true

    // --- Обработчики сигналов ---
    // Вызывается, когда кнопка нажата
    onPressed: {
        triggerPress = true;
    }

    // Вызывается, когда кнопка отпущена
    onReleased: {
        triggerPress = false;
    }

    // --- Фон кнопки ---
    background: Rectangle {
        id: backgroundRect
        // Вычисляем цвет фона динамически в зависимости от состояния
        color: {
            let baseColor = control.on ? control.backgroundColorOn : control.backgroundColorOff;
            let finalColor = baseColor;

            // Если нажата мышью (down), затемняем цвет
            if (control.down) {
                finalColor = Qt.darker(baseColor, 1.5);
            }

            // Если включено "триггерное" нажатие, используем цвет "включенного" состояния
            if (control.triggerPress && control.enableOnPressIndicate) {
                finalColor = control.backgroundColorOn;
                if (control.down) {
                    finalColor = Qt.darker(control.backgroundColorOn, 1.5);
                }
            }

            return finalColor;
        }
        radius: control.radius
        border.color: Qt.darker(color, 1.5)
        border.width: 1 // Убедимся, что граница всегда видна
    }

    // --- Содержимое кнопки (текст) ---
    contentItem: Text {
        id: buttonText
        text: control.text
        // Настройка шрифта
        font.pixelSize: 16
        font.bold: {
            if (control.textBoldByOn) {
                return control.on;
            }
            // Если textBoldByOn отключено, оставляем обычное поведение
            return control.font.bold;
        }
        // Прозрачность для неактивного состояния
        opacity: control.enabled ? 1.0 : 0.3
        // Цвет текста в зависимости от состояния
        color: {
            let baseTextColor = control.on ? control.textColorOn : control.textColorOff;
            if (control.down) {
                return Qt.darker(baseTextColor, 1.5);
            }
            return baseTextColor;
        }
        // Выравнивание текста
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // --- MouseArea для дополнительной логики ---
    // Используется для сброса триггера, если курсор выходит за пределы кнопки
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true // Включаем отслеживание курсора
        acceptedButtons: Qt.NoButton // Не перехватываем клики, Button сам их обработает

        onExited: {
            // Если кнопка была "триггерно нажата", сбрасываем состояние при выходе
            if (control.triggerPress) {
                control.triggerPress = false;
            }
        }
    }
}
