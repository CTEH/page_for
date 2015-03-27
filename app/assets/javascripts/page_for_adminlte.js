
function adjustViewPorts() {
  var mq = window.matchMedia('(max-width: 992px)');
  if(mq.matches) {
    unFitViewPortsOnPage();
  }
  else {
    fitViewPortsOnPage();
  }
}

function unFitViewPortsOnPage() {
  $('.viewport').each( function(index, viewport) {
    var v = $(viewport);
    v.css('height', 'auto');
  });
}

function fitViewPortsOnPage() {
  $('.viewport').each( function(index, viewport) {
    var v = $(viewport);
    var offset = v.offset();
    var newHeight = 0;
    var nextElement = $(v.next());
    var paginationHeight = 0;
    if(nextElement.hasClass('pagination')) {
      paginationHeight = nextElement.height()+15;
    }

    if(offset.top != 0) {
      newHeight = $(window).height() - offset.top - paginationHeight;
    }
    if(newHeight > 400) {
      v.css('height', ''+newHeight+'px');
    }
    else {
      v.height(400);
    }
  });
};

$(window).on('load resize orientationChanged shown.bs.tab', function(){
  adjustViewPorts();
});
