(function() {
  //
  var Relate = window.Relate = {}, appFrame;
  //
  Relate.init = function (evt) {
    appFrame = document.getElementById('main');
  };
  //
  Relate.loadPage = function (page) {
    window.location = page;
  };
  //
  window.addEventListener('load', Relate.init, false);
}());