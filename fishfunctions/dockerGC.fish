function dockerGC --description 'garbage collect old docker containers and images'
  for old_container in (docker ps --filter status=exited -q)
    echo "removing old container $old_container"
    docker rm -v $old_container > /dev/null
  end
  for old_image in (docker images --filter dangling=true -q)
    echo "removing old image $old_image"
    docker rmi $old_image > /dev/null
  end
end