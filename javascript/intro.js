(function() {
  var Resize;
  $(document).ready(function() {
    var resize;    
    resize = new Resize();
    resize.init();
  });
  Resize = (function() {
    function Resize() {}
    Resize.prototype.init = function() {
      var render, support;
      support = $("html").hasClass("backgroundsize");
      render = support ? this.renderRealBrowser : this.renderIe;
      $(window).resize(render);
      return render();
    };
    Resize.prototype.renderIe = function() {
      var crop, height, pageHeight, pageWidth, width;
      width = pageWidth = $(window).width();
      height = width * 0.58;
      pageHeight = $(window).height();
      if (height >= pageHeight) {
        crop = -0.5 * (height - pageHeight);
        return $(".full-screen").css({
          width: width,
          height: height - 30,
          marginBottom: crop * 2
        });
      } else {
        width = height * 1.69;
        crop = -0.5 * (width - pageWidth);
        return $(".full-screen").css({
          width: width,
          height: height,
          marginRight: crop * 2
        });
      }
    };
    Resize.prototype.renderRealBrowser = function() {
      var height;
      height = $(window).height();
      return $(".full-screen").css({
        height: height - 30
      });
    };
    return Resize;
  })();
}).call(this);
