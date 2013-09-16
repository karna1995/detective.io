# See also :
# http://blog.brunoscopelliti.com/deal-with-users-authentication-in-an-angularjs-web-app
class UserCtrl

    # Injects dependancies    
    @$inject : ["$scope", "$http", "$location", "$routeParams", "User", "Page"]

    constructor: (@scope, @http, @location, @routeParams, @User, @Page)-> 
        # Set page title with no title-case
        switch @location.path()
            when "/signup"
                @Page.title "Sign up", false   
            when "/login"
                @Page.title "Log in", false                
        # ──────────────────────────────────────────────────────────────────────
        # Scope attributes
        # ──────────────────────────────────────────────────────────────────────  
        @scope.user    = @User
        @scope.next    = @routeParams.next or "/"
        # ──────────────────────────────────────────────────────────────────────
        # Scope method
        # ──────────────────────────────────────────────────────────────────────
        @scope.loading = false
        @scope.login   = @login
        @scope.logout  = @logout

    # ──────────────────────────────────────────────────────────────────────────
    # Class methods
    # ──────────────────────────────────────────────────────────────────────────
    loginError: (error)=>        
        @User.set
            is_logged: false
            is_staff : false
            username : '' 
        # Record the error
        @scope.error = error if error?        

    login: =>
        config = 
            method: "POST"
            url: "/api/v1/user/login/"
            data: 
                username    : @scope.username
                password    : @scope.password
                remember_me : @scope.remember_me or false
            headers:
                "Content-Type": "application/json"       
        # Turn on loading mode
        @scope.loading = true
        # succefull login
        @http(config).then (response) =>   
            # Turn off loading mode
            @scope.loading = false
            # Interpret the respose            
            if response.data? and response.data.success
                @User.set
                    is_logged: true
                    is_staff : response.data.is_staff
                    username : @scope.username
                # Redirect to the next URL
                @location.url(@scope.next)
                # Delete error
                delete @scope.error
            else
                # Error status
                loginError(response.data.reason)        

    signup: =>
        config = 
            method: "POST"
            url: "/api/v1/user/"
            data: 
                username    : @scope.username
                email       : @scope.email
                password    : @scope.password
            headers:
                "Content-Type": "application/json"       
        # Turn on loading mode
        @scope.loading = true
        # succefull login
        @http(config).then (response) =>   
            # Turn off loading mode
            @scope.loading = false
            # Interpret the respose            
            if response.data? and response.data.success
                @scope.signupSuccedd = true
                # Delete error
                delete @scope.error
            else
                # Record the error
                @scope.error = response.data.reason if response.data.reason?    

    logout: =>
        config = 
            method: "GET"
            url: "/api/v1/user/logout/"
            headers:
                "Content-Type": "application/json"
        # Turn on loading mode
        @scope.loading = true
        # succefull logout
        @http(config).then (response) =>  
            # Turn off loading mode
            @scope.loading = false    
            # Interpret the respose                       
            if response.data? and response.data.success
                @User.set
                    is_logged: false
                    is_staff : false
                    username : ''


angular.module('detective').controller 'userCtrl', UserCtrl