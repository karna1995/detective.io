window.NotFoundCtrl = ($scope, Page, User)->
    Page.title "Page not found"
    $scope.isUserLogged = User.isLogged
    $scope.isUserUnlogged = ->
        !User.isLogged()

NotFoundCtrl.$inject = ['$scope', 'Page', 'User'];

angular.module('detective').controller 'notFoundCtrl', NotFoundCtrl