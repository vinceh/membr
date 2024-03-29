'use strict';

var app = angular.module('membr', ['membr.services', 'membr.directives']);

function AppCtrl($scope, $location, $http, User, Membership, Member, $q, $timeout) {
  $http.defaults.headers.common ['X-CSRF-Token']=$('meta[name="csrf-token"]').attr('content');

  $scope.member_urls = Member.urls;

  $scope.masterLoading = true;
  // loading all the data
  var promises = [
    Membership.get_all().then(function(memberships) {
      $scope.memberships = memberships;
    }),

    Member.get_all().then(function(members) {
      $scope.members = members;
    }),

    Member.get_all_inactive().then(function(members) {
      $scope.inactiveMembers = members;
    }),

    User.accountStatus().then(function(status) {
      $scope.accountStatus = status;
    }),

    User.invoices(1).then(function(data) {
      $scope.transactions = data.invoices;
      $scope.transactions_page = 1;
      $scope.total_transactions_page = data.total_pages
    })
  ];

  $q.all(promises).then( function() {
    // FIX THIS HACK
    $('.members').show();
    $timeout(function(){
      $("#members").tablesorter({
        headers: { 3: { sorter: false} }
      });
      $("#inactiveMembers").tablesorter({
        headers: { 3: { sorter: false} }
      });
    });

    $scope.masterLoading = false;
  });

  $scope.membership = new Membership();

  $scope.getMoreInvoices = function() {
    if ($scope.transactions_page < $scope.total_transactions_page && !$scope.getting_transactions) {
      $scope.transactions_page = $scope.transactions_page + 1;
      $scope.getting_transactions = true;
      User.invoices($scope.transactions_page).then(function(data) {
        $scope.transactions = $scope.transactions.concat(data.invoices);
        $scope.getting_transactions = false;
      })
    }
  };

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
      $scope.show_success('Membership created');
    });
  }

  $scope.editMembership = function(m, index) {
    $scope.memberEdit = $.extend(true, {}, m);
    $scope.memberEdit.listIndex = index;
    $('.membership-edit').appendTo($('#membership'+index));
    $scope.memberEditOpen = true;
  }

  $scope.deleteMembership = function(membership) {
    $scope.deletingMembership = true;
    $scope.$apply();

    // dirty hack
    $('.cancel-member a').attr('disabled', true);

    Membership.delete_membership(membership).then(function(data) {
      // dirty hacks
      $('.cancel-link a').attr('disabled', false);
      $('.membership-edit').appendTo($('.memberships'));

      $scope.memberships = _.reject($scope.memberships, function(m) {return m.id == membership.id});
      $scope.members = data.members;
      $scope.deletingMembership = false;
      $scope.memberEditOpen = false;
      $scope.show_success("Membership successfully deleted");
    });
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
      $scope.show_success("Invite sent");
    });
  }

  $scope.memberDetail = function(member) {
    $scope.memberDetailOpen = true;
    $scope.detailMember = member;
    $scope.loadingInvoices = true;
    $scope.detailMemberMemberships = $scope.memberships;

    if (member.active && !member.cancel_at_period_end) {
      $scope.detailMemberMemberships =
        _.reject($scope.memberships, function(m) {
          return m.name == member.membership;
        });
    }

    if ($scope.detailMemberMemberships.length > 0 ) {
      $scope.changeMembership = $scope.detailMemberMemberships[0].id;
    }

    $timeout(function(){
      $('#change-membership').trigger('update');
    });

    Member.invoices_for(member.id).then(function(data) {
      $scope.loadingInvoices = false;
      $scope.invoices = data.invoices;
    });
  }

  $scope.cancelMember = function(member) {
    $scope.cancelingMember = true;
    $scope.$apply();

    // dirty hack
    $('.cancel-link a').attr('disabled', true);

    Member.cancel_member(member.id).then(function(data) {

      var index = $scope.members.indexOf(member);
      $scope.members[index] = data.member;
      $scope.show_success("Membership successfully canceled");
      $scope.cancelingMember = false;
      $scope.memberDetailOpen = false;

      // dirty hack
      $('.cancel-link a').attr('disabled', false);

      $timeout(function(){
        $('table').trigger('update');
      });
    });
  }

  $scope.changeMember = function(member, membership) {
    $scope.changingMember = true;
    $scope.$apply();

    // dirty hack
    $('.change-member button').attr('disabled', true);

    Member.change_membership(member, membership).then(function(response) {
      if ( member.active ) {
        $scope.members = _.without($scope.members, member);
      }
      else {
        $scope.inactiveMembers = _.without($scope.inactiveMembers, member);
      }

      $scope.members.push(response.member);
      $scope.changingMember = false;
      $scope.show_success("Membership successfully changed");
      $scope.memberDetailOpen = false;

      // dirty hack
      $('.change-member button').attr('disabled', false);

      $timeout(function(){
        $('table').trigger('update');
      });
    });
  }

  $scope.invoiceHelpers = {
    startingText: function(invoice) {
      if (invoice) {
        var membership = invoice.lines.data[0].plan.name;
        var attempts = invoice.attempt_count;
        if ( attempts > 0 ) {
          var attemptText = '(' + attempts + ' attempt' + (attempts > 0 && 's' || '') + ')';
        }
        else {
          var attemptText = "";
        }
        return '$' + (invoice.total/100).toFixed(2) + ' for ' + membership + ' ' + attemptText;
      }
    },
    paid: function(invoice) {
      return invoice.paid && 'Paid' || 'Not Paid';
    }
  }

  $scope.show_success = function(msg) {
    $scope.successMessage = msg;
    $scope.showSuccess = true;
    $timeout(function() {
      $scope.showSuccess = false;
    }, 3000);
  };

  $scope.hasPublicMemberships = function() {
    if ($scope.memberships && $scope.memberships.length == 0) return false;

    return _.where($scope.memberships, {is_private: false}).length > 0
  }

  $scope.revenue_text = function(fee, count) {
    return Math.round((fee*count)/100).toFixed(2);
  }

  $scope.sendPaymenter = function(member) {
    $scope.sendingPaymenter = true;
    $scope.$apply();

    Member.send_paymenter(member).then(function() {
      $scope.show_success("Payment update email successfully sent");
      $scope.sendingPaymenter = false;
      $scope.memberDetailOpen = false;
    });
  }

  $scope.updateMembership = function(membership) {
    $scope.updatingMembership = true;

    Membership.update(membership).then(function(data) {
      $scope.show_success("Membership successfully updated");

      // dirty hack
      $('.membership-edit').appendTo($('.memberships'));

      $scope.memberships[membership.listIndex] = data.membership;
      $scope.members = data.members;
      $scope.updatingMembership = false;
      $scope.memberEditOpen = false;
    });
  }

  $scope.paidMembers = function() {
    if ($scope.members && $scope.members.length > 10) {
      return $scope.members.length - 10;
    }
    else {
      return 0;
    }
  }
}

angular.module('membr.services', [], function ($provide) {
  $provide.factory('Member', function ($http) {
    var Member = function (data) {
      angular.extend(this, data);
    }

    Member.get_all = function (page) {
      return $http.get('/api/members/all').then(function (response) {
        return response.data;
      })
    }

    Member.get_all_inactive = function (page) {
      return $http.get('/api/members/all_inactive').then(function (response) {
        return response.data;
      })
    }

    Member.send_invite = function(invite) {
      return $http.post('api/member/invite', {creatable: invite}).then(function (response) {
        return response.data;
      })
    }

    Member.invoices_for = function(id) {
      return $http.get('api/members/invoice/' + id).then(function (response) {
        return response.data;
      })
    }

    Member.cancel_member = function(id) {
      return $http.put('api/members/cancel/' + id).then(function (response) {
        return response.data;
      })
    }

    Member.change_membership = function(member, membership) {
      return $http.post('api/members/change', {id: member.id, membership_id: membership}).then(function (response) {
        return response.data;
      })
    }

    Member.send_paymenter = function(member) {
      return $http.post('api/members/sendPaymenter', {id: member.id}).then(function (response) {
        return response.data;
      })
    }

    Member.urls = {
      bulk_invite: '/api/members/bulkInvite'
    };

    return Member;
  });

  $provide.factory('Invoice', function ($http) {
    var Invoice = function (data) {
      angular.extend(this, data);
    }

    return Invoice;
  });

  $provide.factory('User', function ($http) {
    var User = function (data) {
      angular.extend(this, data);
    }

    User.accountStatus = function () {
      return $http.get('api/user/account').then(function (response) {
        return response.data;
      })
    }

    User.invoices = function(page) {
      return $http.get('transactions/members?page=' + page).then(function (response) {
        return response.data;
      })
    }

    return User;
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
      var membership = jQuery.extend(true, {}, membership);
      membership.is_private = membership.is_private == 1;
      membership.fee = membership.fee*100;
      membership.renewal_period = parseInt(membership.renewal_period);

      return $http.post('api/memberships/create', {membership: membership}).then(function (response) {
        return new Membership(response.data.membership);
      })
    }

    Membership.get_all = function () {
      return $http.get('api/memberships/all').then(function (response) {
        return response.data;
      })
    }

    Membership.update = function (membership) {
      membership.is_private = membership.is_private == 1;
      return $http.post('api/memberships/update', {id: membership.id, membership: membership}).then(function (response) {
        return response.data;
      })
    }

    Membership.delete_membership = function(membership) {
      return $http.post('api/memberships/delete/' + membership.id).then(function (response) {
        return response.data;
      })
    }

    return Membership;
  });
});

angular.module('membr.directives', []).
  directive('fileUpload',function ($timeout) {
    return {
      restrict: 'A',
      scope: {
        url: '=fileUpload',
        loader: '=loader',
        success: '&success'
      },
      link: function ($scope, $element, $attrs) {
        $scope.$watch('url', function(value) {
          if ( value ) {
            $element.fileupload({
              dataType: 'json',
              url: $scope.url,
              progress: function() {
                $scope.loader = true;
                $scope.$apply();
              },
              done: function (e, data) {
                $scope.loader = false;
                $scope.success();
                $scope.$apply();
              }
            });
          }
        });
      }
    }
  }).
  directive('confirm',function ($timeout) {
    return {
      restrict: 'A',
      scope: {
        confirm: '@confirm',
        action: '&action'
      },
      link: function ($scope, $element, $attrs) {
        $element.click(function() {
          if (confirm($scope.confirm)) {
            $scope.action();
          }
        });
      }
    }
  }).
  directive('popUp',function () {
    return {
      restrict: 'A',
      link: function ($scope, $element, $attrs) {
        $element.click(function () {
          window.open(encodeURI($attrs.popUp), 'mywindow', 'width=' + $attrs.width + ',height=' + $attrs.height);
        });
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
