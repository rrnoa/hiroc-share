(function($, Drupal)
{
  // I want some code to run on page load, so I use Drupal.behaviors
  Drupal.behaviors.searchResults = {
    attach:function()
    {
      $(window).scroll(function () {
        if ($(this).scrollTop() > 100) {
          $('.scroll-top').fadeIn();
        } else {
          $('.scroll-top').fadeOut();
        }
      });

      $('.scroll-top').click(function () {
        $("html, body").animate({
          scrollTop: 0
        }, 100);
          return false;
      });
    }
  };
}(jQuery, Drupal));
