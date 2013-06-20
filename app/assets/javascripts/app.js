'use strict';

var app = angular.module('membr', ['membr.services', 'membr.directives']);

function AppCtrl($scope, $location, $http, Membership, Member, $q, $timeout) {
  $http.defaults.headers.common ['X-CSRF-Token']=$('meta[name="csrf-token"]').attr('content');

  $scope.masterLoading = true;
  // loading all the data
  var promises = [
    Membership.get_all().then(function(memberships) {
      $scope.memberships = memberships;
    }),

    Member.get_all().then(function(members) {
      $scope.members = members;
    })
  ];

  $q.all(promises).then( function() {
    // FIX THIS HACK
    $('.members').show();
    $timeout(function(){
      $("#members").tablesorter({
        headers: { 3: { sorter: false} }
      });
    });

    $scope.masterLoading = false;
  });

  $scope.membership = new Membership();

  $scope.showScope = function() {
    console.log($scope);
  }

  $scope.createMembership = function() {
    $scope.membershipCreating = true;
    Membership.create($scope.membership).then(function(membership) {
      $scope.membershipCreating = false;
      $scope.membership = new Membership();
      $scope.membershipOpened = false;
      $scope.memberships.unshift(membership);
      $scope.newMembership.$setPristine();
    });
  }

  $scope.editMembership = function(m) {
    $scope.memberEdit = jQuery.extend({}, m);;
  }

  $scope.openInvite = function() {
    $scope.inviteWrapOpen = true;
    $scope.invite = {
      email: null,
      membership_id: $scope.memberships[0].id
    }
    $timeout(function(){
      $('#invite-membership').trigger('update');
      $scope.inviteForm.$setPristine();
    });

  }

  $scope.sendInvite = function(invite) {
    $scope.sendingInvite = true;

    Member.send_invite($scope.invite).then(function(data) {
      $scope.sendingInvite = false;
      $scope.inviteWrapOpen = false;
      $scope.inviteSentClass = "show";
      $timeout(function() {
        $scope.inviteSentClass = "";
      }, 2000);
    });
  }
}

angular.module('membr.services', [], function ($provide) {
  $provide.factory('Boardgame', function ($http) {
    var Boardgame = function (data) {
      angular.extend(this, data);
    }

    Boardgame.get = function (page) {
      return $http.get('/api/bg?page=' + page).then(function (response) {
        return new Boardgame(response.data.membership);
      })
    }

    return Boardgame;
  });

  $provide.factory('Member', function ($http) {
    var Member = function (data) {
      angular.extend(this, data);
    }

    Member.get_all = function (page) {
      return $http.get('/api/members/all').then(function (response) {
        return response.data;
      })
    }

    Member.send_invite = function(invite) {
      return $http.post('api/member/invite', {creatable: invite}).then(function (response) {
        return response.data;
      })
    }

    return Member;
  });

  $provide.factory('Membership', function ($http) {
    var Membership = function (data) {
      this.name = null;
      this.is_private = 0;
      this.renewal_period = 1;
      this.fee = null;
      angular.extend(this, data);
    }

    Membership.create = function (membership) {
      membership.is_private = membership.is_private && true || false
      membership.renewal_period = parseInt(membership.renewal_period);

      return $http.post('api/memberships/create', {membership: membership}).then(function (response) {
        return new Membership(response.data.membership);
      })
    }

    Membership.get = function (page) {
      return $http.get('/api/bg?page=' + page).then(function (response) {
        return new Boardgame(response.data);
      })
    }

    Membership.get_all = function () {
      return $http.get('/api/memberships/all').then(function (response) {
        return response.data;
      })
    }

    return Membership;
  });
});

angular.module('membr.directives', []).
  directive('popUp',function () {
    return {
      restrict: 'A',
      link: function ($scope, $element, $attrs) {
        $element.click(function () {
          console.log('popping', $attrs.popUp);
          window.open(encodeURI($attrs.popUp), 'mywindow', 'width=' + $attrs.width + ',height=' + $attrs.height);
        });
      }
    }
  }).
  directive('scrolly',function () {
    return {
      restrict: "A",
      scope: {
        scrolly: '&'
      },
      link: function (scope, element, attrs) {

        $(window).scroll(function () {
          if (distanceToBottom() <= 500) {
            scope.scrolly();
          }
        });

        function distanceToBottom() {
          var scrollPosition = window.pageYOffset;
          var windowSize = window.innerHeight;
          var bodyHeight = document.body.offsetHeight;

          return Math.max(bodyHeight - (scrollPosition + windowSize), 0);
        }
      }
    }
  }).
  directive('slider', function () {
    return {
      restrict: "A",
      scope: {
        sliderValue: '=',
        sliderType: '@',
        min: '@',
        max: '@',
        step: '@',
        initial: '='
      },
      controller: function ($scope, $element, $attrs) {
        var min = parseInt($attrs.min);
        var max = parseInt($attrs.max);
        var range = true;
        var value;

        if ($attrs.sliderType == 'single') {
          range = 'min';
          value = parseInt($scope.initial);
          $scope.sliderValue = value;
          $scope.sliderDisplay = value;
        }
        else if ($attrs.sliderType == 'double') {
          range = true;
          value = [2, 5];
          $scope.sliderValue = value;
          $scope.sliderDisplay = value;
        }

        $element.children('.slider').slider({
          step: parseInt($attrs.step),
          range: range,
          min: min,
          max: max,
          value: parseInt($scope.initial),
          values: value,
          slide: function (event, ui) {

            if ($attrs.sliderType == 'single') {
              $scope.sliderDisplay = ui.value;
            }
            else if ($attrs.sliderType == 'double') {
              $scope.sliderDisplay = ui.values;
            }

            $scope.$apply();
          },
          change: function (event, ui) {

            if ($attrs.sliderType == 'single') {
              $scope.sliderValue = ui.value;
            }
            else if ($attrs.sliderType == 'double') {
              $scope.sliderValue = ui.values;
            }
            $scope.$apply();
          }
        });
      }
    }
  });
