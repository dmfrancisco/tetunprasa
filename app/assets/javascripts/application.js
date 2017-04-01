//= require jquery3
//= require jquery_ujs
//= require turbolinks

var Sheet;
var Marker;

$(document).ready(function () {
  $("html").addClass("js");

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

  // Hide promo on click
  $(document).on("click", "#promo-close", function (e) {
    e.preventDefault();
    $("#promo").hide();
  });

  // Hide an element on click
  //
  // Elements with the `data-close` attribute can close a given element.
  // The element to be closed is specified by the `data-close` attribute.
  // If no value is specified, the parent will be closed.
  // An optional `data-animation` class can be passed.
  // If no value is specified, the element will just be hidden.
  $(document).on("click", "[data-close]", function (e) {
    e.preventDefault();

    var $this = $(this);
    var $element = $($this.data("close") || $this.parent());
    var animationClass = $this.data("animation");

    if (animationClass) {
      $element.addClass(animationClass);
      setTimeout(function () { $element.removeClass(animationClass).hide(); }, 1050);
    } else {
      $element.hide();
    }
  });

  // Remove the initial snackbar animation so it doesn't happen again
  setTimeout(function() {
    $(".Snackbar-message").removeClass("bounceInUp");
  }, 1050);

  // Setup infinite scrolling
  $(window).on("scroll", function () {
    var url = $('.pagination .next a').attr('href');

    if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 200) {
      $('.pagination').text('');
      $.getScript(url);
    }
  });

  // Modern browsers seem to keep the input value when the user hits back
  // This makes it seem the input value and search results don't match
  // It may also result in content being highlighted because of the `mark()` below
  if (typeof URLSearchParams !== "undefined") {
    var params = new URLSearchParams(window.location.search);
    $("input[name='buka']").val(params.get('buka'));
  }

  // Highlight matches
  Marker = {
    mark: function () {
      var keyword = $("input[name='buka']").val().replace(/\"/g, '');
      var $entries = $("#entries");

      if ($entries.find(".Entry--empty").length == 0) {
        $entries.unmark({
          done: function() {
            $("#entries").mark(keyword);
          }
        });
      }
    }
  }
  Marker.mark();
});
