//= require jquery3
//= require jquery_ujs
//= require turbolinks

var Sheet;
var Marker;

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

  // Hide side sheet on click
  $(document).on("click", "#close", function (e) {
    e.preventDefault();
    Sheet.hide();
  });

  // Setup infinite scrolling
  $(window).on("scroll", function () {
    let url = $('.pagination .next a').attr('href');

    if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 200) {
      $('pagination').html();
      $.getScript(url);
    }
  });

  // Hide pagination since JS is being run
  $(".pagination").hide();

  // Highlight matches
  Marker = {
    mark: function () {
      var keyword = $("input[name='buka']").val();

      $("#results").unmark({
        done: function() {
          $("#results").mark(keyword);
        }
      });
    }
  }
  Marker.mark();
});
