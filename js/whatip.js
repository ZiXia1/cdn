/**
var t1 = performance.now();
if (typeof t1 != "undefined") {
    document.getElementById("TimeShow").innerHTML = " 页面加载耗时" + Math.round(t1) + "毫秒 ";
}
**/
function ajax() {
    var ajaxData = {
        type: arguments[0].type || "GET",
        url: arguments[0].url || "",
        async: arguments[0].async || "true",
        data: arguments[0].data || null,
        dataType: arguments[0].dataType || "text",
        contentType: arguments[0].contentType || "application/x-www-form-urlencoded",
        beforeSend: arguments[0].beforeSend || function () {},
        success: arguments[0].success || function () {},
        error: arguments[0].error || function () {}
    }
    ajaxData.beforeSend()
    var xhr = createxmlHttpRequest();
    xhr.responseType = ajaxData.dataType;
    xhr.open(ajaxData.type, ajaxData.url, ajaxData.async);
    xhr.setRequestHeader("Content-Type", ajaxData.contentType);
    xhr.send(convertData(ajaxData.data));
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                var header = xhr.getAllResponseHeaders();
                ajaxData.success(xhr.response, header)
            } else {
                ajaxData.error()
            }
        }
    }
}
function createxmlHttpRequest() {
    if (window.ActiveXObject) {
        return new ActiveXObject("Microsoft.XMLHTTP");
    } else if (window.XMLHttpRequest) {
        return new XMLHttpRequest();
    }
}
function convertData(data) {
    if (typeof data === 'object') {
        var convertResult = "";
        for (var c in data) {
            convertResult += c + "=" + data[c] + "&";
        }
        convertResult = convertResult.substring(0, convertResult.length - 1)
        return convertResult;
    } else {
        return data;
    }
}
ajax({
        type: "get",
        dataType: "json",
        url: "https://api.cdnmc.cn/ip/ryip.php",
        success: function(result) {
            var ipData = "";
            ipData += result.status + "回源节点：" + result.cdnip + "回源国家：" + result.cdnct + "你的IP：" + result.realip;
            $("#jsonTip").append(ipData);
        }
    });
ajax({
    type: "GET",
    url: "/cdn-cgi/trace",
    beforeSend: function () {},
    success: function (msg, header) {
        var sip = msg.match(/(ip=?)(\S*)/)[2];
        var str = msg.match(/(colo=?)(\S*)/)[2];
        var tls = msg.match(/(tls=?)(\S*)/)[2];
        var sni = msg.match(/(sni=?)(\S*)/)[2];
        var loc = msg.match(/(loc=?)(\S*)/)[2];
        var http = msg.match(/(http==?)(\S*)/)[2];
        var every = [['LAX', '洛杉矶'], ['SJC', '圣何塞'], ['HKG', '香港'], ['LHR', '伦敦'], ['TPE', '台北'], ['MFM',
            '澳门'], ['NRT', '东京'], ['KIX', '大阪'], ['ICN', '仁川'], ['BKK', '曼谷'], ['SIN', '新加坡'], [
            'AMS', '阿姆斯特丹'], ['CDG', '巴黎'], ['FRA', '法兰克福'], ['KUL', '马来西亚'], ['KBP', '乌克兰'], [
            'PRG', '布拉格'], ['BCN', '巴塞罗那'], ['YYZ', '多伦多'], ['SEA', '西雅图']];
        for (var i = 0; i < every.length; i++) {
            if (str == every[i][0]) {
                var cdnloc = every[i][1];
                break;
            }
        }
        document.getElementById("resultcfip").innerHTML = "[CDN Node: " + str + " " + cdnloc + "]" + "  [Your Country:" +
            loc + "] " + http;
        if (tls !== 'off') {
            document.getElementById("resultcfip").innerHTML += " Encrypted access:" + tls + "[SNI:" + sni + "]";
        }
