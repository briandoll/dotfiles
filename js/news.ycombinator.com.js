$("table").attr("bgcolor", "#ffffff")
$("td.default").css("background-color", "#fffffc");
$("td.default").css("padding-bottom", "20px");
$("td.default").css("border", "1px solid #fffffa");

$("span.comment").css("font-family", "Trebuchet MS");
$("span.comment").css("line-height", "1.6em");

$(".subtext").css("font-size", "10pt");
$(".subtext").css("color", "silver");
$(".subtext").css("padding-bottom", "10px");

$(".title").css("font-size", "12pt");

$('a:contains("github")').closest('tr').css("background-color", "lightyellow");
$('a:contains("GitHub")').closest('tr').css("background-color", "lightyellow");
$('a:contains("Github")').closest('tr').css("background-color", "lightyellow");
$('a[href*="github"]').closest('tr').css("background-color", "lightyellow");
$('span.comment:contains("github")').closest('td.default').css("background-color", "lightyellow");
$('span.comment:contains("Github")').closest('td.default').css("background-color", "lightyellow");
$('span.comment:contains("GitHub")').closest('td.default').css("background-color", "lightyellow");
