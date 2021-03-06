class App.Github.Issue extends Backbone.Model

  initialize: ->
    @computeAttributes()

    App.github.search_filters.on 'add:filter remove:filter', @checkFilter

  computeAttributes: ->
    @set 'created_at_formatted', moment( @get('created_at') ).from( moment() )

  # A bit of a hacky way to check against each issue
  # and mark it as filtered or not
  checkFilter: (o) =>
    filters = App.github.search_filters
    users = filters.get('users')
    milestones = filters.get('milestones')
    repos = filters.get('repos')
    projects = filters.get('projects')

    doesPass = =>
      # if users filter is not empty
      unless _.isEmpty users
        return false unless _.contains users, @get('assignee')?.login

      # if milestones filter is not empty
      unless _.isEmpty milestones
        return false unless _.contains milestones, @get('milestone')?.title

      # if repos filter is not empty
      unless _.isEmpty repos
        return false unless _.contains repos, @get('repository')

      # if projects filter is not empty.
      # this check is pretty heavy. Would be nice
      # to find a way to make this a bit more effecient
      unless _.isEmpty projects
        does_contain = false
        _.each @get('labels'), (label) ->
          if _.contains projects, label.name.toLowerCase().replace('p:', '')
            does_contain = true
        return does_contain

      # if all passes, return true
      return true

    # set to true or false, 
    @set 'filterMatch', doesPass()