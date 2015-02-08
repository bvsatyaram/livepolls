class Poll
  votedFor: null

  showUser: (user) ->
    template = $('#user_template').html();
    Mustache.parse(template);
    rendered = Mustache.render(template, {user: user, votes: user.votes});
    $('#users').append(rendered)

  showUsers: (users) ->
    @showUser(user) for user in JSON.parse(users)

@poll = new Poll

$ ->
  if $('#users').length
    $('#show_poll').click()