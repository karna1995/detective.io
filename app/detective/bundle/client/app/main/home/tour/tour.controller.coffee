class window.TourCtrl
    # Injects dependencies
    @$inject: ['$scope', '$rootElement', 'Page', "Common"]
    constructor: (@scope, @rootElement, @Page, @Common)->
        # Set page title with no title-case
        @Page.title "Data-driven investigations", false
        # Scroll to an element inside the tour
        @scope.scrollTo = (level)=>
            # Broadcast an event catch into the directive homeTour
            @scope.$broadcast "tour:scrollTo", level


angular.module('detective').controller 'tourCtrl', TourCtrl