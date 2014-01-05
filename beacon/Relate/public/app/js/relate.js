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
  Relate.selectItem = function (el) {
    document.querySelectorAll('.one')[0].parentNode.classList.remove('checking');
    document.querySelectorAll('.two')[0].parentNode.classList.remove('checking');
    document.querySelectorAll('.three')[0].parentNode.classList.remove('checking');
    document.querySelectorAll('.'+el)[0].parentNode.classList.add('checking');
  };
  //
  Relate.sendMessage = function (page) {
    alert('Message Sent!');
    Relate.loadPage(page);
  };
  //
  window.addEventListener('load', Relate.init, false);
}());