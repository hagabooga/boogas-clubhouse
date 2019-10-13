extends Node2D

slave func setPosition(pos):
  position = pos
  
master func shutItDown():
  #Send a shutdown command to all connected clients, including this one
  rpc("shutDown")
  
sync func shutDown():
  get_tree().quit()
  
func _physics_process(delta):
  var moveByX = 0
  var moveByY = 0
  if(is_network_master()):
    if Input.is_key_pressed(KEY_LEFT):
      moveByX = -5
  
    if Input.is_key_pressed(KEY_RIGHT):
      moveByX = 5

    if Input.is_key_pressed(KEY_UP):
      moveByY = -5

    if Input.is_key_pressed(KEY_DOWN):
      moveByY = 5

    if Input.is_key_pressed(KEY_Q):
      shutItDown()
      
    # Tell the other computer about our new position so it can update       
    rpc_unreliable("setPosition",Vector2(position.x, position.y))
  # Move our local player
  translate(Vector2(moveByX,moveByY))
