angular.module('detective.config').config [
    "$stateProvider", "$urlRouterProvider", "$locationProvider",
    ($stateProvider, $urlRouterProvider, $locationProvider)->
        # HTML5 Mode yeah!
        $locationProvider.html5Mode true
        # Not found URL
        $urlRouterProvider.otherwise("/404");

        # ui-router configuration
        $stateProvider
            .state('home',
                url: "/"
                template: '<ui-view/>'
                controller: ["Auth", "$state", (Auth, $state)->
                    unless $state.includes("home.*")
                        if Auth.isAuthenticated()
                            $state.go "home.dashboard"
                        else
                            $state.go "home.tour"
                ]
            )
            .state('home.tour',
                url: 'tour/?scrollTo'
                controller: TourCtrl
                templateUrl: '/partial/home.tour.html'
            )
            .state('home.dashboard',
                controller: DashboardCtrl
                templateUrl: '/partial/home.dashboard.html'
                resolve: DashboardCtrl.resolve
                auth: true
            )
            .state('404-page',
                url: "/404/"
                controller: NotFoundCtrl
                templateUrl: '/partial/404.html'
            )
            .state('404',
                controller: NotFoundCtrl
                templateUrl: '/partial/404.html'
            )
            .state('403',
                controller: NotFoundCtrl
                templateUrl: '/partial/403.html'
            )
            .state('contact-us',
                url: "/contact-us/"
                controller: ContactUsCtrl
                templateUrl: '/partial/contact-us.html'
            )
            .state('plans',
                url: "/plans/"
                templateUrl: '/partial/plans.html'
                controller: ["Page", (Page) ->
                    Page.title "Paid plans"
                ]
            )
            # Accounts
            .state('activate',
                url: "/account/activate/?token"
                controller: UserCtrl
                templateUrl: '/partial/account.activation.html'
            )
            .state('reset-password',
                url: "/account/reset-password/?token"
                controller: UserCtrl
                templateUrl: '/partial/account.reset-password.html'
            )
            .state('reset-password-confirm',
                url: "/account/reset-password-confirm/?token"
                controller: UserCtrl
                templateUrl: '/partial/account.reset-password.confirm.html'
            )
            .state('login',
                url: "/login/?nextState&nextParams"
                auth: false # authenticated users cannot access this page
                controller: LoginCtrl
                templateUrl: '/partial/account.login.html'
            )
            .state('signup',
                url: "/signup/?email"
                auth: false # authenticated users cannot access this page
                controller: UserCtrl
                templateUrl: '/partial/account.signup.html'
            )
            .state('signup-invitation'
                url: "/signup/:token/"
                controller: UserCtrl
                templateUrl: '/partial/account.signup.html'
            )
            .state('subscribe'
                url: "/subscribe/?plan"
                templateUrl: '/partial/account.subscribe.html'
                controller: UserCtrl
            )
            # Pages
            .state('page',
                url: "/page/:slug/"
                controller: PageCtrl
                # Allow a dynamic loading by setting the templateUrl within controller
                template: "<div ng-include src='templateUrl'></div>"
            )
            # User-related url
            .state('user',
                url: "/:username/"
                template: '<ui-view/>'
                controller: ['Auth', 'User', '$state', '$stateParams', (Auth, User, $state, $stateParams) =>
                    unless $state.includes("user.*")
                        if (do Auth.isAuthenticated) and User.username is $stateParams.username
                            $state.go 'user.me', { username: $stateParams.username }
                        else
                            $state.go 'user.notme', { username: $stateParams.username }
                ]
            )
            .state('user.notme',
                controller: UserProfileCtrl
                templateUrl: "/partial/account.html"
                default: 'user'
                resolve:
                    user: UserCtrl.resolve.user
                    userGroups: ['Group', '$q', 'user', (Group, $q, user)->
                        deferred = $q.defer()
                        UserProfileCtrl.loadGroups(Group, user, 1).then (results)->
                            deferred.resolve results
                        deferred.promise
                    ]
                    topics: [ 'userGroups', (userGroups)->
                        UserProfileCtrl.getTopics userGroups
                    ]
            )
            .state('user.me',
                auth: true
                controller: UserProfileCtrl
                templateUrl: "/partial/account.html"
                default: 'user'
                resolve:
                    user: UserCtrl.resolve.user
                    userGroups: ['Group', '$q', 'user', (Group, $q, user)->
                        deferred = $q.defer()
                        UserProfileCtrl.loadGroups(Group, user, 1).then (results)->
                            deferred.resolve results
                        deferred.promise
                    ]
                    topics: [ 'userGroups', (userGroups)->
                        UserProfileCtrl.getTopics userGroups
                    ]
            )
            .state('user.settings',
                auth: true
                controller: AccountSettingsCtrl
                url: 'settings/'
                templateUrl: '/partial/account.settings.html'
                default: 'home'
            )
            # ------------------
            # Topic-related URLs
            # ------------------
            # Note:
            #   URL order matters. Like in django if we declare a pattern like
            #   `/user/:type/` before another pattern `/user/stuff/` the second
            #   pattern wont be accessible by its URL and we will never trigger
            #   the proper state.
            .state('user-topic-create',
                url: '/:username/create/'
                controller: CreateTopicCtrl
                reloadOnSearch: no
                templateUrl: '/partial/topic.form.html'
                resolve: CreateTopicCtrl.resolve
            )
            .state('user-topic-create.choose-ontology',
                templateUrl: '/partial/topic.form.choose-ontology.html'
            )
            .state('user-topic-create.customize-ontology',
                controller: EditTopicOntologyCtrl
                templateUrl: '/partial/topic.form.customize-ontology.html'
            )
            .state('user-topic-create.describe',
                templateUrl: '/partial/topic.form.describe.html'
            )
            # check previous comment before changing URLs order.
            .state('user-topic',
                url: "/:username/:topic/"
                controller: ExploreCtrl
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                # Allow a dynamic loading by setting the templateUrl within controller
                template: "<div ng-include src='templateUrl' ng-if='templateUrl'></div>"
            )
            .state('user-topic-edit',
                url: "/:username/:topic/edit/"
                controller: EditTopicCtrl
                templateUrl: '/partial/topic.form.html'
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                auth: true
                owner: true
            )
            .state('user-topic-delete',
                url: "/:username/:topic/delete/"
                controller: DeleteTopicCtrl
                templateUrl: '/partial/topic.delete.html'
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                auth: true
                owner: true
            )
            .state('user-topic-graph',
                url: "/:username/:topic/graph/"
                controller: ExploreCtrl
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                # Allow a dynamic loading by setting the templateUrl within controller
                template: "<div ng-include src='templateUrl' ng-if='templateUrl'></div>"
            )
            .state('user-topic-invite',
                url: "/:username/:topic/invite/"
                controller: AddCollaboratorsCtrl
                templateUrl: '/partial/topic.invite.html'
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                    collaborators: AddCollaboratorsCtrl.resolve.collaborators
                    administrators: AddCollaboratorsCtrl.resolve.administrators
                auth: true
                admin: yes
            )
            .state('user-topic-search',
                url: '/:username/:topic/search/?q&page'
                controller: IndividualSearchCtrl
                templateUrl: "/partial/topic.list.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
             # Topic-related url
            .state('user-topic-article',
                url: '/:username/:topic/p/:slug/'
                controller: ArticleCtrl
                templateUrl: "/partial/topic.article.html"
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
            .state('user-topic-contribute',
                url: '/:username/:topic/contribute/?id&type'
                controller: ContributeCtrl
                templateUrl: "/partial/topic.contribute.html"
                resolve:
                    forms: UserTopicCtrl.resolve.forms
                    topic: UserTopicCtrl.resolve.topic
                auth: true
            )
            .state('user-topic-contribute-upload',
                url: '/:username/:topic/contribute/upload/'
                controller: BulkUploadCtrl
                templateUrl: "/partial/topic.contribute.bulk-upload.html"
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                auth: true
            )
            .state('user-topic-list',
                url: '/:username/:topic/:type/?page'
                controller: IndividualListCtrl
                templateUrl: "/partial/topic.list.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
            .state('user-topic-detail',
                url: '/:username/:topic/:type/:id/'
                controller: IndividualSingleCtrl
                templateUrl: "/partial/topic.single.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                    forms: UserTopicCtrl.resolve.forms
                    individual: UserTopicCtrl.resolve.individual
            )
            .state('user-topic-detail.network',
                url: 'network'
                templateUrl: "/partial/topic.single.network.html"
            )
]