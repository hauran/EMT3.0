# socket = io.connect(window.location.origin)

# socket.on 'new_post', (data) ->
# 	RSPY.newPost(data.payload)
	
# socket.on 'ill_do_it', (data) ->
# 	RSPY.updatePostStats data

# socket.on 'maybe_do_it', (data) ->
# 	RSPY.updatePostStats data

# socket.on 'not_gonna_do_it', (data) ->
# 	RSPY.updatePostStats data

# socketio_connect = () ->
# 	socket.emit 'signedIn', RSPY.meEmail
