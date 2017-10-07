import QtQuick 2.3

Item {
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
//            console.log("text:"+buffer)
            return buffer;
        }
        return ""
    }    

    TextEdit {
        id: helper
        text: ""
    }
}
