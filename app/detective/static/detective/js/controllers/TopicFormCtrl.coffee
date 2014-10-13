class window.TopicFormCtrl
    @$inject: ['$scope', '$state', 'TopicsFactory', 'Page', 'User', 'constants.events']

    MODES:
        editing: 'edit'
        creating: 'create'

    constructor: (@scope, @state, @TopicFactory, @Page, @User, @EVENTS)->
        @form_mode = undefined
        @scope.submitted = no
        @scope.submit = @submit
        @scope.shouldShowForm = @isEditing
        @scope.isEditing      = @isEditing
        @scope.isCreating     = @isCreating
        @scope.hideErrors     = @hideErrors
        @scope.canMakePrivate = @canMakePrivate

        @scope.formMode = =>
            @form_mode

        @scope.$watch 'topic', @onTopicUpdated, yes

    isEditing: =>
        @form_mode is @MODES.editing

    isCreating: =>
        @form_mode is @MODES.creating

    setCreatingMode: =>
        @form_mode = @MODES.creating

    setEditingMode: =>
        @form_mode = @MODES.editing

    onTopicUpdated: (old_val, new_val) =>
        @hideErrors()
        @scope.$broadcast @EVENTS.topic.user_updated, old_val, new_val

    hideErrors: =>
        unless @scope.loading
            @scope.submitted = no

    assertModeInitialized: =>
        return if @form_mode?
        throw new Error("TopicFormCtrl children must set the form mode (create or edit)")

    submit: (form)=>
        @assertModeInitialized()
        @scope.submitted = yes
        return unless form.$valid
        if @isEditing()
            @edit()
        if @isCreating()
            @create()

    canMakePrivate: => @User.profile.plan != 'free'

