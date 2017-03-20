//= require jquery3
//= require jquery_ujs
//= require turbolinks

var Sheet;

$(document).ready(function () {
  Sheet = {
    show: function () {
      var $sheet = $("#sheet");

      if ($sheet.is(":visible")) return;
      $sheet.addClass("slideInRight").show();
      setTimeout(function () { $sheet.removeClass("slideInRight"); }, 750);
    },
    hide: function () {
      var $sheet = $("#sheet");

      if (!$sheet.is(":visible")) return;
      $sheet.addClass("slideOutRight");
      setTimeout(function () { $sheet.removeClass("slideOutRight").hide(); }, 750);
    }
  }

  $(document).on("click", "#close", function (e) {
    e.preventDefault();
    Sheet.hide();
  });
});
