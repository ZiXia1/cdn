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
    error: function () {
        console.log("error")
    }
  }
})
