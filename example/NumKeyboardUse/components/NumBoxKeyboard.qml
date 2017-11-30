import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import "../components"

Item {
    id: dialog

    /* Минимальные размеры после которых начнется масштабирование на уменьшение панели ввода */
    property int minimumDialogHeight: 455
    property int minimumDialogWidth: 600

    /* Размеры 'окна диалога' (на чтение) */
    property alias dialogHeight: dialogPanel.height
    property alias dialogWidth: dialogPanel.width

    /* Заголовок и измерение */
    property string label: "Breasts" // "some text label"
    property string measurement: "Kg" // "Hz" or "Kg" or "Mbyte" or ...

    /* Старое значение (слегка видно перед вводом первого символа) */
    property string placeholderValue: ""
    property bool flagCurrentValueSetted: false

    /* Вид */
    property alias radius: dialogPanel.radius
    property alias colorBackground: dialogPanel.color
    property alias border: dialogPanel.border
    property alias dialogOpacity: dialogPanel.opacity
    property color displayBackground: "#f1f3f1"
    property color buttonsColors: "#f7a363"
    property color buttonsColorsOff: buttonsColors
    property color buttonsColorsOn: Qt.lighter(buttonsColorsOff, 1.5)

    /* Точность */
    property int precision: 0
    property int decimals: 0

    /* Пределы ввода */
    property double minimumValue: -Number.MAX_VALUE/2
    property double maximumValue: Number.MAX_VALUE/2

    /* Названия кнопок закрытия слоя (скрытия) */
    property string textBtOK: "ВВОД" 
    property string textBtCancel: "ОТМЕНА"

    /* Включение функции: сетка последовательности 
    (если значение не кратно sequenceStep то оно будет блокироваться на ввод кнопками) */
    property bool enableSequenceGrid: false // 
    property double sequenceStep: 0.5

    /* Сигналы */
    signal ok(var number); 	// сигнал посылается когда нажимаем кнопку 'ВВОД' и закрываем слой (если кнопка разблокирована условием непустого ввода)
    signal cancel();		// сигнал посылается когда нажимаем кнопку 'ОТМЕНА' и закрываем слой 

    /* Главные методы */
    // показать окно ввода
    function show(numberStr) {
        var tmpValue = numberStr ? getAbsValueStr(numberStr) : ""
        var countD = 0;
        dialogPanel.visible = true;
        if(tmpValue) {            
            if(decimals > 0 && minimumValue >= 0) {
                var i;
                for(i=0; i<tmpValue.length; i++) {
                    if(tmpValue[i] === '0') {
                        countD += 1;
                    } else break;
                }
                if(countD === tmpValue.length) countD -= 1;
                for(i=0; i<countD; i++) {
                    tmpValue = tmpValue.substring(1);
                }
            }
            value = toPosixTextValue(tmpValue);
            dialog.flag_minus = (parseFloat(numberStr) < 0);
        }
    }
    // скрыть окно ввода
    function hide() {
        dialogPanel.visible = false;
        flagCurrentValueSetted = false;
        value = "";
    }
    // очистить ввод
    function clear() {
        value = "";
    }
    // окно ввода открыто
    function isVisible() {
        return dialogPanel.visible;
    }    

    // -------------------------------------------------------------------------------------------------------------

    /* Системные параметры */
    property string placeholderSafeValue: getPlaceholderValueSafe()
    property bool flag_minus: false // используется для запоминания знака 
    property string value: "" // Абсолютное введеное значение(без знака)
    property string displayValue: flag_minus ? getValueStr(toLocaleTextValue(value)) : getValueStr(toLocaleTextValue(value)); // Отображаемое значение ввода на дисплее
    // -------------------------------------------------------------------------------------------------------------
    
    /* Системные методы масштабирования*/
    function fixScale() {
        if(dialog.height < minimumDialogHeight || dialog.width < minimumDialogWidth) {
            return Math.min(dialog.height/minimumDialogHeight, dialog.width/minimumDialogWidth);
        }
        return 1.0;
    } 
    // -------------------------------------------------------------------------------------------------------------   

    /* Системные методы ввода */
    // Ввести символ
    function putSymbol(sym) {
        if(isBtSymbolCorrect(sym)) {
            if(value.length === 0 && sym === '.') value = "0";
            if(value.length === 1 && value.charAt(0) === '0' && isNumericChar(sym)) {
                value = value.substring(1);
            }
            value = value + sym;
        }
    }
    // Стереть введенный символ
    function backspSymbol() {
        if(value.length === 0) return false;
        var i = value.length-1;
        value = value.substring(0,value.length-1);
        return true;
    }
    // Вставить число на ввод из буфера обмена
    function pastValue() {
        if(clipboardHelper.canPast()) {
            var buffer = clipboardHelper.past();
            var conv_text = toPosixTextValue(buffer);
            var real_value = parseFloat(conv_text);
            real_value = roundPlus(real_value, precision);
            if(real_value >= minimumValue && real_value <= maximumValue) {
                value = getAbsValueStr(real_value.toString());
                flag_minus = (real_value < 0);
            }
        }
    }
    // Скопировать введенно число в буфера обмена (или старое число если ничего не введено)
    function copyValue() {
        if(value.length > 0) {
            clipboardHelper.copy(displayText.text);
        } else if(placeholderSafeValue.length > 0) {
            clipboardHelper.copy(placeholderSafeValue);
        }
    }
    // функция авто-выбора знака ввода по умолчанию (при показе панели)
    function func_autoselect_flag_minus() {
    	if(minimumValue < 0 && maximumValue < 0) return true;
    	if(minimumValue < 0 && maximumValue >= 0) {
    		if(placeholderValue.length > 0) {
				if(Math.floor(parseFloat(placeholderValue)) >= 0) return false;
				else return true;
    		} else {
    			if(Math.abs(minimumValue*2/3) > maximumValue) return true;
    			else return false;
    		}
    	}
    	return false;
    }
    // Получить защищенный вариант старого значения (исключает некорректный ввод при нажатии кнопки '#' )
    function getPlaceholderValueSafe() {
        if(placeholderValue.length > 0) {
            var check_value = roundPlus(parseFloat(toPosixTextValue(placeholderValue)),precision)
            //console.log(check_value)
            // проверка на диапазон
            if(isNaN(check_value)) return "";
            if(!(check_value >= minimumValue && check_value <= maximumValue)) {
                return "";
            }
            // если проверка на диапазон прошла успешно то проверка на кратность (если включена)
            if(enableSequenceGrid) {
                var tmp_value = parseFloat(Number(check_value).toFixed(precision));
                var valPr = parseInt((tmp_value*Math.pow(10,precision)).toFixed(0));
                var valArgPr = parseInt((sequenceStep*Math.pow(10,precision)).toFixed(0));
                if((valPr % valArgPr) !== 0) {
                    return ""; // получившееся значение не кратно шагу последовательности!
                }
            }
            return toLocaleTextValue(check_value.toString());
        }
        return "";
    }
    // Старое значение было со знаком '-'
    function isPlaceholderSigned() {
        if(placeholderSafeValue.length > 1) {
            if(placeholderSafeValue.charAt(0) === '-') return true;
        }
        return false;
    }
    // Метод блокировки управляющих кнопок ввода (с предсказанием)
    function isBtSymbolCorrect(symbols) {
    	var result = false;
    	switch(symbols) {
		// Alg 1. - проверка на диапазон, точность и кратность
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			if(value.length > 0) {
                if(value.length > 2) {
					// проверка на то что вводим целую часть
					var index_pointer = value.indexOf('.');
                    //console.log(index_pointer)
					if(~index_pointer) {
						// символ найден, значит вводим дробную часть											
                        var fraction_precision_fact = (value.substring(index_pointer)).length-1; // фактическая точность по текущему вводу числа
						// проверка на точность
						if((fraction_precision_fact+1) > precision) {
							// точность не соблюдена!
							break;
						}
					}
				}
				// проверка на диапазон
				var new_value_str = value + symbols;
				var real_value = ((flag_minus) ? -1*parseFloat(new_value_str) : parseFloat(new_value_str)); // получение проверяемого числа
				if(isNaN(real_value)) break;
				if(real_value >= minimumValue && real_value <= maximumValue) {					
					result = true;
				} else break;
				// если проверка на диапазон прошла успешно то проверка на кратность (если включена)
                if(enableSequenceGrid) {
                    if(!isNumberInSequenceGrid(real_value,precision)) {
                        result = false; // получившееся значение не кратно шагу последовательности!
                    }
                }
            } else {
                // проверка на одиночный символ
                // проверка на диапазон
                var real_value_1s = ((flag_minus) ? -1*parseFloat(symbols+".0") : parseFloat(symbols+".0")); // получение проверяемого числа
                if(isNaN(real_value_1s)) break;
                if(real_value_1s >= minimumValue && real_value_1s <= maximumValue) {
                    result = true;
                } else break;
                // если проверка на диапазон прошла успешно то проверка на кратность (если включена)
                if(enableSequenceGrid) {
                    if(!isNumberInSequenceGrid(real_value_1s,precision)) {
                        result = false; // получившееся значение не кратно шагу последовательности!
                    }
                }
            }
    		break;
		// Alg 2.
		case '.':
			if(precision <= 0) break;
			if(value.length > 0) {
                var index_pointer_2 = value.indexOf('.');
                if(~index_pointer_2) {
					// символ найден, второй не нужен!
					break;
				} else {                    
                    // исключать точку в граничных значениях!
                    if(!isAddsPutDoteInLimitAtRange()) {
                        // входит в диапазон и не является граничным -> ввод точки
                        result = true;
                    }
				}
			} else {
				// входит ли 0 в диапазон
                if(0 >= minimumValue && 0 <= maximumValue) {
                    // исключать точку в граничных значениях!
                    if(!isAddsPutDoteInLimitAtRange()) {
                        // 0.0 входит в диапазон и не является граничным -> ввод точки с подстановкой символа '0' перед точкой
                        result = true;
                    }
				} 
			}
			break;
		// Alg 3.
		case '-':
            if(value.length > 0) {
                var real_value_3 = -1*parseFloat(value); // получение проверяемого числа
                if(real_value_3 === 0) {
                    //break;
                    if(0 === minimumValue || 0 === maximumValue) break;
                }
                // проверка на диапазон
                if(real_value_3 >= minimumValue && real_value_3 <= maximumValue) {
                    result = true;
                } else break;
            }
			break;
		// Alg 4.
		case '#':
            if(placeholderValue.length > 0) result = true;
			break;
		// Alg 5.
		case 'C':
            if(value.length > 0) result = true;
			break;
		// Alg 6.
		case '<':
            if(value.length > 0) result = true;
			break;
    	}
    	return result;
    }
    // -------------------------------------------------------------------------------------------------------------

    /* Системные вспомогательные методы */    
    // Получить строку числа со знаком
    function getValueStr(arg) {
        var valueStr;
        var countD = 0;
        valueStr = ((!flag_minus) ? arg : ("-"+arg));
        if(decimals > 0 && minimumValue >= 0) {
            var i;
            for(i=0; i<valueStr.length; i++) {
                if(isNumericChar(valueStr[i])) {
                    countD += 1;
                } else break;
            }
            for(i=0; i<(decimals-countD); i++) {
                valueStr = "0" + valueStr;
            }
        }
        return valueStr; //((!flag_minus) ? arg : ("-"+arg));
    }
    // Получить строку числа без знака
    function getAbsValueStr(arg) {
        if(arg.length > 1) {
            if(arg.charAt(0) === '-') {
                return arg.substr(1);
            }
        }
        return arg;
    }       
    // Получить символ разделителя целого числа от дробного в локализации среды
    function getSystemLocaleDecimalChar() {
        return Qt.locale("").decimalPoint;
    }    
    // Преобразование числовой строки в формат posix (для преобразований с помощью javascript)
    function toPosixTextValue(arg) {        
        var doteSymbol = getSystemLocaleDecimalChar();
        var strValue = arg;
        if(doteSymbol !== '.') {
            if(strValue.length > 0)
                strValue = strValue.replace(doteSymbol,'.')
        }
        return strValue;
    }
    // Преобразование числовой строки в формат локализации среды (для отображения)
    function toLocaleTextValue(arg) {
        var doteSymbol = getSystemLocaleDecimalChar();
        var strValue = arg;
        if(doteSymbol !== '.') {
            strValue = strValue.replace('.', doteSymbol)
        } else {
            strValue = strValue.replace(',', doteSymbol)
        }
        //console.log(strValue)
        return strValue;
    }
    // Символ является числом
    function isNumericChar(sym) {
        if (sym >= '0' && sym <= '9') {
            return true;
        }
        return false;
    }
    // Округление до точности
    function roundPlus(x, n) { //x - число, n - количество знаков
      var m = Math.pow(10,n);
      return Math.round(x*m)/m;
    }
    // Проверка числа на кратность числу шага последовательности с точностью
    function isNumberInSequenceGrid(real_value, precision) {
        if(isNaN(real_value)) return false;
        var tmp_value = roundPlus(real_value,precision);
        var valPr = parseInt((tmp_value*Math.pow(10,precision)).toFixed(0));
        var valArgPr = parseInt((sequenceStep*Math.pow(10,precision)).toFixed(0));
        if((valPr % valArgPr) === 0) {
            return true; // значение кратно шагу последовательности!
        }
        return false; 
    }
    // Проверка факта ввода точки на границах диапазона ввода
    function isAddsPutDoteInLimitAtRange() {
        var tmp_value;
        if(value.length > 0) {
            tmp_value = ((flag_minus) ? -1*parseInt(value) : parseInt(value));
        } else {
            if(0 >= maximumValue) {
                return true; // чтобы исключить ввод точки, если ничего не введено, и ноль по умолчанию для подстановки не входит в диапазон
            }
            tmp_value = 0;
        }
        var check_value_str = tmp_value+".0";
        var check_value = roundPlus(parseFloat(check_value_str), precision);
        if(!flag_minus) {
            if(check_value >= maximumValue) {
                return true
            }
        } else {
            if(check_value <= minimumValue) {
                return true
            }
        }
        return false
    }
    // -------------------------------------------------------------------------------------------------------------

    Item {
        id: clipboardHelper
        opacity: 0
        property alias buffer: helper.text
        function copy(text) {
            buffer = text;
            helper.selectAll();
            helper.copy();
        }
        function cut(text) {
            buffer = text;
            helper.selectAll();
            helper.cut()
        }
        function canPast() {
            return helper.canPaste
        }
        function past() {
            if(helper.canPaste) {
                buffer = " "
                helper.selectAll()
                helper.paste();
                return buffer;
            }
            return ""
        }
        TextEdit {
            id: helper
            text: ""
        }
    }
    Rectangle {
    	// Тень
        id: dialogMsgShadow
        visible: dialogPanel.visible
        anchors.fill: parent
        color: Qt.darker("#c0ffffff", 1.5)
        MouseArea {
            anchors.fill: parent
        }        
    }
    Rectangle {
    	// Диалоговое окно ввода
        id: dialogPanel
        anchors.centerIn: parent
        scale: fixScale()
        height: 455
        width: 600
        visible: false
        antialiasing: true
        color: "#f1eee0"
        focus: true
        onVisibleChanged: {
            if(visible === true) {
                Keys.enabled = true
            }
            //dialog.value = "" // ЭТО ЗЛОЙ КОСТЫЛЬ, КОТОРЫЙ ДОЛГО МЕНЯ ВЫМАТЫВАЛ КОГДА ДЕБАЖИЛ, НИКОГДА ТАК НЕ ДЕЛАЙ В БУДУЮЩЕМ! >:O
            dialogPanel.forceActiveFocus()
        }

        Menu {
            id: serviceMenu
            MenuItem {
                text: "Копировать"
                enabled: (value.length > 0) || (placeholderSafeValue.length > 0)
                onTriggered: {
                    copyValue();
                    dialogPanel.forceActiveFocus()
                }
            }
            MenuItem {
                text: "Вставить"
                enabled: clipboardHelper.canPast()
                onTriggered: {
                    pastValue();
                    dialogPanel.forceActiveFocus()
                }
            }
        }
        MouseArea {
            id: textArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
        ColumnLayout {
            id: contentDialogPanel
            height: parent.height
            width: parent.width
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter            
            Row {
                id: rowLabelPanel
                height: 0.1*contentDialogPanel.height
                width: parent.width
                spacing: 0
                // Область заголовка
                Text {
                    id: labelDialog
                    width: parent.width
                    height: 0.1*contentDialogPanel.height
                    color: "black"
                    text: label
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    font.bold: true
                }
            }
            RowLayout {
                id: rowDisplayPanel
                width: contentDialogPanel.width
                height: contentDialogPanel.height*0.15
                anchors.horizontalCenter: parent.horizontalCenter
                // Область индикатора ввода
                Rectangle {
                    id: displayTextDisplay
                    color: trigger_copy ? Qt.darker(displayBackground, 1.5) : displayBackground
                    border.color: Qt.darker(color, 2)
                    implicitHeight: contentDialogPanel.height*0.15
                    implicitWidth: contentDialogPanel.width-2
                    Text {
                        id: displayText
                        anchors.fill: parent
                        verticalAlignment: "AlignVCenter"
                        horizontalAlignment: "AlignHCenter"
                        text: dialog.value.length > 0 ? displayValue : placeholderValue
                        color: dialog.value.length > 0 ? "black" : "gray"
                        font.pixelSize: displayTextDisplay.height*0.65
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton | Qt.LeftButton
                        onPressAndHold: {
                            serviceMenu.x = textArea.mouseX
                            serviceMenu.y = textArea.mouseY
                            serviceMenu.open()
                        }
                        onClicked: {
                            if(mouse.button == Qt.RightButton) {
                                serviceMenu.x = textArea.mouseX
                                serviceMenu.y = textArea.mouseY
                                serviceMenu.open()
                            }
                        }

                    }
                }
            }
            Grid {
                id: gridDigits
                columns: 3
                padding: 0
                rows: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: contentDialogPanel.width+2
                height: contentDialogPanel.height*0.625
                spacing: -1
                ButtonKey {
                    id: areaCClearFront
                    height: 0.125*contentDialogPanel.height
                    width: 0.3333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    text: "#"
                    state: trigger_ftsp ? "on" : "off"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_ftsp = true
                    }
                    onReleased: {
                        if(value.length > 0) {                            
                            clear();
                            flag_minus = func_autoselect_flag_minus();
                        } else {                            
                            value = getAbsValueStr(toPosixTextValue(placeholderSafeValue));
                            flag_minus = isPlaceholderSigned();
                        }
                        trigger_ftsp = false
                        trigger_clear = false
                    }
                }
                ButtonKey {
                    id: areaCClear
                    height: 0.125*contentDialogPanel.height
                    width: 0.3333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    text: "C"
                    state: isBtSymbolCorrect('C') ? (trigger_clear ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_clear = true
                    }
                    onReleased: {
                        trigger_clear = false
                        clear();
                        flag_minus = func_autoselect_flag_minus()
                    }
                }
                ButtonKey {
                    id: areaCClearBack
                    height: 0.125*contentDialogPanel.height
                    width: 0.3333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    text: "<-"
                    state: isBtSymbolCorrect('<') ? (trigger_bksp ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_bksp = true
                    }
                    onReleased: {
                        trigger_bksp = false
                        backspSymbol();
                        if(value.length === 0) {
                            flag_minus = func_autoselect_flag_minus()
                        }
                    }
                }
                ButtonKey {
                    id: areaC7
                    text: "7"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('7') ? (trigger_7 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_7 = true
                    }
                    onReleased: {
                        trigger_7 = false
                        putSymbol('7');
                    }
                }
                ButtonKey {
                    id: areaC8
                    text: "8"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('8') ? (trigger_8 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_8 = true
                    }
                    onReleased: {
                        trigger_8 = false
                        putSymbol('8');
                    }
                }
                ButtonKey {
                    id: areaC9
                    text: "9"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('9') ? (trigger_9 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_9 = true
                    }
                    onReleased: {
                        trigger_9 = false
                        putSymbol('9');
                    }
                }
                ButtonKey {
                    id: areaC4
                    text: "4"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('4') ? (trigger_4 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_4 = true
                    }
                    onReleased: {
                        trigger_4 = false
                        putSymbol('4');
                    }
                }
                ButtonKey {
                    id: areaC5
                    text: "5"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('5') ? (trigger_5 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_5 = true
                    }
                    onReleased: {
                        trigger_5 = false
                        putSymbol('5');
                    }
                }
                ButtonKey {
                    id: areaC6
                    text: "6"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('6') ? (trigger_6 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_6 = true
                    }
                    onReleased: {
                        trigger_6 = false
                        putSymbol('6');
                    }
                }
                ButtonKey {
                    id: areaC1
                    text: "1"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('1') ? (trigger_1 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_1 = true
                    }
                    onReleased: {
                        trigger_1 = false
                        putSymbol('1');
                    }
                }
                ButtonKey {
                    id: areaC2
                    text: "2"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('2') ? (trigger_2 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_2 = true
                    }
                    onReleased: {
                        trigger_2 = false
                        putSymbol('2');
                    }
                }
                ButtonKey {
                    id: areaC3
                    text: "3"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('3') ? (trigger_3 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_3 = true
                    }
                    onReleased: {
                        trigger_3 = false
                        putSymbol('3');
                    }
                }
                ButtonKey {
                    id: areaC0
                    text: "0"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('0') ? (trigger_0 ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_0 = true
                    }
                    onReleased: {
                        trigger_0 = false
                        putSymbol('0');
                    }
                }
                ButtonKey {
                    id: areaCDote
                    text: getSystemLocaleDecimalChar()//"."
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('.') ? (trigger_dote ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_dote = true
                    }
                    onReleased: {
                        trigger_dote = false
                        putSymbol('.');
                    }
                }
                ButtonKey {
                    id: areaCMinus
                    text: "+/-"
                    height: 0.125*contentDialogPanel.height
                    width: 0.333333*contentDialogPanel.width
                    colorOn: buttonsColorsOn
                    colorOff: buttonsColorsOff
                    state: isBtSymbolCorrect('-') ? (trigger_minus ? "on" : "off") : "dimmed"
                    enableOnPressIndicate: false
                    onPressed: {
                        trigger_minus = true
                    }
                    onReleased: {
                        trigger_minus = false;
                        flag_minus = !flag_minus;
                    }                    
                }
            }
            RowLayout {
                id: rowFinishEditButtons
                height: 0.125*contentDialogPanel.height
                width: contentDialogPanel.width+1
                spacing: -1
                anchors.horizontalCenter: parent.horizontalCenter
                ButtonDlg {
                    id: btOK
                    color: "white"
                    backgroundColorOn: color
                    backgroundColorOff: Qt.darker(color, 1.2)
                    text: textBtOK
                    height: parent.height
                    width: parent.width/2
                    enabled: (value.length > 0)
                    onClicked: {                        
                        dialog.ok(getValueStr(value));
                        hide();
                    }
                }
                ButtonDlg {
                    id: btCancel
                    color: "white"
                    backgroundColorOn: color
                    backgroundColorOff: Qt.darker(color, 1.2)
                    text: textBtCancel
                    height: parent.height
                    width: parent.width/2
                    onClicked: {
                        dialog.cancel()
                        hide();
                    }
                }
            }
        }
        Keys.onPressed: {
            //console.log("Key "+/*String.fromCharCode*/(event.key)+" pressed")
            if(event.key === Qt.Key_C && event.modifiers === Qt.ControlModifier) {
                // Копирование по сочетанию CTRL+C
                trigger_copy = true;
                copyValue();
            }
            else if(event.key === Qt.Key_V && event.modifiers === Qt.ControlModifier) {
                // Вставка по сочетанию CTRL+V
                pastValue();
            }
            else if(event.key === Qt.Key_0) {
                trigger_0 = true
            }
            else if(event.key === Qt.Key_1) {
                trigger_1 = true
            }
            else if(event.key === Qt.Key_2) {
                trigger_2 = true
            }
            else if(event.key === Qt.Key_3) {
                trigger_3 = true
            }
            else if(event.key === Qt.Key_4) {
                trigger_4 = true
            }
            else if(event.key === Qt.Key_5) {
                trigger_5 = true
            }
            else if(event.key === Qt.Key_6) {
                trigger_6 = true
            }
            else if(event.key === Qt.Key_7) {
                trigger_7 = true
            }
            else if(event.key === Qt.Key_8) {
                trigger_8 = true
            }
            else if(event.key === Qt.Key_9) {
                trigger_9 = true
            }
            else if(event.key === 46 || event.key === 44) { // '.'
                trigger_dote = true
            }
            else if(event.key === 45) { // '-'
                trigger_minus = true
            }
            else if(event.key === Qt.Key_Backspace) {
                trigger_bksp = true
            }
            else if(event.key === Qt.Key_Delete) {
                trigger_ftsp = true
            }
            else if((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (value.length > 0) ) {
                dialog.ok(getValueStr(value));
                hide();
            }
            else if(event.key === Qt.Key_Space) {
                if(value.length > 0) {
                    trigger_clear = true
                } else {
                    trigger_ftsp = true
                }
            }
        }
        Keys.onReleased: {            
            if(event.key === Qt.Key_C && event.modifiers === Qt.ControlModifier) {
                trigger_copy = false;
                copyValue();
            }
            else if(event.key === Qt.Key_0) {
                trigger_0 = false
                putSymbol('0')
            }
            else if(event.key === Qt.Key_1) {
                trigger_1 = false
                putSymbol('1')
            }
            else if(event.key === Qt.Key_2) {
                trigger_2 = false
                putSymbol('2')
            }
            else if(event.key === Qt.Key_3) {
                trigger_3 = false
                putSymbol('3')
            }
            else if(event.key === Qt.Key_4) {
                trigger_4 = false
                putSymbol('4')
            }
            else if(event.key === Qt.Key_5) {
                trigger_5 = false
                putSymbol('5')
            }
            else if(event.key === Qt.Key_6) {
                trigger_6 = false
                putSymbol('6')
            }
            else if(event.key === Qt.Key_7) {
                trigger_7 = false
                putSymbol('7')
            }
            else if(event.key === Qt.Key_8) {
                trigger_8 = false
                putSymbol('8')
            }
            else if(event.key === Qt.Key_9) {
                trigger_9 = false
                putSymbol('9')
            }
            else if(event.key === 46 || event.key === 44) {
                trigger_dote = false
                putSymbol('.')
            }
            else if(event.key === 45) {
                if(isBtSymbolCorrect('-')) {
                    trigger_minus = false
                    flag_minus = !flag_minus;
                }
            }
            else if(event.key === Qt.Key_Backspace) {
                if(isBtSymbolCorrect('<')) {
                    trigger_bksp = false
                    backspSymbol();
                    if(value.length === 0) {
                        flag_minus = func_autoselect_flag_minus();
                    }
                }
            }
            else if(event.key === Qt.Key_Delete) {
                if(isBtSymbolCorrect('C')) {
                    trigger_ftsp = false
                    clear();
                    flag_minus = func_autoselect_flag_minus();
                }
            }
            else if(event.key === Qt.Key_Space) {
                if(isBtSymbolCorrect('#')) {
                    if(value.length > 0) {                        
                        clear();
                        flag_minus = func_autoselect_flag_minus();
                    } else {                        
                        value = getAbsValueStr(toPosixTextValue(placeholderSafeValue));                        
                        flag_minus = isPlaceholderSigned();
                    }
                }
                trigger_clear = false
                trigger_ftsp = false
            }
            else {
                trigger_1 = false;
                trigger_2 = false;
                trigger_3 = false;
                trigger_4 = false;
                trigger_5 = false;
                trigger_6 = false;
                trigger_7 = false;
                trigger_8 = false;
                trigger_9 = false;
                trigger_0 = false;
                trigger_bksp = false;
                trigger_ftsp = false;
                trigger_dote = false;
                trigger_minus = false;
                trigger_clear = false;
                trigger_copy = false;
            }
        }
    }

    property bool trigger_1: false
    property bool trigger_2: false
    property bool trigger_3: false
    property bool trigger_4: false
    property bool trigger_5: false
    property bool trigger_6: false
    property bool trigger_7: false
    property bool trigger_8: false
    property bool trigger_9: false
    property bool trigger_0: false
    property bool trigger_bksp: false
    property bool trigger_ftsp: false
    property bool trigger_dote: false
    property bool trigger_minus: false
    property bool trigger_clear: false
    property bool trigger_copy: false

    onFocusChanged: {
        if(!dialogPanel.focus) dialogPanel.forceActiveFocus()
    }

}
